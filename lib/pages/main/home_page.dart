import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../configs/app_route.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = '';
  List<dynamic> searchResults = [];

  Future<List<dynamic>> fetchDataFromEndpoint(String endpoint,
      {String query = ''}) async {
    final url = Uri.parse(
        '$endpoint?q=$query'); // Replace 'ID' with the actual parameter name for ID
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to fetch data from $endpoint');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(top: 160),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jelajahi budaya Jawa Timur...',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 23,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Card(
                              child: InkWell(
                                splashColor: AppColors.primary,
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoute.food);
                                },
                                child: SizedBox(
                                  width: screenWidth,
                                  child: Image.asset(
                                    AppAssets.foodCategory,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Kuliner Jawa Timur',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Card(
                                        child: InkWell(
                                          splashColor: AppColors.primary,
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, AppRoute.dance);
                                          },
                                          child: SizedBox(
                                            child: Image.asset(
                                              AppAssets.danceCategory,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Tarian Jawa Timur',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Card(
                                        child: InkWell(
                                          splashColor: AppColors.primary,
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, AppRoute.travel);
                                          },
                                          child: SizedBox(
                                            child: Image.asset(
                                              AppAssets.travelCategory,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Wisata Jawa Timur',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selamat Datang',
                    style: Theme.of(context).textTheme.headline3!.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              searchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          height: 45,
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
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
            ),
          ),
        ),
        if (searchResults != null)
          Positioned(
            top: 45,
            left: 0,
            right: 0,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return ListTile(
                    title: Text(result['title']),
                    // Display other relevant data from the result
                    onTap: () {
                      // Handle tile tap event here, e.g., navigate to details page
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void performSearch(String query) async {
    const endpoint1 =
        'https://192.168.100.8:8888/eJavaPedia/Get?type=Wisata&ID=';
    const endpoint2 =
        'https://192.168.100.8:8888/eJavaPedia/Get?type=Makanan&ID=';
    const endpoint3 =
        'https://192.168.100.8:8888/eJavaPedia/Get?type=Tarian&ID=';

    final results1 = await fetchDataFromEndpoint('$endpoint1&ID=$query');
    final results2 = await fetchDataFromEndpoint('$endpoint2&ID=$query');
    final results3 = await fetchDataFromEndpoint('$endpoint3&ID=$query');

    setState(() {
      searchResults = [...results1, ...results2, ...results3];
    });
  }
}
