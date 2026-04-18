import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.4220041,
      longitude: -122.0862462,
      address: '1600 Amphitheatre Parkway, Mountain View, CA',
    ),
    this.isSelecting = true,
  });
  final PlaceLocation? location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick your location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(widget.location);
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.location?.latitude ?? 0,
            widget.location?.longitude ?? 0,
          ),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('p1'),
            position: LatLng(
              widget.location?.latitude ?? 0,
              widget.location?.longitude ?? 0,
            ),
          ),
        },
      ),
    );
  }
}
