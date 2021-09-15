import 'dart:developer';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

import 'verify_bridge.dart';

class SgxClient {
  static final Dio dio = Dio(BaseOptions(
    receiveTimeout: 30000,
    connectTimeout: 30000,
    headers: {'Connection': 'close'}
  ));

  static init() async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      SecurityContext sc = SecurityContext(withTrustedRoots: false);
      HttpClient httpClient = HttpClient(context: sc)
        ..badCertificateCallback =
            (X509Certificate cert, String name, int port) {
          try {
            final result = VerifyBridge.verify(cert);
            return result;
          } catch (e) {
            log(e.toString());
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

  static Future postJson(String url, [Map<String, dynamic>? data]) async {
    var response = await dio.post(url, data: data);
    return response.data;
  }

  static Future post(String url, [Map<String, dynamic>? params]) async {
    var response = await dio.post(url, queryParameters: params);
    return response.data;
  }

  static Future put(String url,
      [Map<String, dynamic>? data]) async {
    var response = await dio.put(url, queryParameters: data);
    return response.data;
  }

  ///put body请求
  static Future putJson(String url,
      [Map<String, dynamic>? data]) async {
    var response = await dio.put(url, data: data);
    return response.data;
  }
}
