import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/formapagamento_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class FormaPagamentoService {
  // lib/service/meuService.js
  static const String Url = '${AppConfig.baseUrl}/api/formaspagamento';  
  //static const String baseUrl = 'https://soistec-api.onrender.com/api/atividades';

  static Future<List<FormaPagamento>> getFormasPagamentoDropDown() async {
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

      return jsonData.map((e) => FormaPagamento.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar forma pagamento');
    }
  }

  static Future<List<FormaPagamento>> getFormasPagamento({String? nome}) async {
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

      return jsonData.map((e) => FormaPagamento.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar forma pagamento');
    }
  }

  static Future<bool> createFormaPagamento(FormaPagamento formapagamento) async {
    final resultado = json.encode(formapagamento.toJson());
    print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(formapagamento.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateFormaPagamento(FormaPagamento formapagamento) async {
    final response = await http.put(
      Uri.parse('$Url/${formapagamento.idformapagamento}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(formapagamento.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteFormaPagamento(int idformapagamento) async {
    final response = await http.delete(Uri.parse('$Url/$idformapagamento'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<FormaPagamento> getFormaPagamentoById(String idformapagamento) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$Url/$idformapagamento'); // <--- URL com o ID na rota
   // print(uri);

    final response = await http.get(uri);
    //print(response.body);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return FormaPagamento.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Venda não encontrada');
    } else {
      throw Exception('Erro ao buscar venda: ${response.reasonPhrase}');
    }
  }

}
