import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/configs/app_route.dart';
import 'package:ejavapedia/pages/categories/dance_page.dart';
import 'package:ejavapedia/pages/categories/food_page.dart';
import 'package:ejavapedia/pages/categories/travel_page.dart';
import 'package:ejavapedia/pages/main/bookmark_page.dart';
import 'package:ejavapedia/pages/main/home_page.dart';
import 'package:ejavapedia/pages/main/main_page.dart';
import 'package:ejavapedia/pages/intro_page.dart';
import 'package:ejavapedia/pages/user/login_page.dart';
import 'package:ejavapedia/pages/main/profile_page.dart';
import 'package:ejavapedia/pages/user/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(),
        scaffoldBackgroundColor: AppColors.bgScaffold,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      routes: {
        '/': (context) {
          return FutureBuilder(builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const IntroPage();
            } else {
              return MainPage();
            }
          });
        },
        AppRoute.intro: (context) => const IntroPage(),
        AppRoute.bookmark: (context) => const BookmarkPage(),
        AppRoute.main: (context) => MainPage(),
        AppRoute.home: (context) => const HomePage(),
        AppRoute.login: (context) => const LoginPage(),
        AppRoute.signup: (context) => const SignupPage(),
        AppRoute.profile: (context) => const ProfilePage(),
        AppRoute.food: (context) => const FoodPage(),
        AppRoute.travel: (context) => const TravelPage(),
        AppRoute.dance: (context) => const DancePage(),
      },
    );
  }
}
