use std::ffi::{CStr, CString};
use std::io::BufReader;
use std::os::raw::c_char;
use std::prelude::v1::*;
use std::ptr;
use std::time::*;

use base64;
use chrono::prelude::*;
use itertools::Itertools;
use rustls;
use serde_json;
use serde_json::Value;
use webpki;

use crate::error::sgx_status_t;
use crate::pib::*;
use crate::types::{sgx_quote_t, ReportBody, VerifyResult};

pub type uint8_t = u8;
pub type uint16_t = u16;
pub type uint32_t = u32;
pub type sgx_epid_group_id_t = [uint8_t; 4];
pub type sgx_isv_svn_t = uint16_t;

type SignatureAlgorithms = &'static [&'static webpki::SignatureAlgorithm];
static SUPPORTED_SIG_ALGS: SignatureAlgorithms = &[
    &webpki::ECDSA_P256_SHA256,
    &webpki::ECDSA_P256_SHA384,
    &webpki::ECDSA_P384_SHA256,
    &webpki::ECDSA_P384_SHA384,
    &webpki::RSA_PSS_2048_8192_SHA256_LEGACY_KEY,
    &webpki::RSA_PSS_2048_8192_SHA384_LEGACY_KEY,
    &webpki::RSA_PSS_2048_8192_SHA512_LEGACY_KEY,
    &webpki::RSA_PKCS1_2048_8192_SHA256,
    &webpki::RSA_PKCS1_2048_8192_SHA384,
    &webpki::RSA_PKCS1_2048_8192_SHA512,
    &webpki::RSA_PKCS1_3072_8192_SHA384,
];

pub const IAS_REPORT_CA: &[u8] = include_bytes!("AttestationReportSigningCACert.pem");

#[no_mangle]
pub extern "C" fn verify_mra_cert(pem: *const c_char) -> *const c_char {
    let res = match verify_cert(pem) {
        Ok(report_body) => VerifyResult {
            result: "Success".to_string(),
            report_body
        },
        Err(e) => VerifyResult {
            result: e,
            report_body: ReportBody::default()
        }
    };
    let c_str_song = match serde_json::to_string(&res) {
        Ok(res_string) => CString::new(res_string.as_str()).unwrap(),
        Err(_) => CString::new("Serialize failed").unwrap()
    };
    c_str_song.into_raw()
}

fn verify_cert(pem: *const c_char) -> Result<ReportBody, String> {
    let cert_der = unsafe {
        CStr::from_ptr(pem).to_str()
    };
    let cert_der = match cert_der {
        Ok(cert_der_str) => match hex::decode(cert_der_str) {
            Ok(cert_der_vec) => cert_der_vec,
            Err(_) => return Err("hex::decode(cert_der_str) error".to_string())
        },
        Err(_) =>   return Err("CStr::from_ptr(pem).to_str() error".to_string())
    };
    // Before we reach here, Webpki already verifed the cert is properly signed

    // Search for Public Key prime256v1 OID
    let prime256v1_oid = &[0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07];
    let mut offset = match cert_der
        .windows(prime256v1_oid.len())
        .position(|window| window == prime256v1_oid)
    {
        Some(offset) => offset,
        None => return Err("not contains prime256v1_oid".to_string())
    };
    offset += 11; // 10 + TAG (0x03)

    // Obtain Public Key length
    let mut len = cert_der[offset] as usize;
    if len > 0x80 {
        len = (cert_der[offset + 1] as usize) * 0x100 + (cert_der[offset + 2] as usize);
        offset += 2;
    }

    // Obtain Public Key
    offset += 1;
    let pub_k = cert_der[offset + 2..offset + len].to_vec(); // skip "00 04"

    // Search for Netscape Comment OID
    let ns_cmt_oid = &[
        0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x86, 0xF8, 0x42, 0x01, 0x0D,
    ];
    let mut offset = match cert_der
        .windows(ns_cmt_oid.len())
        .position(|window| window == ns_cmt_oid)
    {
        Some(offset) => offset,
        None => return Err("not contains ns_cmt_oid".to_string())
    };
    offset += 12; // 11 + TAG (0x04)

    // Obtain Netscape Comment length
    let mut len = cert_der[offset] as usize;
    if len > 0x80 {
        len = (cert_der[offset + 1] as usize) * 0x100 + (cert_der[offset + 2] as usize);
        offset += 2;
    }

    // Obtain Netscape Comment
    offset += 1;
    let payload = cert_der[offset..offset + len].to_vec();

    // Extract each field
    let mut iter = payload.split(|x| *x == 0x7C);
    let attn_report_raw = match iter.next() {
        Some(attn_report_raw) => attn_report_raw,
        None => return Err("iter attn_report_raw error".to_string())
    };
    let sig_raw = match iter.next() {
        Some(sig_raw) => sig_raw,
        None => return Err("iter sig_raw error".to_string())
    };
    let sig = match base64::decode(&sig_raw) {
        Ok(sig) => sig,
        Err(_) => return Err("base64::decode error".to_string())
    };

    let sig_cert_raw = match iter.next() {
        Some(sig_cert_raw) => sig_cert_raw,
        None => return Err("iter sig_cert_raw error".to_string())
    };
    let sig_cert_dec = match base64::decode_config(&sig_cert_raw, base64::MIME) {
        Ok(sig_cert_dec) => sig_cert_dec,
        Err(_) => return Err("base64::decode_config error".to_string())
    };
    let sig_cert = match webpki::EndEntityCert::from(&sig_cert_dec) {
        Ok(sig_cert) => sig_cert,
        Err(_) => return Err("Bad DER".to_string())
    };

    // Load Intel CA

    let mut ias_ca_stripped = IAS_REPORT_CA.to_vec();
    ias_ca_stripped.retain(|&x| x != 0x0d && x != 0x0a);
    let head_len = "-----BEGIN CERTIFICATE-----".len();
    let tail_len = "-----END CERTIFICATE-----".len();
    let full_len = ias_ca_stripped.len();
    let ias_ca_core: &[u8] = &ias_ca_stripped[head_len..full_len - tail_len];
    let ias_cert_dec = match base64::decode_config(ias_ca_core, base64::MIME) {
        Ok(ias_cert_dec) => ias_cert_dec,
        Err(_) => return Err("base64::decode_config error".to_string())
    };

    let mut ca_reader = BufReader::new(&IAS_REPORT_CA[..]);

    let mut root_store = rustls::RootCertStore::empty();
    if let Err(_) = root_store.add_pem_file(&mut ca_reader) {
        return Err("Failed to add CA".to_string());
    }

    let trust_anchors: Vec<webpki::TrustAnchor> = root_store
        .roots
        .iter()
        .map(|cert| cert.to_trust_anchor())
        .collect();

    let mut chain: Vec<&[u8]> = Vec::new();
    chain.push(&ias_cert_dec);

    let now_func = match webpki::Time::try_from(SystemTime::now()) {
        Ok(now_func) => now_func,
        Err(_) => return Err("now_func error".to_string())
    };

    match sig_cert.verify_is_valid_tls_server_cert(
        SUPPORTED_SIG_ALGS,
        &webpki::TLSServerTrustAnchors(&trust_anchors),
        &chain,
        now_func,
    ) {
        Ok(_) => println!("Cert is good"),
        Err(e) => return Err(format!("Cert verification error {:?}", e)),
    }

    // Verify the signature against the signing cert
    match sig_cert.verify_signature(&webpki::RSA_PKCS1_2048_8192_SHA256, &attn_report_raw, &sig) {
        Ok(_) => println!("Signature good"),
        Err(e) => return Err(format!("Signature verification error {:?}", e))
    }

    // Verify attestation report
    // 1. Check timestamp is within 24H
    let attn_report: Value = match serde_json::from_slice(attn_report_raw) {
        Ok(attn_report) => attn_report,
        Err(_) => return Err("serde_json::from_slice(attn_report_raw) error".to_string())
    };
    if let Value::String(time) = &attn_report["timestamp"] {
        let time_fixed = time.clone() + "+0000";
        let ts = match DateTime::parse_from_str(&time_fixed, "%Y-%m-%dT%H:%M:%S%.f%z") {
            Ok(dt) => dt,
            Err(_) => return Err("DateTime::parse_from_str(&time_fixed) error".to_string())
        }
            .timestamp();
        let now = match SystemTime::now()
            .duration_since(UNIX_EPOCH) {
            Ok(dr) => dr,
            Err(_) => return Err("SystemTime::now().duration_since(UNIX_EPOCH) error".to_string())
        }
            .as_secs() as i64;
        println!("Time diff = {}", now - ts);
    } else {
        println!("Failed to fetch timestamp from attestation report");
        return Err(sgx_status_t::SGX_ERROR_UNEXPECTED.as_str().to_string());
    }

    // 2. Verify quote status (mandatory field)
    if let Value::String(quote_status) = &attn_report["isvEnclaveQuoteStatus"] {
        println!("isvEnclaveQuoteStatus = {}", quote_status);
        match quote_status.as_ref() {
            "OK" => (),
            "GROUP_OUT_OF_DATE" | "GROUP_REVOKED" | "CONFIGURATION_NEEDED" => {
                // Verify platformInfoBlob for further info if status not OK
                if let Value::String(pib) = &attn_report["platformInfoBlob"] {
                    let got_pib = platform_info::from_str(&pib);
                    println!("{:?}", got_pib);
                } else {
                    println!("Failed to fetch platformInfoBlob from attestation report");
                    return Err(sgx_status_t::SGX_ERROR_UNEXPECTED.as_str().to_string());
                }
            }
            _ => return Err(sgx_status_t::SGX_ERROR_UNEXPECTED.as_str().to_string()),
        }
    } else {
        println!("Failed to fetch isvEnclaveQuoteStatus from attestation report");
        return Err(sgx_status_t::SGX_ERROR_UNEXPECTED.as_str().to_string());
    }

    // 3. Verify quote body
    if let Value::String(quote_raw) = &attn_report["isvEnclaveQuoteBody"] {
        let quote = match base64::decode(&quote_raw) {
            Ok(quote) => quote,
            Err(_) => return Err("base64::decode(&quote_raw) error".to_string())
        };
        println!("Quote = {:?}", quote);
        // TODO: lack security check here
        let sgx_quote: sgx_quote_t = unsafe { ptr::read(quote.as_ptr() as *const _) };
        let report_body = ReportBody {
            version: sgx_quote.version,
            sign_type: sgx_quote.sign_type,
            report_data: sgx_quote.report_body.report_data.d.to_vec(),
            mr_enclave: sgx_quote.report_body.mr_enclave.m.to_vec(),
            mr_signer: sgx_quote.report_body.mr_signer.m.to_vec(),
            pub_key: pub_k.clone()
        };


        // Borrow of packed field is unsafe in future Rust releases
        // ATTENTION
        // DO SECURITY CHECK ON DEMAND
        // DO SECURITY CHECK ON DEMAND
        // DO SECURITY CHECK ON DEMAND
        unsafe {
            println!("sgx quote version = {}", sgx_quote.version);
            println!("sgx quote signature type = {}", sgx_quote.sign_type);
            println!(
                "sgx quote report_data = {:02x}",
                sgx_quote.report_body.report_data.d.iter().format("")
            );
            println!(
                "sgx quote mr_enclave = {:02x}",
                sgx_quote.report_body.mr_enclave.m.iter().format("")
            );
            println!(
                "sgx quote mr_signer = {:02x}",
                sgx_quote.report_body.mr_signer.m.iter().format("")
            );
        }
        println!("Anticipated public key = {:02x}", pub_k.iter().format(""));
        if sgx_quote.report_body.report_data.d.to_vec() == pub_k.to_vec() {
            println!("ue RA done!");
        } else {
            return Err("pubkey invalid".to_string());
        }

        Ok(report_body)
    } else {
        println!("Failed to fetch isvEnclaveQuoteBody from attestation report");
        Err(sgx_status_t::SGX_ERROR_UNEXPECTED.as_str().to_string())
    }
}

#[no_mangle]
pub extern fn rust_cstr_free(s: *mut c_char) {
    unsafe {
        if s.is_null() { return }
        CString::from_raw(s)
    };
}