/// bindings for `libtkms`

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart' as ffi;

// ignore_for_file: unused_import, camel_case_types, non_constant_identifier_names
final DynamicLibrary _dl = _open();
/// Reference to the Dynamic Library, it should be only used for low-level access
final DynamicLibrary dl = _dl;
DynamicLibrary _open() {
  if (Platform.isAndroid) return DynamicLibrary.open('libverify_mra_cert.so');
  if (Platform.isIOS) return DynamicLibrary.executable();
  throw UnsupportedError('This platform is not supported.');
}

/// C function `rust_cstr_free`.
void rust_cstr_free(
  Pointer<ffi.Utf8> s,
) {
  _rust_cstr_free(s);
}
final _rust_cstr_free_Dart _rust_cstr_free = _dl.lookupFunction<_rust_cstr_free_C, _rust_cstr_free_Dart>('rust_cstr_free');
typedef _rust_cstr_free_C = Void Function(
  Pointer<ffi.Utf8> s,
);
typedef _rust_cstr_free_Dart = void Function(
  Pointer<ffi.Utf8> s,
);

/// C function `verify_mra_cert`.
Pointer<ffi.Utf8> verify_mra_cert(
  Pointer<ffi.Utf8> pem,
  int now,
) {
  return _verify_mra_cert(pem, now);
}
final _verify_mra_cert_Dart _verify_mra_cert = _dl.lookupFunction<_verify_mra_cert_C, _verify_mra_cert_Dart>('verify_mra_cert');
typedef _verify_mra_cert_C = Pointer<ffi.Utf8> Function(
  Pointer<ffi.Utf8> pem,
  Uint64 now,
);
typedef _verify_mra_cert_Dart = Pointer<ffi.Utf8> Function(
  Pointer<ffi.Utf8> pem,
  int now,
);
