import 'dart:convert';
import 'dart:io';
import 'package:ejavapedia/pages/categories/prediction_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MapsPage extends StatefulWidget {
  final String nama;
  final String type;
  final double? latitude;
  final double? longitude;

  MapsPage(
      {required this.nama, required this.type, this.latitude, this.longitude});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final places = GoogleMapsPlaces(
    apiKey: 'AIzaSyD9c4q9V2BvqbvfgR9z6mbulvvfwWxoVeM',
  );

  List<Map<String, dynamic>> updatedBookmarkData = [];

  List<Map<String, dynamic>> existingBookmarks = [];

  void _addBookmark(PlaceDetails result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountId = prefs.getString('accountId');

    final bookmark = {
      'kategori': widget.type,
      'nama': result.name,
      'latitude': double.parse(result.geometry!.location.lat.toString()),
      'longitude': double.parse(result.geometry!.location.lng.toString()),
      'alamat': result.formattedAddress ?? '',
      'rating': result.rating?.toString() ?? '',
      'pic': result.photos.isNotEmpty
          ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${result.photos[0].photoReference}'
          : '',
    };

    List<Map<String, dynamic>> existingBookmarks =
        jsonDecode(prefs.getString('bookmarkData') ?? '[]')
            .cast<Map<String, dynamic>>();

    bool isDuplicate = existingBookmarks.any((bookmark) =>
        bookmark['nama'] == result.name &&
        bookmark['latitude'] ==
            double.parse(result.geometry!.location.lat.toString()) &&
        bookmark['longitude'] ==
            double.parse(result.geometry!.location.lng.toString()));

    if (isDuplicate) {
      print('Bookmark already exists');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tempat ini sudah masuk favorit"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    existingBookmarks.add(bookmark);

    await prefs.setString('bookmarkData', jsonEncode(existingBookmarks));

    final url = Uri.parse('http://192.168.100.8:8888/eJavaPedia/AddBookmark');

    final payload = {
      'account_id': accountId,
      'data': existingBookmarks,
    };

    final response = await http.post(
      url,
      body: jsonEncode(payload),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var responseBody = jsonDecode(response.body);

    if (responseBody['error']['status'] == false) {
      print('Bookmark berhasil ditambahkan');
      print(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil masuk favorit"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Update the local bookmark data list
      setState(() {
        updatedBookmarkData = existingBookmarks;
      });
    } else {
      print('Gagal menambahkan bookmark');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  List<Prediction> _predictions = [];

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    List<Component> components = [
      Component(Component.country, 'id'),
    ];

    if (widget.nama == 'Brem') {
      input += ' Jawa Timur';
    }

    PlacesAutocompleteResponse response = await places.autocomplete(
      input,
      components: components,
    );

    setState(() {
      _predictions = response.predictions;
    });
  }

  void getPlaceDetails(String placeId) async {
    PlacesDetailsResponse response = await places.getDetailsByPlaceId(placeId);
    if (response.isOkay) {
      final result = response.result;

      if (_mapController != null && result.geometry?.location != null) {
        final LatLng position = LatLng(
          result.geometry!.location.lat,
          result.geometry!.location.lng,
        );
        const double zoomLevel = 20.0;
        _mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(position, zoomLevel));
        _markers = {
          Marker(
            markerId: MarkerId(result.placeId),
            position: position,
            infoWindow: InfoWindow(title: result.name),
          )
        };
        setState(() {});

        Future.delayed(const Duration(seconds: 1), () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              bool isBookmarked = false;
              if (existingBookmarks.any((bookmark) =>
                  bookmark['nama'] == result.name &&
                  bookmark['latitude'] ==
                      double.parse(result.geometry!.location.lat.toString()) &&
                  bookmark['longitude'] ==
                      double.parse(result.geometry!.location.lng.toString()))) {
                isBookmarked = true;
              }

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                title: Text(result.name),
                content: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Column(
                    children: [
                      if (result.photos.isNotEmpty)
                        Expanded(
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  child: InteractiveViewer(
                                    minScale: 0.1,
                                    maxScale: 3.0,
                                    child: Image.network(
                                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${result.photos[0].photoReference}&key=AIzaSyD9c4q9V2BvqbvfgR9z6mbulvvfwWxoVeM',
                                      fit: BoxFit.cover,
                                      width: 300,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      if (result.rating != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            for (int i = 0;
                                                i < result.rating!.floor();
                                                i++)
                                              const Icon(Icons.star,
                                                  color: Colors.yellow),
                                            if (result.rating! -
                                                    result.rating!.floor() >
                                                0.0)
                                              const Icon(Icons.star_half,
                                                  color: Colors.yellow),
                                            for (int i = 0;
                                                i < (5 - result.rating!.ceil());
                                                i++)
                                              const Icon(Icons.star_border,
                                                  color: Colors.yellow),
                                            const SizedBox(width: 4),
                                            Text(
                                              result.rating.toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (result.rating == null)
                                        const Text(
                                          'Belum ada rating',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            result.formattedAddress ?? '',
                                            style:
                                                const TextStyle(fontSize: 16),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  if (!isBookmarked)
                    TextButton(
                      child: const Text('Favorit'),
                      onPressed: () {
                        _addBookmark(result);
                        Navigator.of(context).pop();
                      },
                    ),
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
      } else {
        print('Error fetching place details: ${response.errorMessage}');
      }
    }
  }

  void showAutocompleteModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: _predictions.length,
            itemBuilder: (BuildContext context, int index) {
              Prediction prediction = _predictions[index];
              return PredictionTile(
                places: places,
                prediction: prediction,
                onTap: (String? placeId) {
                  if (placeId != null) {
                    getPlaceDetails(placeId);
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      searchPlaces(widget.nama);
      _markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: LatLng(widget.latitude!, widget.longitude!),
        ),
      };
    } else {
      _searchController.text = widget.nama;
      searchPlaces(widget.nama);
    }
    _searchController.text = widget.nama;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, updatedBookmarkData);
                },
                child: const Padding(
                  padding: EdgeInsets.only(
                    top: 24.0,
                    left: 16.0,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
          title: const Padding(
            padding: EdgeInsets.only(
              top: 24.0,
            ),
            child: Text(
              'Lokasi',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude ?? 0, widget.longitude ?? 0),
              zoom: 19.5,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: Colors.grey[300],
                  child: TextField(
                    controller: _searchController,
                    onChanged: searchPlaces,
                    decoration: InputDecoration(
                      hintText: 'Cari tempat...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          showAutocompleteModal();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
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
