import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas del centro de Huancayo (Zampa)
  static const double cityLat = -12.0651;
  static const double cityLng = -75.2048;
  static const double radioMaximoKm = 15.0;

  /// Verifica si el servicio de ubicación del celular está activado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Devuelve el permiso actual sin pedirlo todavía
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Indica si el usuario ya tiene permiso válido
  bool hasGrantedPermission(LocationPermission permission) {
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Indica si el usuario bloqueó el permiso para siempre
  bool isDeniedForever(LocationPermission permission) {
    return permission == LocationPermission.deniedForever;
  }

  /// Solicita permiso solo si aún está denegado
  Future<LocationPermission> requestPermissionIfNeeded() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Obtiene la ubicación actual solo si:
  /// - el GPS está activado
  /// - el permiso fue concedido
  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await requestPermissionIfNeeded();

    if (!hasGrantedPermission(permission)) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Verifica si el cliente está dentro de los 15 km de cobertura
  bool isUserInCity(Position userPos) {
    final double distanceInMeters = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      cityLat,
      cityLng,
    );

    return (distanceInMeters / 1000) <= radioMaximoKm;
  }
}
