
  import 'package:intl/intl.dart';
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/reciboreceber_model.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../config.dart'; // importa o arquivo de configuração
  import 'dart:io';

  class ApiExceptionReciboRec implements Exception {
    final String message;
    ApiExceptionReciboRec(this.message);

    @override
    String toString() => message;
  }

  class ReciboReceberService {
     // lib/service/meuService.js
    static const String Url = '${AppConfig.baseUrl}/api/recibosreceber';
    static const String Url2 = '${AppConfig.baseUrl}/api/increcibosreceber/incReciboRec';

    static Future<List<ReciboReceber>> getReciboReceber({String? idfilial, String? idcliente, String? idmoeda, DateTime? datainicial, DateTime? datafinal}) async {
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

        return jsonData.map((e) => ReciboReceber.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar recibo');
      }
    }

    static Future<int?> createReciboReceber(ReciboReceber recibo) async {
      final resultado = json.encode(recibo.toJson());
      //print('Dados decodificados: $resultado');
      final response = await http.post(
        Uri.parse(Url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recibo.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['idrecibo']; // Aqui você pega o ID retornado
      } else {
        return null;
      }
    }

    static Future<bool> updateReciboReceber(ReciboReceber recibo) async {
      final response = await http.put(
        Uri.parse('$Url/${recibo.idrecibo}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recibo.toJson()),
      );
      return response.statusCode == 200;
    }

    static Future<void> deleteReciboReceber(int idrecibo) async {
      final url = Uri.parse('$Url/$idrecibo');//Uri.parse('$baseUrl/$idvenda');

      try {
        final response = await http.delete(url);

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Sucesso, venda excluída
          return;
        } else {
          // Erro vindo da API (ex.: 400, 404, 500...)
          final String errorMessage = _parseError(response);
          throw ApiExceptionReciboRec(
              'Erro ao excluir recibo (Status: ${response.statusCode}): $errorMessage');
        }
      } on SocketException {
        throw ApiExceptionReciboRec('Sem conexão com a internet.');
      } on HttpException {
        throw ApiExceptionReciboRec('Erro HTTP ao excluir recibo.');
      } on FormatException {
        throw ApiExceptionReciboRec('Resposta inválida da API.');
      } catch (e) {
        throw ApiExceptionReciboRec('Erro inesperado: $e');
      }
    }

    static Future<int> incReciboRec(int idempresa) async {
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

    static Future<ReciboReceber> getReciboReceberById(String idrecibo) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      final uri = Uri.parse('$Url/$idrecibo'); // <--- URL com o ID na rota

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReciboReceber.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Recibo não encontrada');
      } else {
        throw Exception('Erro ao buscar recibo: ${response.reasonPhrase}');
      }
    }

  }

