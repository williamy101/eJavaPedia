import 'dart:convert';
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/configs/app_route.dart';
import 'package:ejavapedia/pages/main/main_page.dart';
import 'package:ejavapedia/widgets/button_custom.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class ApiError {
  final int statusCode;
  final String message;

  ApiError(this.statusCode, this.message);
}

class _LoginPageState extends State<LoginPage> {
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  bool hidePassword = true;

  Future<void> _callLoginApi() async {
    final url = Uri.parse('http://192.168.100.8:8888/eJavaPedia/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_email': controllerEmail.text,
        'account_password': controllerPassword.text,
      }),
    );
    // ignore: avoid_print
    print('Response status: ${response.statusCode}');
    // ignore: avoid_print
    print('Response body: ${response.body}');

    final responseData = jsonDecode(response.body);
    final token = response.headers['authorization'];
    final accountId = responseData['data']['account_id'];
    final bookmarkData = responseData['metadata']['bookmark_data'];

    if (responseData['data'] != null &&
        token != null &&
        accountId != null &&
        responseData['metadata'] != null) {
      // ignore: avoid_print
      print("Login Successful");
      await storeToken(token, accountId);
      await storeUserData(responseData['data']);
      if (bookmarkData != null) {
        final bookmarkDataString = jsonEncode(bookmarkData);
        await storeBookmarkData(bookmarkDataString);
      }
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, AppRoute.main);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Berhasil masuk"),
        behavior: SnackBarBehavior.floating,
      ));
    } else if (responseData['data'] == null) {
      throw Exception('Data user tidak ditemukan');
    } else {
      throw Exception('Terjadi error saat masuk');
    }
  }

  Future<void> storeToken(String token, String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    final tokenParts = token.split('.');
    if (tokenParts.length == 3) {
      final timer = int.tryParse(tokenParts[2]);
      if (timer != null) {
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final expirationTime = currentTime + timer;
        await prefs.setInt('tokenExpiration', expirationTime);
      }
    }
    await prefs.setString('accountId', accountId);
    // ignore: avoid_print
    print('Store successful!!!!!');
  }

  Future<void> storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final dataListString = jsonEncode(data);
    await prefs.setString('dataList', dataListString);
    // ignore: avoid_print
    print('Store data successful!!');
  }

  Future<void> storeBookmarkData(String bookmarkData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookmarkData', bookmarkData);
    // ignore: avoid_print
    print('Bookmark Storing Successful');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final expirationTime = prefs.getInt('tokenExpiration');
    if (token != null && expirationTime != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentTime < expirationTime) {
        return token;
      }
    }
    return null;
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ignore: prefer_const_constructors
          return CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null) {
          return MainPage();
        } else {
          return Scaffold(
            body: SafeArea(
              child: LayoutBuilder(builder: ((context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AppRoute.intro);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 25,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Masuk',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email harus diisi!";
                                }
                                if (!RegExp(
                                        '^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                                    .hasMatch(value)) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                              controller: controllerEmail,
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: AppColors.formColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                hintText: 'Email',
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.formHint,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.secondary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.formBorder),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password harus diisi!";
                                } else if (value.length < 8) {
                                  return 'Password harus berisi minimum 8 karakter';
                                }
                                return null;
                              },
                              controller: controllerPassword,
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                suffix: GestureDetector(
                                  onTap: _togglePassword,
                                  child: const Text(
                                    'Lihat',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: AppColors.formColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.formHint,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.secondary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.formBorder),
                                ),
                              ),
                            ),
                            const SizedBox(height: 200),
                            ButtonCustom(
                              label: 'Masuk',
                              isExpand: true,
                              onTap: () async {
                                if (_formkey.currentState!.validate()) {
                                  try {
                                    await _callLoginApi();
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushReplacementNamed(
                                        context, AppRoute.main);
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text("Berhasil masuk"),
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  } catch (e) {
                                    // ignore: avoid_print
                                    print('Login Error: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Gagal masuk"),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        "Pastikan Format Login Sudah Tepat"),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 15),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, AppRoute.signup);
                              },
                              child: const Text(
                                'Belum punya akun? Registrasi!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.signInTextButton,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })),
            ),
          );
        }
      },
    );
  }

  void _togglePassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }
}
