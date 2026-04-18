import 'dart:convert';

import 'package:favorite_places/helpers/static_map_url.dart';
import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:favorite_places/env.dart';

Uri geocodeRequestUri({
  required double latitude,
  required double longitude,
}) {
  return Uri.https(
    'maps.googleapis.com',
    '/maps/api/geocode/json',
    <String, String>{
      'latlng': '$latitude,$longitude',
      'key': kGoogleMapsApiKey,
    },
  );
}

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  bool isLoading = false;
  String? formattedAddress;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _getCurrentLocation() async {
    final Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData? locationData;
    double? longitude;
    double? latitude;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      locationData = await location.getLocation();
      longitude = locationData.longitude;
      latitude = locationData.latitude;
      final response = await http.get(
        geocodeRequestUri(
          latitude: latitude!,
          longitude: longitude!,
        ),
      );

      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      final String? apiStatus = data['status'] as String?;
      final List<dynamic> results =
          data['results'] as List<dynamic>? ?? <dynamic>[];

      if (response.statusCode != 200) {
        _showMessage(
          'Address lookup failed (HTTP ${response.statusCode}).',
        );
        return;
      }

      // API errors (e.g. REQUEST_DENIED) often use an empty `results` list —
      // handle those before treating empty results as "no address".
      if (apiStatus != 'OK' && apiStatus != 'ZERO_RESULTS') {
        final String? err = data['error_message'] as String?;
        _showMessage(
          err ?? 'Geocoding failed (${apiStatus ?? 'unknown'}).',
        );
        return;
      }

      if (apiStatus == 'ZERO_RESULTS' || results.isEmpty) {
        _showMessage(
          'No address was found for these coordinates. Try another spot.',
        );
        return;
      }

      formattedAddress = results.first['formatted_address'] as String?;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          _pickedLocation = PlaceLocation(
            latitude: latitude!,
            longitude: longitude!,
            address: formattedAddress!,
          );
          widget.onSelectLocation(_pickedLocation!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Colors.white,
          ),
    );

    final String previewUrl = staticMapPreviewUrl(_pickedLocation);
    if (previewUrl.isNotEmpty) {
      previewContent = Image.network(
        previewUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (isLoading) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: Theme.of(context).colorScheme.primary),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Pick Location'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
