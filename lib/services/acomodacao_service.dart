import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/acomodacao_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class AcomodacaoService {
  // lib/service/meuService.js
  static const String Url = '${AppConfig.baseUrl}/api/acomodacoes';  
  

  static Future<List<Acomodacao>> getAcomodacoesDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');
    //print('URL EM getAcomodacoesDropDown->' + Url.toString());

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
    //print('URI EM getAcomodacoesDropDown->' + uri.toString());
    final response = await http.get(uri);
    //print(response.statusCode.toString());

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => Acomodacao.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar acomodações');
    }
  }

  static Future<List<Acomodacao>> getAcomodacoes({String? nome}) async {
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


      return jsonData.map((e) => Acomodacao.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar acomodações');
    }
  }

  static Future<bool> createAcomodacao(Acomodacao acomodacao) async {
    final resultado = json.encode(acomodacao.toJson());
    //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(acomodacao.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateAcomodacao(Acomodacao acomodacao) async {
    final response = await http.put(
      Uri.parse('$Url/${acomodacao.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(acomodacao.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAcomodacao(int id) async {
    final response = await http.delete(Uri.parse('$Url/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
