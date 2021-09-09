import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:pem/pem.dart';

import './sgx_client_error.dart';
import './utils.dart';
import './model.dart';

class SgxVerify {
  static bool sgxVerify(X509Certificate cert, String host, int port) {
    print(cert.pem);
    print(cert.der);
    final keydata = PemCodec(PemLabel.certificate).decode(cert.pem);

    final result = parseCert(keydata as Uint8List);

    final pubKey = result[0];
    final payload = result[1];

    return true;
  }

  static List verifyCert(List<int> payload) {
    // Extract each field
    final plSplit = payload.split(0x7C);
    final attnReportRaw = plSplit[0];
    final sigRaw = plSplit[1];

    late Uint8List sig, sigCertDec;
    final sigRawString = utf8.decode(sigRaw);
    sig = base64Decode(sigRawString);

    final sigCertRaw = plSplit[2];
    sigCertDec = base64Decode(sigCertRaw);

    final dir =
        "/home/stone/Rust/incubator-teaclave-sgx-sdk/samplecode/ue-ra/cert";
    final cacert =
        File(dir + '/AttestationReportSigningCACert.pem').readAsStringSync();

    // final certServer = x509.parsePem(sigCertDec).first;
    final keydata = PemCodec(PemLabel.certificate).decode(cacert);
    final result = parseCert(keydata as Uint8List);
    final pubKey = result[0];

    return attnReportRaw;
  }

  static verifyAttestReport(Uint8List attestRep, Uint8List publicKey) {
    final attesString = utf8.decode(attestRep);
    final qr = QuoteReport.fromJson(attesString);
    if (qr.timestamp != "") {
//timeFixed := qr.Timestamp + "+0000"
      final timeFixed = qr.timestamp + "Z";
      // final ts = DateTime.Parse(time.RFC3339, timeFixed);
      final now = DateTime.now().millisecondsSinceEpoch;
      print("Time diff = ");
    } else {
      throw SgxClientError("Failed to fetch timestamp from attestation report");
    }
  }

  static parseCert(Uint8List rawbyte) {
    final prime256v1Oid = [
      0x06,
      0x08,
      0x2A,
      0x86,
      0x48,
      0xCE,
      0x3D,
      0x03,
      0x01,
      0x07
    ];
    Function eq = const ListEquality().equals;

    int? offset;
    for (var i = 0; i < rawbyte.length - 10; i++) {
      if (eq(rawbyte.sublist(i, i + 10), prime256v1Oid)) {
        offset = i;
        break;
      }
    }

    if (offset == null) {
      throw SgxClientError('Parse error');
    }

    offset += 11;

    // Obtain Public Key length
    var length = rawbyte[offset];
    if (length > 0x80) {
      length = rawbyte[offset + 1] * 0x100 + rawbyte[offset + 2];
      offset += 2;
    }
    // Obtain Public Key
    offset += 1;

    final pubKey = rawbyte.sublist(offset + 2, offset + length); // skip "00 04"
    // Search for Netscape Comment OID
    final nsCmtOid = [
      0x06,
      0x09,
      0x60,
      0x86,
      0x48,
      0x01,
      0x86,
      0xF8,
      0x42,
      0x01,
      0x0D
    ];

    offset = null;
    for (var i = 0; i < rawbyte.length - 10; i++) {
      if (eq(rawbyte.sublist(i, i + 10), nsCmtOid)) {
        offset = i;
        break;
      }
    }

    if (offset == null) {
      throw SgxClientError('Parse error');
    }
    offset += 12; // 11 + TAG (0x04)

    // Obtain Netscape Comment length
    length = rawbyte[offset];
    if (length > 0x80) {
      length = rawbyte[offset + 1] * 0x100 + rawbyte[offset + 2];
      offset += 2;
    }

    // Obtain Netscape Comment
    offset += 1;
    final payload = rawbyte.sublist(offset, offset + length);
    return [pubKey, payload];
  }
}
