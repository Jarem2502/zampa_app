import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas aproximadas del centro de Huancayo para tu lógica de "Ciudad"
  static const double cityLat = -12.0651;
  static const double cityLng = -75.2048;
  static const double radioMaximoKm = 15.0; // Radio de acción para promociones

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. ¿El GPS está encendido?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // 2. ¿Tenemos permisos?
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    // 3. Obtener posición actual
    return await Geolocator.getCurrentPosition();
  }

  // Función mágica para saber si el usuario está cerca de Zampa
  bool isUserInCity(Position userPos) {
    double distanceInMeters = Geolocator.distanceBetween(
      userPos.latitude, 
      userPos.longitude, 
      cityLat, 
      cityLng
    );
    // Convertimos a KM y comparamos
    return (distanceInMeters / 1000) <= radioMaximoKm;
  }
}