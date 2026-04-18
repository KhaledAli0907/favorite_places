import 'package:favorite_places/helpers/static_map_url.dart';
import 'package:flutter/material.dart';

import 'package:favorite_places/models/place.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  String get locationImage {
    return staticMapPreviewUrl(place.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        children: [
          Image.file(place.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(locationImage),
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    place.location.address,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
