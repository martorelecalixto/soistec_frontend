
  import 'package:intl/intl.dart';
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/vendabilhete_model.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../config.dart'; // importa o arquivo de configuração

  class VendaBilheteService {
     // lib/service/meuService.js
     static const String Url = '${AppConfig.baseUrl}/api/vendasbilhete';
    
    static Future<List<VendaBilhete>> getVendaBilhetes({String? idfilial, String? idcliente, String? idmoeda, DateTime? datainicial, DateTime? datafinal}) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      // Formata datas manualmente
      final dateFormatter = DateFormat('MM/dd/yyyy');
      final dataInicialStr = datainicial != null ? dateFormatter.format(datainicial) : '';
      final dataFinalStr = datafinal != null ? dateFormatter.format(datafinal) : '';

      final queryParams = {
        'empresa': empresa,
        'idfilial': idfilial ?? '',
        'identidade': idcliente ?? '',
        'idmoeda': idmoeda ?? '',
        'datainicial': dataInicialStr ?? '',
        'datafinal': dataFinalStr ?? '',
      };

      final uri = Uri.parse(Url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);

        return jsonData.map((e) => VendaBilhete.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar vendas');
      }
    }


    static Future<bool> createVendaBilhete(VendaBilhete venda) async {
      final resultado = json.encode(venda.toJson());
      //print('Dados decodificados: $resultado');
      final response = await http.post(
        Uri.parse(Url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(venda.toJson()),
      );
      return response.statusCode == 201;
    }

    static Future<bool> updateVendaBilhete(VendaBilhete venda) async {
      final response = await http.put(
        Uri.parse('$Url/${venda.idvenda}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(venda.toJson()),
      );
      return response.statusCode == 200;
    }

    static Future<bool> deleteVendaBilhete(int idvenda) async {
      final response = await http.delete(Uri.parse('$Url/$idvenda'));
      return response.statusCode == 200 || response.statusCode == 204;
    }
  }

