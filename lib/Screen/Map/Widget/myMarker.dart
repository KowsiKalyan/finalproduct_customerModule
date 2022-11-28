import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Set<Marker> myMarker(Set<Marker> _markers, LatLng latlong,
    StateSetter stateSetter, TextEditingController locationController) {
  _markers.clear();

  _markers.add(
    Marker(
      markerId: MarkerId(
        Random().nextInt(10000).toString(),
      ),
      position: LatLng(
        latlong.latitude,
        latlong.longitude,
      ),
    ),
  );

  getLocation(latlong, stateSetter, locationController);

  return _markers;
}

Future<void> getLocation(LatLng latlong, StateSetter stateSetter,
    TextEditingController locationController) async {
  List<Placemark> placemark = await placemarkFromCoordinates(
    latlong.latitude,
    latlong.longitude,
  );

  var address;
  address = placemark[0].name;
  address = address + ',' + placemark[0].subLocality;
  address = address + ',' + placemark[0].locality;
  address = address + ',' + placemark[0].administrativeArea;
  address = address + ',' + placemark[0].country;
  address = address + ',' + placemark[0].postalCode;
  locationController.text = address;
  stateSetter(() {});
}
