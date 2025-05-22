
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/itensvendabilhete_model.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../config.dart'; // importa o arquivo de configuração

  class ItemVendaBilheteService {
     // lib/service/meuService.js
    static const String Url = '${AppConfig.baseUrl}/api/itensvendabilhete';
    
    static Future<List<ItensVendaBilhete>> getItensVendaBilhete({String? idcia, String? idoperadora, String? pax}) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      // Formata datas manualmente
      final queryParams = {
        'empresa': empresa,
        'idcia': idcia ?? '',
        'idoperadora': idoperadora ?? '',
        'pax': pax ?? '',
      };

      final uri = Uri.parse(Url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);

        return jsonData.map((e) => ItensVendaBilhete.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar itens vendas');
      }
    }

    static Future<bool> createItemVendaBilhete(ItensVendaBilhete item) async {
      final resultado = json.encode(item.toJson());
      final response = await http.post(
        Uri.parse(Url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      return response.statusCode == 201;
    }

    static Future<bool> updateItemVendaBilhete(ItensVendaBilhete item) async {
      final response = await http.put(
        Uri.parse('$Url/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      return response.statusCode == 200;
    }

    static Future<bool> deleteItemVendaBilhete(int id) async {
      final response = await http.delete(Uri.parse('$Url/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    }

    static Future<List<ItensVendaBilhete>> getItensVendaBilheteById({int? id}) async {
      final queryParams = {
        'id': id,
      };

      final uri = Uri.parse(Url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);

        return jsonData.map((e) => ItensVendaBilhete.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar itens vendas');
      }
    }


  static Future<List<ItensVendaBilhete>> getItensVendaBilheteByIdVenda({required int idvenda}) async {
    final uri = Uri.parse('$Url/porvenda/$idvenda');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      if (jsonData.isEmpty) {
        return []; // Retorna lista vazia se não houver dados
      }

      return jsonData.map((e) => ItensVendaBilhete.fromJson(e)).toList();
    } else {
      return []; // Também retorna lista vazia em caso de erro
      // Ou use: throw Exception('Erro ao carregar itens vendas');
    }
  }


  }

