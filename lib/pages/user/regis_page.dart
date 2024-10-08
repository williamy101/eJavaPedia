import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/configs/app_route.dart';
import 'package:ejavapedia/widgets/button_custom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final controllerName = TextEditingController();
  final controllerDoB = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;
  bool _isFormValid = false;

  Future<void> registerUser() async {
    final url = Uri.parse('http://192.168.100.203:8888/eJavaPedia/register');
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
      return;
    } else {
      throw Exception('Registrasi gagal');
    }
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  void _validateForm() {
    setState(() {
      _isFormValid = _formkey.currentState?.validate() ?? false;
    });
  }

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
                              'Registrasi',
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
                            hintText: 'Nama',
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
                              return "Nama harus diisi!";
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
                          hintText: 'Tanggal lahir',
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
                            return "Tanggal lahir harus diisi!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email harus diisi!";
                          }
                          if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                              .hasMatch(value)) {
                            return 'Email tidak valid';
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
                            child: const Text('Lihat',
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
                          if (value == null || value.isEmpty) {
                            return "Password harus diisi!";
                          } else if (value.length < 8) {
                            return 'Password harus berisi minimum 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 65),
                      ButtonCustom(
                        label: 'Registrasi',
                        isExpand: true,
                        onTap: () async {
                          _validateForm();
                          if (_isFormValid) {
                            await registerUser();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Berhasil registrasi"),
                              behavior: SnackBarBehavior.floating,
                            ));
                            Navigator.pushReplacementNamed(
                                context, AppRoute.login);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Gagal registrasi"),
                              behavior: SnackBarBehavior.floating,
                            ));
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
                          'Sudah punya akun? Masuk!',
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
