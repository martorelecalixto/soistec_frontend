import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tiposervico_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class TipoServicoService {
  // lib/service/meuService.js
  static const String Url = '${AppConfig.baseUrl}/api/tiposervico';  

  static Future<List<TipoServico>> getTipoServicoHoteisDropDown() async {
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

      return jsonData.map((e) => TipoServico.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar tipo servico');
    }
  }

  static Future<List<TipoServico>> getTipoServicoHoteis({String? nome}) async {
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

      return jsonData.map((e) => TipoServico.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar tipo servico');
    }
  }

  static Future<bool> createTipoServicoHoteis(TipoServico tiposervico) async {
    final resultado = json.encode(tiposervico.toJson());
    //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tiposervico.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateTipoServicoHoteis(TipoServico tiposervico) async {
    final response = await http.put(
      Uri.parse('$Url/${tiposervico.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tiposervico.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteTipoServicoHoteis(int id) async {
    final response = await http.delete(Uri.parse('$Url/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
