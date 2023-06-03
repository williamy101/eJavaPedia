import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/controllers/c_main.dart';
import 'package:ejavapedia/pages/main/bookmark_page.dart';
import 'package:ejavapedia/pages/main/home_page.dart';
import 'package:ejavapedia/pages/main/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);
  final cMain = Get.put(CMain());
  final List<Map> listNav = [
    {'icon': AppAssets.iconHome, 'label': 'Home'},
    {'icon': AppAssets.iconBookmark, 'label': 'Bookmark'},
    {'icon': AppAssets.iconProfile, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (cMain.indexPage == 1) {
          return const BookmarkPage();
        } else if (cMain.indexPage == 2) {
          return const ProfilePage();
        } else {
          return const HomePage();
        }
      }),
      bottomNavigationBar: Obx(() {
        return Material(
          elevation: 8,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 5, bottom: 8),
            child: BottomNavigationBar(
              currentIndex: cMain.indexPage,
              onTap: (value) => cMain.indexPage = value,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: Colors.black,
              selectedItemColor: Colors.black,
              selectedIconTheme: const IconThemeData(
                color: AppColors.primary,
              ),
              backgroundColor: Colors.white,
              items: listNav.map((e) {
                return BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage(e['icon'])),
                  label: e['label'],
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
