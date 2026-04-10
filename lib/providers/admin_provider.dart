import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  double _totalVentas = 0.0;
  int _totalPedidos = 0;
  bool _isLoading = false;
  String _currentFilter = 'Diario';

  // 🔥 Estas ya no darán línea amarilla porque las expondremos con "get"
  String? _startDate;
  String? _endDate;

  double get totalVentas => _totalVentas;
  int get totalPedidos => _totalPedidos;
  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;
  String? get startDate => _startDate;
  String? get endDate => _endDate;

  // Filtros rápidos
  Future<void> updateStats(String filter) async {
    _isLoading = true;
    _currentFilter = filter;
    _startDate = null;
    _endDate = null;
    notifyListeners();

    try {
      final stats = await _adminService.getStats(filter);
      _totalVentas = (stats['ventas'] as num?)?.toDouble() ?? 0.0;
      _totalPedidos = (stats['pedidos'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint("Error AdminProvider (Filtro): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtro de Calendario
  Future<void> updateStatsCustom(String start, String end) async {
    _isLoading = true;
    _currentFilter = 'Personalizado';
    _startDate = start;
    _endDate = end;
    notifyListeners();

    try {
      final stats = await _adminService.getStatsCustom(start, end);
      _totalVentas = (stats['ventas'] as num?)?.toDouble() ?? 0.0;
      _totalPedidos = (stats['pedidos'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint("Error AdminProvider (Custom): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
