import 'dart:ffi';
import 'dart:io';
import 'dart:developer';

import 'package:ffi/ffi.dart';
import 'package:hex/hex.dart';

import 'sgx_client_error.dart';

typedef VerifyCertType = Pointer<Utf8> Function(Pointer<Utf8>);
typedef VerifyCertFunc = Pointer<Utf8> Function(Pointer<Utf8>);

class VerifyBridge {
  static DynamicLibrary? _lib;
  static late final VerifyCertFunc _verifyCert;

  static void _loadLib() {
    _lib = _open();
    _verifyCert = _lib!
        .lookup<NativeFunction<VerifyCertType>>("verify_mra_cert")
        .asFunction();
  }

  static bool verify(X509Certificate cert) {
    if (_lib == null) {
      _loadLib();
    }

    final result = _verifyCert(HEX.encode(cert.der).toNativeUtf8().cast<Utf8>())
        .toDartString();

    log(result);
    if (result == 'Success') {
      return true;
    } else {
      throw SgxClientError(result);
    }
  }

  static DynamicLibrary _open() {
    if (Platform.isAndroid) return DynamicLibrary.open('libverify_mra_cert.so');
    if (Platform.isIOS) return DynamicLibrary.executable();
    throw UnsupportedError('This platform is not supported.');
  }
}
