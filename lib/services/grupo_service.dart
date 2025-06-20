import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/grupo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class GrupoService {
  // lib/service/meuService.js
  static const String Url = '${AppConfig.baseUrl}/api/grupos';
  //static const String baseUrl = 'https://soistec-api.onrender.com/api/moedas';


  static Future<List<Grupo>> getGruposDropDown() async {
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

      //print('Dados atividades_service: $jsonData');

      return jsonData.map((e) => Grupo.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar moedas');
    }
  }

  static Future<List<Grupo>> getGrupos({String? nome}) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
      'nome': nome ?? '',
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados atividades_service: $jsonData');

      return jsonData.map((e) => Grupo.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar grupos');
    }
  }


  static Future<bool> createGrupo(Grupo grupo) async {
    final resultado = json.encode(grupo.toJson());
    //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grupo.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateGrupo(Grupo grupo) async {
    final response = await http.put(
      Uri.parse('$Url/${grupo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grupo.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteGrupo(int id) async {
    final response = await http.delete(Uri.parse('$Url/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
