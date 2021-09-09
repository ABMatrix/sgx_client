import 'dart:ffi';

import 'dart:io';

typedef VerifyCertType = Void Function();
typedef VerifyCertFunc = void Function();

class VerifyBridge {
  static DynamicLibrary? _lib;
  static late final VerifyCertFunc _verifyCert;

  static void _loadLib() {
    _lib = _open();
    _verifyCert =
        _lib!.lookup<NativeFunction<Void Function()>>("connect").asFunction();
  }

  static bool verify(X509Certificate  cert) {
    if(_lib == null) {
      _loadLib();
    }
    final result =  _verifyCert();
    
    return true;
  }

  static DynamicLibrary _open() {
    if (Platform.isAndroid) return DynamicLibrary.open('libadder_ffi.so');
    if (Platform.isIOS) return DynamicLibrary.executable();
    throw UnsupportedError('This platform is not supported.');
  }
}

