import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class AuthService {
  // lib/service/meuService.js
  static const String apiUrl =AppConfig.baseUrl;
  //static const String Url = '${AppConfig.baseUrl}/api/vendasbilhete';

  //static const String apiUrl = 'https://soistec-api.onrender.com';

  // Função para cadastrar o usuário
  static Future<Map<String, dynamic>> cadastrarUsuario(
      String nome, String email, String senha) async {
    try {
      final response = await http.post(
       // Uri.parse('$apiUrl/api/usuarios'),
        Uri.parse('$apiUrl/api/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      final url = Uri.parse('$apiUrl/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'senha': senha}),
      );
      //print(apiUrl);
      //print(url);
      //print('STATUS CODE: ${response.statusCode}');
      //print('RESPONSE BODY: ${response.body}');

      Map<String, dynamic> body;

      try {
        body = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message':
              'Erro ao interpretar resposta do servidor. Resposta inesperada:\n${response.body}',
        };
      }

      if (response.statusCode == 200 && body['success'] == true) {
        final usuario = {
          'nome': body['nome'],
          'email': body['email'],
          'empresa': body['empresa'],
          'idempresa': body['idempresa'],
        };
        final token = body['fctoken'];
        //final empresa = body['empresa'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nome', usuario['nome'] ?? '');
        await prefs.setString('email', usuario['email'] ?? '');
        await prefs.setString('fctoken', token ?? '');
        await prefs.setString('empresa', usuario['empresa'] ?? '');
        await prefs.setInt('idempresa', usuario['idempresa'] ?? 0);

        return {
          'success': true,
          'message': body['message'] ?? 'Login realizado com sucesso',
          'user': usuario,
          'token': token,
          //'empresa': empresa,
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

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nome': prefs.getString('nome'),
      'email': prefs.getString('email'),
      'fctoken': prefs.getString('fctoken'),
      'empresa': prefs.getString('empresa'),
      'idempresa': prefs.getInt('idempresa'),
    };
  }
}
