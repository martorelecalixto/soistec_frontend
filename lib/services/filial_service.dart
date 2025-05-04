import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filial_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilialService {
  static const String baseUrl = 'https://soistec-api.onrender.com/api/filiais';

  //static Future<List<Filial>> getFiliais({String? nome}) async {
  //  final uri = Uri.parse(nome != null ? '$baseUrl?nome=$nome' : baseUrl);
  //  final response = await http.get(uri);

  //  if (response.statusCode == 200) {
  //    final List jsonData = json.decode(response.body);
  //    return jsonData.map((e) => Filial.fromJson(e)).toList();
  //  } else {
  //    throw Exception('Erro ao carregar filiais');
  //  }
  //}

 //static Future<List<Filial>> getFiliais({String? nome}) async {
 //  final prefs = await SharedPreferences.getInstance();
 //  final empresa = prefs.getString('empresa');

 //  if (empresa == null || empresa.isEmpty) {
 //    throw Exception('Empresa não definida nas preferências.');
 //  }

 //  final queryParams = <String, String>{'empresa': empresa};
 //  if (nome != null && nome.isNotEmpty) {
 //    queryParams['nome'] = nome;
 //  }

 //  final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
 //  final response = await http.get(uri);

 //  if (response.statusCode == 200) {
 //    final List jsonData = json.decode(response.body);
 //    return jsonData.map((e) => Filial.fromJson(e)).toList();
 //  } else {
 //    throw Exception('Erro ao carregar filiais');
 //  }
 // }


 // static Future<List<Filial>> getFiliais({String? nome}) async {
 //   final prefs = await SharedPreferences.getInstance();
 //   final empresa = prefs.getString('empresa');

 //   if (empresa == null || empresa.isEmpty) {
 //     throw Exception('Empresa não definida nas preferências.');
 //   }

 //   final queryParams = {
 //     'empresa': empresa,
 //     'nome': nome ?? '',
 //     'cnpjcpf': '',
 //     'email': '',
 //   };

 //   final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
 //   final response = await http.get(uri);

 //   if (response.statusCode == 200) {
 //     final List jsonData = json.decode(response.body);

      //print('Status Code: ${response.statusCode}');
      //print('Response Body: ${response.body}');
 //     print('Dados decodificados: $jsonData');
     // final filiais = jsonData.map((e) => Filial.fromJson(e)).toList();
     // print('Filiais mapeadas: $filiais');

 //     return jsonData.map((e) => Filial.fromJson(e)).toList();
//    } else {
//      throw Exception('Erro ao carregar filiais');
//    }
//  }

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

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      print('Dados decodificados: $jsonData');

      return jsonData.map((e) => Filial.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar filiais');
    }
  }


  static Future<bool> createFilial(Filial filial) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(filial.toJson()),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateFilial(Filial filial) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${filial.idfilial}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(filial.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteFilial(int idfilial) async {
    final response = await http.delete(Uri.parse('$baseUrl/$idfilial'));
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
