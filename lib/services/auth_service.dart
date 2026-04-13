import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static const String baseUrl =
      'http://SEU_IP:PORTA/api'; // Substitua pelo seu backend

  Future<Map<String, dynamic>> register(User user, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({...user.toJson(), 'password': password}),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Erro no cadastro',
      };
    }
  }
}
