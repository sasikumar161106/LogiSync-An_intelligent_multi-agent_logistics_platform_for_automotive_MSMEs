import 'dart:convert';
import 'package:http/http.dart' as http;

/// Central API service for communicating with the FastAPI backend.
class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:8000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── DASHBOARD ──────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _get('/dashboard/summary');
    return response;
  }

  Future<List<dynamic>> getInventoryHealth() async {
    final response = await _getList('/dashboard/inventory-health');
    return response;
  }

  Future<List<dynamic>> getShipmentMap() async {
    final response = await _getList('/dashboard/shipment-map');
    return response;
  }

  Future<List<dynamic>> getPortStatus() async {
    final response = await _getList('/dashboard/port-status');
    return response;
  }

  // ── ALERTS ──────────────────────────────────────────────

  Future<List<dynamic>> getAlerts({String? status}) async {
    String path = '/alerts/';
    if (status != null) path += '?status=$status';
    return await _getList(path);
  }

  Future<List<dynamic>> getPendingAlerts() async {
    return await _getList('/alerts/pending');
  }

  Future<Map<String, dynamic>> getAlertSummary() async {
    return await _get('/alerts/summary');
  }

  Future<Map<String, dynamic>> approveAlert(String alertId) async {
    return await _post('/alerts/$alertId/approve', {});
  }

  Future<Map<String, dynamic>> rejectAlert(String alertId, String reason) async {
    return await _post('/alerts/$alertId/reject', {
      'action': 'rejected',
      'reason': reason,
    });
  }

  // ── INVENTORY ───────────────────────────────────────────

  Future<List<dynamic>> getMaterials() async {
    return await _getList('/inventory/materials');
  }

  Future<List<dynamic>> getStock() async {
    return await _getList('/inventory/stock');
  }

  Future<Map<String, dynamic>> getConsumption(String materialId, {int days = 30}) async {
    return await _get('/inventory/consumption/$materialId?days=$days');
  }

  // ── SHIPMENTS ───────────────────────────────────────────

  Future<List<dynamic>> getShipments({String? status}) async {
    String path = '/shipments/';
    if (status != null) path += '?status=$status';
    return await _getList(path);
  }

  Future<List<dynamic>> getActiveShipments() async {
    return await _getList('/shipments/active');
  }

  Future<List<dynamic>> getDelayedShipments() async {
    return await _getList('/shipments/delayed');
  }

  // ── SUPPLIERS ───────────────────────────────────────────

  Future<List<dynamic>> getSuppliers() async {
    return await _getList('/suppliers/');
  }

  // ── AGENTS ──────────────────────────────────────────────

  Future<Map<String, dynamic>> triggerAgentRun() async {
    return await _post('/agents/run', {});
  }

  Future<List<dynamic>> getAgentHistory() async {
    return await _getList('/agents/history');
  }

  Future<Map<String, dynamic>> getAgentConfig() async {
    return await _get('/agents/config');
  }

  // ── HTTP HELPERS ────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw ApiException('GET $path failed: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<List<dynamic>> _getList(String path) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw ApiException('GET $path failed: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw ApiException('POST $path failed: ${response.statusCode}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
