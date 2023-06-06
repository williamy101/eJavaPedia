import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class PredictionTile extends StatelessWidget {
  final GoogleMapsPlaces places;
  final Prediction prediction;
  final Function(String?) onTap;

  PredictionTile({
    required this.places,
    required this.prediction,
    required this.onTap,
  });

  void _handleTap() async {
    await onTap(prediction.placeId);
  }

  Future<void> getPlaceDetails(String placeId) async {
    PlacesDetailsResponse response = await places.getDetailsByPlaceId(placeId);
    if (response.isOkay) {
      final result = response.result;
      onTap(result.placeId);
    } else {
      print('Error fetching place details: ${response.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder<PlacesDetailsResponse>(
        future: places.getDetailsByPlaceId(prediction.placeId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasError) {
            return const Icon(Icons.error);
          }
          if (snapshot.hasData) {
            final result = snapshot.data!.result;
            if (result.photos.isNotEmpty) {
              final photoReference = result.photos.first.photoReference;
              const apiKey = 'AIzaSyD9c4q9V2BvqbvfgR9z6mbulvvfwWxoVeM';
              final imageUrl =
                  'https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=$photoReference&key=$apiKey';
              return SizedBox(
                width: 100,
                height: 150,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              );
            }
          }
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey,
            child: const Center(
              child: Text(
                'Belum ada gambar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      title: Text(prediction.description ?? ''),
      subtitle: FutureBuilder<PlacesDetailsResponse>(
        future: places.getDetailsByPlaceId(prediction.placeId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasError) {
            return const Icon(Icons.error);
          }
          if (snapshot.hasData) {
            final result = snapshot.data!.result;
            if (result.rating != null) {
              final rating = result.rating ?? 0.0;
              final starCount = rating.floor();
              final hasHalfStar = rating - starCount > 0.0;
              final emptyStarCount = 5 - starCount - (hasHalfStar ? 1 : 0);

              return Row(
                children: [
                  for (int i = 0; i < starCount; i++)
                    const Icon(Icons.star, color: Colors.yellow),
                  if (hasHalfStar)
                    const Icon(Icons.star_half, color: Colors.yellow),
                  for (int i = 0; i < emptyStarCount; i++)
                    const Icon(Icons.star_border, color: Colors.yellow),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            } else {
              return const Text(
                'Belum ada rating',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
      onTap: () => getPlaceDetails(prediction.placeId ?? ''),
    );
  }
}
