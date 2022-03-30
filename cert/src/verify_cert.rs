use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::prelude::v1::*;
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct VerifyResult {
    pub result: String,
    pub report_body: ReportBody
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ReportBody {
    pub version: u16,
    pub sign_type: u16,
    pub report_data: Vec<u8>,
    pub mr_enclave: Vec<u8>,
    pub mr_signer: Vec<u8>,
    pub pub_key: Vec<u8>
}

impl From<tra::EnclaveFields> for ReportBody {
    fn from(o: tra::EnclaveFields) -> Self {
        ReportBody {
            version: o.version,
            sign_type: o.sign_type,
            report_data: o.report_data.clone(),
            mr_enclave: o.mr_enclave,
            mr_signer: o.mr_signer,
            pub_key: o.report_data,
        }
    }
}
#[no_mangle]
pub extern "C" fn verify_mra_cert(pem: *const c_char, now: u64) -> *const c_char {
    let s: &CStr = unsafe { CStr::from_ptr(pem) };
    let res = match tra::verify_cert(s.to_bytes(), now) {
        Ok(report_body) => VerifyResult {
            result: "Success".to_string(),
            report_body: report_body.into()
        },
        Err(e) => VerifyResult {
            result: format!("{:?}", e),
            report_body: ReportBody::default()
        }
    };
    let c_str_song = match serde_json::to_string(&res) {
        Ok(res_string) => CString::new(res_string.as_str()).unwrap(),
        Err(_) => CString::new("Serialize failed").unwrap()
    };
    c_str_song.into_raw()
}

#[no_mangle]
pub extern fn rust_cstr_free(s: *mut c_char) {
    unsafe {
        if s.is_null() { return }
        CString::from_raw(s)
    };
}