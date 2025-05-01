import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String apiUrl = 'https://soistec-api.onrender.com';

// Função para cadastrar o usuário
  static Future<Map<String, dynamic>> cadastrarUsuario(String nome, String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nome': nome, 'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Usuário cadastrado com sucesso'};
      } else {
        final body = json.decode(response.body);
        final mensagemErro = body['message'] ?? 'Erro ao cadastrar usuário';
        return {'success': false, 'message': mensagemErro};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

// Função para logar o usuário
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final url = Uri.parse('$apiUrl/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final usuario = body['user'];
        final token = body['token'];

        // Armazenar localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nome', usuario['nome'] ?? '');
        await prefs.setString('email', usuario['email'] ?? '');
        await prefs.setString('fctoken', token ?? '');

        return {
          'success': true,
          'message': body['message'] ?? 'Login realizado com sucesso',
          'usuario': usuario,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Erro ao realizar login',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

// Função para logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

// Função para recuperar dados do usuário
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nome': prefs.getString('nome'),
      'email': prefs.getString('email'),
      'fctoken': prefs.getString('fctoken'),
    };
  }
}
