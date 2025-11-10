import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Регистрация пользователя
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Ошибка регистрации');
    }
  }

  // Вход пользователя
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Ошибка входа');
    }
  }

  // Расчет франшизы
  static Future<Map<String, dynamic>> calculate({
    required String franchiseId,
    required Map<String, dynamic> inputData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calculate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'franchiseId': franchiseId,
        'inputData': inputData,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка расчета');
    }
  }

  // Получение списка франшиз
  static Future<List<dynamic>> getFranchises() async {
    final response = await http.get(Uri.parse('$baseUrl/franchises'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка загрузки франшиз');
    }
  }

  // Создание заявки
  static Future<Map<String, dynamic>> createApplication({
    required String userId,
    required String franchiseId,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'franchiseId': franchiseId,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка создания заявки');
    }
  }

  // Получение заявок пользователя
  static Future<List<dynamic>> getUserApplications(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/applications'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка загрузки заявок');
    }
  }
}