import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entidade_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class EntidadeService {
  // lib/service/meuService.js
  static const String Url = '${AppConfig.baseUrl}/api/entidades';
  //static const String baseUrl = 'https://soistec-api.onrender.com/api/entidades';


  static Future<List<Entidade>> getCiasDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar vendedores');
    }
  }


  static Future<List<Entidade>> getEmissoresDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar emissores');
    }
  }

  static Future<List<Entidade>> getVendedoresDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar vendedores');
    }
  }

  static Future<List<Entidade>> getClientesDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
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

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
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
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entidade.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateEntidade(Entidade entidade) async {
    final response = await http.put(
      Uri.parse('$Url/${entidade.identidade}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entidade.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deletefilial(int identidade) async {
    final response = await http.delete(Uri.parse('$Url/$identidade'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Entidade> getEntidadeById(String identidade) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$Url/$identidade'); // <--- URL com o ID na rota

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Entidade.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Entidade não encontrada');
    } else {
      throw Exception('Erro ao buscar entidade: ${response.reasonPhrase}');
    }
  }

}
