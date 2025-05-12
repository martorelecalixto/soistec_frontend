import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entidade_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntidadeService {
  static const String baseUrl = 'https://soistec-api.onrender.com/api/entidades';


  static Future<List<Entidade>> getClientesDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar clientes');
    }
  }

  static Future<List<Entidade>> getEntidades({String? nome}) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
      'nome': nome ?? '',
      'cnpjcpf': '',
      'email': '',
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar entidades');
    }
  }


  static Future<bool> createEntidade(Entidade entidade) async {
    final resultado = json.encode(entidade.toJson());
    //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entidade.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateEntidade(Entidade entidade) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${entidade.identidade}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entidade.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deletefilial(int identidade) async {
    final response = await http.delete(Uri.parse('$baseUrl/$identidade'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
