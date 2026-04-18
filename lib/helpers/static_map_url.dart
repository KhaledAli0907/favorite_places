import 'package:favorite_places/env.dart';
import 'package:favorite_places/models/place.dart';

/// Preview image URL for [location], or an empty string when [location] is null.
String staticMapPreviewUrl(PlaceLocation? location) {
  if (location == null) {
    return '';
  }
  final double latitude = location.latitude;
  final double longitude = location.longitude;
  return Uri.https(
    'maps.googleapis.com',
    '/maps/api/staticmap',
    <String, String>{
      'center': '$latitude,$longitude',
      'zoom': '16',
      'size': '600x300',
      'maptype': 'roadmap',
      'markers': 'color:red|label:A|$latitude,$longitude',
      'key': kGoogleMapsApiKey,
    },
  ).toString();
}
