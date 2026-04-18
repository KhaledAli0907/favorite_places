import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location,
    this.isSelecting = true,
  });

  /// Opening the map with `location: null` does not use the constructor default;
  /// use this instead of (0, 0), which is in the ocean.
  static const PlaceLocation defaultStart = PlaceLocation(
    latitude: 37.4220041,
    longitude: -122.0862462,
    address: '',
  );

  final PlaceLocation? location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _pickedLatLng;
  GoogleMapController? _mapController;

  PlaceLocation get _seed =>
      widget.location ?? MapScreen.defaultStart;

  @override
  void initState() {
    super.initState();
    final PlaceLocation seed = _seed;
    _pickedLatLng = LatLng(seed.latitude, seed.longitude);
  }

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
                Navigator.of(context).pop(
                  PlaceLocation(
                    latitude: _pickedLatLng.latitude,
                    longitude: _pickedLatLng.longitude,
                    address: widget.location?.address ?? '',
                  ),
                );
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onTap: widget.isSelecting
            ? (LatLng position) {
                setState(() => _pickedLatLng = position);
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(position),
                );
              }
            : null,
        initialCameraPosition: CameraPosition(
          target: _pickedLatLng,
          zoom: 15,
        ),
        markers: <Marker>{
          Marker(
            markerId: const MarkerId('picked'),
            position: _pickedLatLng,
          ),
        },
      ),
    );
  }
}
