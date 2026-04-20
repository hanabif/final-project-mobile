import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../utils/navigator_key.dart';
import '../routes/route_names.dart';

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void initialize() {
    // 1. Handle links when app is already open
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // 2. Handle links that opened the app
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Incoming Deep Link: $uri');
    
    // Check if it's our reset-password link
    // cityvoice://reset-password?token=XYZ&email=ABC
    if (uri.scheme == 'cityvoice' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];

      if (token != null && email != null) {
        navigatorKey.currentState?.pushNamed(
          RouteNames.resetPassword,
          arguments: {
            'token': token,
            'email': email,
          },
        );
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
