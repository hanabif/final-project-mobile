import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureAdapter(Dio dio) {
  if (dio.httpClientAdapter is IOHttpClientAdapter) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }
}
