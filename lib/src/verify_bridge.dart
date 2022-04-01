import 'dart:convert';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:hex/hex.dart';

import 'package:sgx_client/src/ffi/ffi.dart';
import 'sgx_client_error.dart';

class VerifyBridge {
  static bool verify(X509Certificate cert) {
    final res = verify_mra_cert(HEX.encode(cert.der).toNativeUtf8(),
            DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .cast<Utf8>()
        .toDartString();

    _free(res);
    final result = jsonDecode(res);
    if (result['result'] == 'Success') {
      return true;
    } else {
      throw SgxClientError(result['result']);
    }
  }

  static void _free(String value) {
    final ptr = value.toNativeUtf8().cast<Utf8>();
    return rust_cstr_free(ptr);
  }
}
