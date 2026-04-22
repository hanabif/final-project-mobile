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

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Incoming Deep Link: $uri');
    
    // 1. Wait for navigator to be ready
    int attempts = 0;
    while (navigatorKey.currentState == null && attempts < 20) {
      debugPrint('Waiting for Navigator... (Attempt ${attempts + 1})');
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (navigatorKey.currentState == null) {
      debugPrint('Navigator not ready after several attempts. Link handling aborted.');
      return;
    }

    // 2. Check if it's our reset-password link
    // Supports:
    // - cityvoice://reset-password
    // - https://ai-complaint-backend-7xc5.onrender.com/reset-password
    // - http://localhost:50510/reset-password (for local web testing)
    
    final host = uri.host;
    final path = uri.path;
    final scheme = uri.scheme;
    
    bool isResetPasswordPath = path.contains('reset-password') || 
                              uri.fragment.contains('reset-password');
    
    bool isAuthorizedHost = host == 'reset-password' || 
                           host == 'ai-complaint-backend-7xc5.onrender.com' || 
                           host == 'localhost' || 
                           host == '127.0.0.1';

    if (isAuthorizedHost && isResetPasswordPath) {
      // For web hash routing, query parameters might be in the fragment
      Map<String, String> params = Map.from(uri.queryParameters);
      if (params.isEmpty && uri.fragment.contains('?')) {
        final fragmentUri = Uri.parse(uri.fragment.substring(uri.fragment.indexOf('/')));
        params = fragmentUri.queryParameters;
      }

      final token = params['token'];
      final email = params['email'];

      if (token != null && email != null) {
        debugPrint('Navigating to Reset Password for: $email');
        navigatorKey.currentState?.pushNamed(
          RouteNames.resetPassword,
          arguments: {
            'token': token,
            'email': email,
          },
        );
      } else {
        debugPrint('Link parsed but missing token or email parameters. Params: $params');
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
