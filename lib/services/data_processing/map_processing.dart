import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';



class MapProcessing{
  // GeoPoint (lat, lon) -> Mapbox Point (lon, lat)
  Point fromGeoPointToPoint(GeoPoint gp) {
    return Point(coordinates: Position(gp.longitude, gp.latitude));
  }

  // Mapbox Point (lon, lat) -> Firestore GeoPoint (lat, lon)
  GeoPoint fromPointToGeoPoint (Point p) {
    return GeoPoint(p.coordinates.lat.toDouble(), p.coordinates.lng.toDouble());
  }




}
