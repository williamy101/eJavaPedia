import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/configs/app_route.dart';
import 'package:ejavapedia/widgets/button_custom.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.bgIntro,
            fit: BoxFit.cover,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'eJavaPedia',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sumber Pengetahuan mengenai budaya\nJawa Timur Terkini',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 40),
                ButtonCustom(
                  label: 'Log in',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoute.login);
                  },
                  isExpand: true,
                ),
                const SizedBox(height: 15),
                ButtonCustom(
                  label: 'Sign Up',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoute.signup);
                  },
                  isExpand: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}