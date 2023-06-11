import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<String?> getToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final expirationTime = prefs.getInt('tokenExpiration');

    if (token != null && expirationTime != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentTime < expirationTime) {
        return token;
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sesi Login Kadaluwarsa'),
              content: const Text('Mohon lakukan login ulang'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      await performLogout();
      return null;
    }
    return null;
  }

  static Future<void> performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
