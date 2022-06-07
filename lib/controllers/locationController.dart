import 'package:geolocator/geolocator.dart';
//agrego la librería geolocator
//modifico info.plist y androind manifest para dar permisos al gps del terminal

class Location {
  late double latitude;
  late double  longitude;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }
}
