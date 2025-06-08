
  import 'package:intl/intl.dart';
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/vendabilhete_model.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../config.dart'; // importa o arquivo de configuração
  import 'dart:io';

  class ApiException implements Exception {
    final String message;
    ApiException(this.message);

    @override
    String toString() => message;
  }

  class VendaBilheteService {
     // lib/service/meuService.js
    static const String Url = '${AppConfig.baseUrl}/api/vendasbilhete';
    static const String Url2 = '${AppConfig.baseUrl}/api/vendasbilhete/incVendaBilhete';
    static const String UrlTemBaixa = '${AppConfig.baseUrl}/api/vendasbilhete/tembaixa';

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
      // print('Dados decodificados: ${response.body}');

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);

        return jsonData.map((e) => VendaBilhete.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar vendas');
      }
    }

    static Future<int?> createVendaBilhete(VendaBilhete venda) async {
      final resultado = json.encode(venda.toJson());
     // print('Dados decodificados: $resultado');
      final response = await http.post(
        Uri.parse(Url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(venda.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['idvenda']; // Aqui você pega o ID retornado
      } else {
        return null;
      }
    }

    static Future<bool> updateVendaBilhete(VendaBilhete venda) async {
     
      final response = await http.put(
        Uri.parse('$Url/${venda.idvenda}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(venda.toJson()),
      );
      return response.statusCode == 200;
    }

    static Future<void> deleteVendaBilhete(int idvenda) async {
      final url = Uri.parse('$Url/$idvenda');//Uri.parse('$baseUrl/$idvenda');

      try {
        final response = await http.delete(url);

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Sucesso, venda excluída
          return;
        } else {
          // Erro vindo da API (ex.: 400, 404, 500...)
          final String errorMessage = _parseError(response);
          throw ApiException(
              'Erro ao excluir venda (Status: ${response.statusCode}): $errorMessage');
        }
      } on SocketException {
        throw ApiException('Sem conexão com a internet.');
      } on HttpException {
        throw ApiException('Erro HTTP ao excluir venda.');
      } on FormatException {
        throw ApiException('Resposta inválida da API.');
      } catch (e) {
        throw ApiException('Erro inesperado: $e');
      }
    }

    static Future<int> incVendaBilhete(int idempresa) async {
      final queryParams = {
        'idempresa': idempresa.toString(),
      };

      final uri = Uri.parse(Url2).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Supondo que o body seja algo como: 5 (número puro)
        final valor = int.tryParse(response.body.trim());
        if (valor != null) {
          return valor;
        } else {
          throw Exception('Resposta inválida: ${response.body}');
        }
      } else {
        throw Exception('Erro ao buscar ID: ${response.statusCode}');
      }
    }

    /// Função auxiliar para extrair mensagens de erro do corpo da resposta
    static String _parseError(http.Response response) {
      try {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        } else {
          return response.body;
        }
      } catch (_) {
        return response.body;
      }
    }

    static Future<VendaBilhete> getVendasBilheteById(String idvenda) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      final uri = Uri.parse('$Url/$idvenda'); // <--- URL com o ID na rota

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return VendaBilhete.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Venda não encontrada');
      } else {
        throw Exception('Erro ao buscar venda: ${response.reasonPhrase}');
      }
    }

    static Future<int> getTemBaixa(String idvenda) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      final uri = Uri.parse('$UrlTemBaixa/$idvenda');
      //print(uri);

      final response = await http.get(uri);
      //print(response.body);
      //print(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final qtd = jsonData['qtd'] ?? 0;
       // print('QTD :' + qtd.toString());
        return qtd;
      } else if (response.statusCode == 404) {
        return 0; // ou lança exceção se quiser
      } else {
        throw Exception('Erro ao buscar venda: ${response.reasonPhrase}');
      }
    }

  }

