import 'dart:convert';

import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/configs/app_route.dart';
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
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final responseData = jsonDecode(response.body);
    final token = response.headers['authorization'];
    final accountId = responseData['data']['account_id'];
    final bookmarkData = responseData['metadata']['bookmark_data'];

    if (responseData['data'] != null &&
        token != null &&
        accountId != null &&
        responseData['metadata'] != null) {
      print("Login Successful");
      await storeToken(token, accountId);
      await storeUserData(responseData['data']);
      if (bookmarkData != null) {
        final bookmarkDataString = jsonEncode(bookmarkData);
        await storeBookmarkData(bookmarkDataString);
      }
      Navigator.pushReplacementNamed(context, AppRoute.main);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login Berhasil"),
        behavior: SnackBarBehavior.floating,
      ));
    } else if (responseData['data'] == null) {
      throw Exception('Data user tidak ditemukan');
    } else {
      throw Exception('Error Login');
    }
  }

  Future<void> storeToken(String token, String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('accountId', accountId);
    print('Store successful!!!!!');
  }

  Future<void> storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final dataListString = jsonEncode(data);
    await prefs.setString('dataList', dataListString);
    print('Store data successful!!');
  }

  Future<void> storeBookmarkData(String bookmarkData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookmarkData', bookmarkData);
    print('Bookmark Storing Successful');
  }

  Future<String?> getToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                                Navigator.pushNamed(context, AppRoute.intro);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                              )),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Log In',
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
                            return "Email must be filled!";
                          }
                          if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                              .hasMatch(value)) {
                            return 'Email Invalid';
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
                            borderSide:
                                const BorderSide(color: AppColors.secondary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.formBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        validator: (value) {
                          final RegExp regex = RegExp(
                            r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d]{8,}$',
                          );
                          if (value == null || !regex.hasMatch(value)) {
                            return 'Password harus berisi paling tidak 8 karakter, 1 huruf kapital, 1 huruf kecil, dan 1 karakter alfanumerik';
                          }
                          return null;
                        },
                        controller: controllerPassword,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          suffix: GestureDetector(
                            onTap: _togglePassword,
                            child: const Text('Show',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                )),
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
                            borderSide:
                                const BorderSide(color: AppColors.secondary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.formBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 200),
                      ButtonCustom(
                        label: 'Log In',
                        isExpand: true,
                        onTap: () async {
                          if (_formkey.currentState!.validate()) {
                            try {
                              await _callLoginApi();
                              Navigator.pushReplacementNamed(
                                  context, AppRoute.main);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Login Berhasil"),
                                behavior: SnackBarBehavior.floating,
                              ));
                            } catch (e) {
                              print('Login Error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Login Gagal"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text("Pastikan Format Login Sudah Tepat"),
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
                          'Belum punya akun? Sign Up!',
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

  void _togglePassword() {
    if (hidePassword == true) {
      hidePassword = false;
    } else {
      hidePassword = true;
    }
    setState(() {});
  }
}
