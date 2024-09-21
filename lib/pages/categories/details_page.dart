import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/pages/categories/maps_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailsPage extends StatefulWidget {
  final String category_name;
  final int id;

  // ignore: use_key_in_widget_constructors
  const DetailsPage({required this.category_name, required this.id});

  @override
  // ignore: library_private_types_in_public_api
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Future<Map<String, dynamic>> fetchItemDetails() async {
    final response = await http.get(Uri.parse(
      'http://192.168.100.203:8888/eJavaPedia/Get?type=${widget.category_name}&ID=${widget.id}',
    ));

    if (response.body.contains('data')) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];
      return {
        'item_id': data['ID'],
        'item_name': data['nama'],
        'item_origin': data['asal'],
        'item_overview': data['overview'],
        'item_info': data['more_info'],
        'item_funfact': data['fun_fact'],
        'item_imageUrl': data['pic'],
        'item_vidUrl': data['vid'],
      };
    } else {
      throw Exception('Failed to load item details: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.asset(
                        AppAssets.iconBack,
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.category_name,
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: fetchItemDetails(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Hero(
                                tag: 'item_${widget.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    data['item_imageUrl'] ?? '',
                                    height: 250,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['item_name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      data['item_origin'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.category_name !=
                                    'Tarian') // Tambahkan kondisi ini
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapsPage(
                                            nama: data['item_name'] ?? '',
                                            category_name: widget.category_name,
                                            latitude: null,
                                            longitude: null,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      AppAssets.iconLocation,
                                      width: 35,
                                      height: 35,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ringkasan',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.underline),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['item_overview'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.justify,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Rincian',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['item_info'].isEmpty
                                      ? 'Maaf, bagian ini belum ada penjelasannya :('
                                      : data['item_info'],
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.justify,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Fakta Menarik',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['item_funfact'].isEmpty
                                      ? 'Maaf, bagian ini belum ada penjelasannya :('
                                      : data['item_funfact'],
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.justify,
                                ),
                                const SizedBox(height: 16),
                                const SizedBox(height: 8),
                                if (data['item_vidUrl'] != null &&
                                    data['item_vidUrl'].isNotEmpty)
                                  Column(
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Video',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      YoutubePlayer(
                                        controller: YoutubePlayerController(
                                          initialVideoId:
                                              YoutubePlayer.convertUrlToId(
                                                      data['item_vidUrl']) ??
                                                  '',
                                          flags: const YoutubePlayerFlags(
                                            autoPlay: false,
                                            mute: false,
                                          ),
                                        ),
                                        showVideoProgressIndicator: true,
                                        progressIndicatorColor:
                                            Colors.blueAccent,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                if (data['item_vidUrl'] == null &&
                                    data['item_vidUrl'].isEmpty)
                                  const SizedBox(height: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
