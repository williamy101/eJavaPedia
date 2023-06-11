import 'dart:convert';

import 'package:ejavapedia/auth_service.dart';
import 'package:ejavapedia/configs/app_route.dart';
import 'package:ejavapedia/widgets/button_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> dataList = [];

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('dataList');
    // ignore: avoid_print
    print('jsonData: $jsonData');
    if (jsonData != null) {
      try {
        Map<String, dynamic> dataMap =
            jsonDecode(jsonData) as Map<String, dynamic>;
        setState(() {
          dataList = [dataMap];
        });
        // ignore: avoid_print
        print('Decoded dataList: $dataList');
      } catch (e) {
        // ignore: avoid_print
        print('Error decoding dataList: $e');
      }
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () async {
                await AuthService.performLogout();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, AppRoute.login);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Berhasil keluar"),
                  behavior: SnackBarBehavior.floating,
                ));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: ((context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Profil',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildProfileDataItem(
                        label: 'Nama',
                        value: dataList.isNotEmpty
                            ? dataList[0]['account_nama']
                            : '',
                      ),
                      const SizedBox(height: 20),
                      _buildProfileDataItem(
                        label: 'Tanggal Lahir',
                        value: dataList.isNotEmpty
                            ? dataList[0]['account_dob']
                            : '',
                      ),
                      const SizedBox(height: 20),
                      _buildProfileDataItem(
                        label: 'Email',
                        value: dataList.isNotEmpty
                            ? dataList[0]['account_email']
                            : '',
                      ),
                      const SizedBox(height: 20),
                      ButtonCustom(
                          label: 'Keluar',
                          onTap: () {
                            _showConfirmationDialog(context);
                          }),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileDataItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
