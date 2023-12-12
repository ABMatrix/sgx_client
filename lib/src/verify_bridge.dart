import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:hex/hex.dart';

import 'bindings.dart';
import 'sgx_client_error.dart';

class VerifyBridge {
  static DynamicLibrary? _lib;

  static void _loadLib() {
    _lib = _open();
  }

  static bool verify(X509Certificate cert) {
    if (_lib == null) {
      _loadLib();
    }
    final res = VerifyBindings(_lib!)
        .verifyMraCert(HEX.encode(cert.der).toNativeUtf8().cast<Int8>())
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

  static DynamicLibrary _open() {
    if (Platform.isAndroid) return DynamicLibrary.open('libverify_mra_cert.so');
    if (Platform.isIOS) return DynamicLibrary.executable();
    throw UnsupportedError('This platform is not supported.');
  }

  static void _free(String value) {
    final ptr = value.toNativeUtf8().cast<Int8>();
    return VerifyBindings(_lib!).rustCstrFree(ptr);
  }
}
