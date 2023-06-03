import 'dart:convert';
import 'package:ejavapedia/models/model_user.dart';
import 'package:http/http.dart' as http;
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/configs/app_route.dart';
import 'package:ejavapedia/widgets/button_custom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final controllerName = TextEditingController();
  final controllerDoB = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  Future<User> _callApi() async {
    final url = Uri.parse('http://192.168.100.8:8888/eJavaPedia/register');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'account_nama': controllerName.text,
        'account_dob': controllerDoB.text,
        'account_email': controllerEmail.text,
        'account_password': controllerPassword.text,
      }),
    );
    if (response.body.contains('data')) {
      final jsonData = jsonDecode(response.body);
      return User.toJson(jsonData);
    } else {
      throw Exception('Failed to register');
    }
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
                              'Sign Up',
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
                          textCapitalization: TextCapitalization.words,
                          controller: controllerName,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.formColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            hintText: 'Name',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name must be filled!";
                            }
                            return null;
                          }),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: controllerDoB,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.grey,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.formColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          hintText: 'Date of Birth',
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
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              controllerDoB.text =
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Date of birth field must be filled!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
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
                        validator: (value) {
                          final RegExp regex = RegExp(
                            r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d]{8,}$',
                          );
                          if (value == null || !regex.hasMatch(value)) {
                            return 'Password harus berisi paling tidak 8 karakter, 1 huruf kapital, 1 huruf kecil, dan 1 karakter alfanumerik';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 65),
                      ButtonCustom(
                        label: 'Sign Up',
                        isExpand: true,
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            _callApi();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Registrasi Berhasil"),
                              behavior: SnackBarBehavior.floating,
                            ));
                            return Navigator.pushReplacementNamed(
                                context, AppRoute.login);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Registrasi Gagal"),
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
                              context, AppRoute.login);
                        },
                        child: const Text(
                          'Sudah punya akun? Log in!',
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
