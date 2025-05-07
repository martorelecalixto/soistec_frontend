import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/atividade_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AtividadeService {
  static const String baseUrl = 'https://soistec-api.onrender.com/api/atividades';

  
  static Future<List<Atividade>> getAtividades({String? nome}) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
      'nome': nome ?? '',
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados atividades_service: $jsonData');

      return jsonData.map((e) => Atividade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar atividades');
    }
  }


  static Future<bool> createAtividade(Atividade atividade) async {
    final resultado = json.encode(atividade.toJson());
    print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(atividade.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateAtividade(Atividade atividade) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${atividade.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(atividade.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAtividade(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
