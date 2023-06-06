import 'dart:convert';
import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/pages/categories/maps_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Map<String, dynamic>> bookmarkData = [];
  String selectedFilter = '';

  Future<void> getBookmarkData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('bookmarkData');
    if (jsonData != null) {
      setState(() {
        bookmarkData = List<Map<String, dynamic>>.from(
          jsonDecode(jsonData) as List<dynamic>,
        );
      });
    }
  }

  Future<void> updateBookmarkData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookmarkData', jsonEncode(bookmarkData));
  }

  void showFilterPopupMenu(BuildContext context) async {
    final selectedValue = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, 30, 0, 0),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: '',
          child: Text('All'),
        ),
        const PopupMenuItem<String>(
          value: 'Makanan',
          child: Text('Makanan'),
        ),
        const PopupMenuItem<String>(
          value: 'Wisata',
          child: Text('Wisata'),
        ),
      ],
      elevation: 8,
    );

    if (selectedValue != null) {
      setState(() {
        selectedFilter = selectedValue;
      });
    }
  }

  Future<void> deleteAllBookmarks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accountId = prefs.getString('accountId');

      final url =
          Uri.parse('http://192.168.100.8:8888/eJavaPedia/DeleteBookmark');

      final payload = {
        'account_id': accountId,
        'data': bookmarkData.map((data) {
          return {
            'kategori': data['kategori'],
            'nama': data['nama'],
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'alamat': data['alamat'],
            'rating': data['rating'],
            'pic': data['pic'],
          };
        }).toList(),
      };

      final response = await http.delete(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          bookmarkData.clear();
        });
        await updateBookmarkData();
      } else {
        throw Exception(
            'Delete failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error calling API: $error');
      throw Exception('Error calling API');
    }
  }

  Future<void> deleteBookmark(int index) async {
    final data = bookmarkData[index];

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accountId = prefs.getString('accountId');

      final url =
          Uri.parse('http://192.168.100.8:8888/eJavaPedia/DeleteBookmark');

      final payload = {
        'account_id': accountId,
        'data': [
          {
            'kategori': data['kategori'],
            'nama': data['nama'],
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'alamat': data['alamat'],
            'rating': data['rating'],
            'pic': data['pic'],
          },
        ],
      };

      final response = await http.delete(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          bookmarkData.removeAt(index);
        });
        await updateBookmarkData();
      } else {
        throw Exception(
            'Delete failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error calling API: $error');
      throw Exception('Error calling API');
    }
  }

  String getFilterIcon() {
    if (selectedFilter == 'Makanan') {
      return 'assets/icon_food.png';
    } else if (selectedFilter == 'Wisata') {
      return 'assets/icon_travel.png';
    } else {
      return 'assets/icon_filter.png';
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content:
              const Text('Apakah Anda yakin ingin menghapus semua bookmark?'),
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
                deleteAllBookmarks();
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
  void initState() {
    super.initState();
    getBookmarkData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          getFilterIcon(),
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        showFilterPopupMenu(context);
                      },
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Favorit',
                          style:
                              Theme.of(context).textTheme.headline4!.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                    ),
                    InkWell(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          AppAssets.iconDelete,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        _showConfirmationDialog(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: bookmarkData.length,
                  itemBuilder: (context, index) {
                    final data = bookmarkData[index];
                    final imageUrl =
                        '${data['pic']}&key=AIzaSyD9c4q9V2BvqbvfgR9z6mbulvvfwWxoVeM';

                    if (selectedFilter.isNotEmpty &&
                        data['kategori'] != selectedFilter) {
                      return Container();
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Konfirmasi"),
                                content: const Text(
                                    "Apakah Anda yakin ingin menghapus item ini?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Tidak"),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("Ya"),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            deleteBookmark(index);
                          }
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapsPage(
                                  nama: data['nama'],
                                  type: data['kategori'],
                                  latitude: data['latitude'],
                                  longitude: data['longitude'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: SizedBox(
                                      width: 100,
                                      height: 120,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['nama'],
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          Text(
                                            data['kategori'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['rating'],
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 35,
                                                child: Image.asset(
                                                  AppAssets.iconStar,
                                                  color: Colors.yellow,
                                                  height: 20,
                                                  width: 20,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
