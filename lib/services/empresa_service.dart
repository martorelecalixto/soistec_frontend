import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/empresa_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração

class EmpresaService {
  static const String Url = '${AppConfig.baseUrl}/api/empresas';

  static Future<List<Empresa>> getEmpresasDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'codigoempresa': empresa,
    };

    final uri = Uri.parse(Url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      return jsonData.map((e) => Empresa.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar empresas');
    }
  }

  static Future<List<Empresa>> getEmpresas({String? nome}) async {
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

      return jsonData.map((e) => Empresa.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar empresas');
    }
  }

  static Future<bool> createEmpresa(Empresa empresa) async {
    final resultado = json.encode(empresa.toJson());
    //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(Url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(empresa.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateEmpresa(Empresa empresa) async {
    final response = await http.put(
      Uri.parse('$Url/${empresa.idempresa}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(empresa.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteEmpresa(int idempresa) async {
    final response = await http.delete(Uri.parse('$Url/$idempresa'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Empresa> getEmpresaById(String idempresa) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }


    final uri = Uri.parse('$Url/$idempresa'); // <--- URL com o ID na rota
    final response = await http.get(uri);
    if (response.statusCode == 200) {
       final jsonData = json.decode(response.body);

       return Empresa.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Empresa não encontrada');
    } else {
      throw Exception('Erro ao buscar empresa: ${response.reasonPhrase}');
    }
  }

}
