import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/centrocusto_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class CentroCustoService {
  // lib/service/meuService.js
  static const String Url = '${AppConfig.baseUrl}/api/centrocusto';  
  //static const String baseUrl = 'https://soistec-api.onrender.com/api/atividades';

  static Future<List<CentroCusto>> getCentroCustoDropDown() async {
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

      return jsonData.map((e) => CentroCusto.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar centro custo');
    }
  }

  static Future<List<CentroCusto>> getCentroCusto({String? nome}) async {
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

      return jsonData.map((e) => CentroCusto.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar centro custo');
    }
  }


  static Future<bool> createCentroCusto(CentroCusto centrocusto) async {
    final resultado = json.encode(centrocusto.toJson());
    print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(centrocusto.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateCentroCusto(CentroCusto centrocusto) async {
    final response = await http.put(
      Uri.parse('$Url/${centrocusto.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(centrocusto.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteCentroCusto(int id) async {
    final response = await http.delete(Uri.parse('$Url/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
