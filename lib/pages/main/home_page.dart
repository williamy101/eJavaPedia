import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/pages/categories/culture_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(top: 150),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jelajahi...',
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CulturePage(
                                                  category_name: 'Makanan')));
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
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CulturePage(
                                                            category_name:
                                                                'Tarian')));
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
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CulturePage(
                                                            category_name:
                                                                'Wisata')));
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
                    'Selamat Datang,',
                    style: Theme.of(context).textTheme.headline3!.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'di eJavaPedia',
                  style: Theme.of(context).textTheme.headline3!.copyWith(
                        color: AppColors.bgScaffold,
                        fontWeight: FontWeight.w400,
                        fontSize: 28,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
