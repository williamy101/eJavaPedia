import 'package:ejavapedia/configs/app_assets.dart';
import 'package:ejavapedia/configs/app_colors.dart';
import 'package:ejavapedia/pages/categories/maps_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailsPage extends StatefulWidget {
  final String type;
  final int id;

  DetailsPage({required this.type, required this.id});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Future<Map<String, dynamic>> fetchItemDetails() async {
    final response = await http.get(Uri.parse(
      'http://192.168.100.8:8888/eJavaPedia/Get?type=${widget.type}&ID=${widget.id}',
    ));

    if (response.body.contains('data')) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];
      return {
        'id': data['ID'],
        'name': data['nama'],
        'origin': data['asal'],
        'overview': data['overview'],
        'info': data['more_info'],
        'funfact': data['fun_fact'],
        'imageUrl': data['pic'],
        'vidUrl': data['vid'],
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
                    '${widget.type}',
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Hero(
                                  tag: 'item_${widget.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      data['imageUrl'] ?? '',
                                      height: 250,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        data['origin'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.type !=
                                    'Tarian') // Tambahkan kondisi ini
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapsPage(
                                              nama: data['name'] ?? '',
                                              type: widget.type,
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
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
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
                                    data['overview'] ?? '',
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
                                    data['info'].isEmpty
                                        ? 'Maaf, bagian ini belum ada penjelasannya :('
                                        : data['info'],
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
                                    data['funfact'].isEmpty
                                        ? 'Maaf, bagian ini belum ada penjelasannya :('
                                        : data['funfact'],
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.justify,
                                  ),
                                  const SizedBox(height: 16),
                                  const SizedBox(height: 8),
                                  if (data['vidUrl'] != null &&
                                      data['vidUrl'].isNotEmpty)
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
                                                        data['vidUrl']) ??
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
                                  if (data['vidUrl'] != null &&
                                      data['vidUrl'].isEmpty)
                                    const SizedBox(height: 16),
                                ],
                              ),
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
