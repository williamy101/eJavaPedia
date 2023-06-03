import 'dart:convert';

import 'package:ejavapedia/configs/app_assets.dart';
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

  Future<void> performLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, AppRoute.login);
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('dataList');
    print('jsonData: $jsonData');
    if (jsonData != null) {
      try {
        Map<String, dynamic> dataMap =
            jsonDecode(jsonData) as Map<String, dynamic>;
        setState(() {
          dataList = [dataMap];
        });
        print('Decoded dataList: $dataList');
      } catch (e) {
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
              onPressed: () {
                performLogout(context);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Logout Berhasil"),
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
                          label: 'Logout',
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
