import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filial_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class FilialService {
  // lib/service/meuService.js
  static const String Url = '${AppConfig.baseUrl}/api/filiais';
  //static const String baseUrl = 'https://soistec-api.onrender.com/api/filiais';

  static Future<List<Filial>> getFiliaisDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
   // print('URL EM getFiliaisDropDown -> ' + Url.toString());
   // print('URI EM getFiliaisDropDown -> ' + uri.toString());
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Filial.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar filiais');
    }
  }

  static Future<List<Filial>> getFiliais({String? nome}) async {
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

      return jsonData.map((e) => Filial.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar filiais');
    }
  }

  static Future<bool> createFilial(Filial filial) async {
    final resultado = json.encode(filial.toJson());
    //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(filial.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateFilial(Filial filial) async {
    final response = await http.put(
      Uri.parse('$Url/${filial.idfilial}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(filial.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteFilial(int idfilial) async {
    final response = await http.delete(Uri.parse('$Url/$idfilial'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Filial> getFilialById(String idfilial) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$Url/$idfilial'); // <--- URL com o ID na rota

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      return Filial.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Entidade não encontrada');
    } else {
      throw Exception('Erro ao buscar filial: ${response.reasonPhrase}');
    }
  }

}
