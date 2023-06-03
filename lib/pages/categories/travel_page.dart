import 'dart:convert';

import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/configs/app_route.dart';
import 'package:ejavapedia/pages/categories/details_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TravelPage extends StatefulWidget {
  const TravelPage({Key? key}) : super(key: key);

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class SearchService {
  static Future<List<Map<String, dynamic>>> searchItems(String query) async {
    final url = Uri.parse(
        'http://192.168.100.8:8888/eJavaPedia/Get?category=Wisata&name=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      data.sort((a, b) => a['Nama'].compareTo(b['Nama']));
      return data
          .map((item) => {
                'id': item['ID'],
                'name': item['Nama'],
                'imageUrl': item['Pic'],
              })
          .toList();
    } else {
      throw Exception('Failed to fetch items: ${response.statusCode}');
    }
  }
}

class _TravelPageState extends State<TravelPage> {
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchSearchResults('');
  }

  void _fetchSearchResults(String query) async {
    try {
      List<Map<String, dynamic>> results =
          await SearchService.searchItems(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error fetching search results: $e');
    }
  }

  void _performSearch(String query) {
    _fetchSearchResults(query);
  }

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.only(top: 160, left: 16, right: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1.4,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return Card(
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.formBorder),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(
                            type: 'Wisata',
                            id: item['id'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Hero(
                          tag: 'item_${item['id']}',
                          child: Image.network(
                            item['imageUrl'],
                            height: 190,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w200,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            header(context),
          ],
        ),
      ),
    );
  }

  Positioned header(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 24.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoute.main);
                    },
                    child: Image.asset(
                      AppAssets.iconBack,
                      width: 25,
                      height: 25,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Wisata',
                    style: Theme.of(context).textTheme.headline3!.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              searchBar()
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
      ),
      height: 45,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Cari...',
                hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
