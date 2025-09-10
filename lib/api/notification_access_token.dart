import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async => _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      // 1. Load the JSON file from assets
      final jsonString =
          await rootBundle.loadString('secrets/service-account-key.json');

      // 2. Decode the JSON string into a Map
      final credentialsJson = jsonDecode(jsonString);

      final client = await clientViaServiceAccount(
        // 3. Pass the decoded credentials to fromJson
        ServiceAccountCredentials.fromJson(credentialsJson),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}