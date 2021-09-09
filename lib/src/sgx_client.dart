import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'verify_bridge.dart';

class SgxService {
  static final Dio dio = Dio(BaseOptions(
    receiveTimeout: 30000,
    connectTimeout: 30000,
  ));

  static init(String baseUrl) async {
    final cert = await rootBundle.loadString('assets/cert/AttestationReportSigningCACert.pem');
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      SecurityContext sc = SecurityContext(withTrustedRoots: true)..setTrustedCertificatesBytes(utf8.encode(cert));
      HttpClient httpClient = HttpClient(context: sc)
        ..badCertificateCallback = (X509Certificate cert, String name, int port) {
          try{
            final result = VerifyBridge.verify(cert);
            return result;
          } catch(e) {
            return false;
          }
        };
      return httpClient;
    };
  }

  static Future get(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.get(url, queryParameters: params);
    } else {
      response = await dio.get(url);
    }
    if (response.data != null) return response.data;
  }
}
