import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas del centro de Huancayo (Zampa)
  static const double cityLat = -12.0651;
  static const double cityLng = -75.2048;
  static const double radioMaximoKm = 15.0; // Radio de acción

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  // Verifica si el cliente está dentro de los 15km
  bool isUserInCity(Position userPos) {
    double distanceInMeters = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      cityLat,
      cityLng,
    );
    return (distanceInMeters / 1000) <= radioMaximoKm;
  }
}
