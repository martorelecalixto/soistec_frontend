
  import 'package:intl/intl.dart';
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/tituloreceber_model.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../config.dart'; // importa o arquivo de configuração
  import 'dart:io';

  class ApiExceptionTituloRec implements Exception {
    final String message;
    ApiExceptionTituloRec(this.message);

    @override
    String toString() => message;
  }

  class TituloReceberService {
     // lib/service/meuService.js
    static const String Url = '${AppConfig.baseUrl}/api/titulosreceber';
    static const String Url2 = '${AppConfig.baseUrl}/api/inctitulosreceber/incTituloRec';
    static const String Url3 = '${AppConfig.baseUrl}/api/titulosreceber/porvendabilhete';

    static Future<List<TituloReceber>> getTituloReceber({String? idfilial, String? idcliente, String? idmoeda, DateTime? datainicial, DateTime? datafinal}) async {
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

        return jsonData.map((e) => TituloReceber.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar titulo');
      }
    }

    static Future<int?> createTituloReceber(TituloReceber titulo) async {
      final resultado = json.encode(titulo.toJson());
      final response = await http.post(
        Uri.parse(Url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(titulo.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['idtitulo']; // Aqui você pega o ID retornado
      } else {
        return null;
      }
    }

    static Future<bool> updateTituloReceber(TituloReceber titulo) async {
      final response = await http.put(
        Uri.parse('$Url/${titulo.idtitulo}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(titulo.toJson()),
      );
      return response.statusCode == 200;
    }

    static Future<void> deleteTituloReceber(int idtitulo) async {
      final url = Uri.parse('$Url/$idtitulo');//Uri.parse('$baseUrl/$idvenda');

      try {
        final response = await http.delete(url);

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Sucesso, venda excluída
          return;
        } else {
          // Erro vindo da API (ex.: 400, 404, 500...)
          final String errorMessage = _parseError(response);
          throw ApiExceptionTituloRec(
              'Erro ao excluir titulo (Status: ${response.statusCode}): $errorMessage');
        }
      } on SocketException {
        throw ApiExceptionTituloRec('Sem conexão com a internet.');
      } on HttpException {
        throw ApiExceptionTituloRec('Erro HTTP ao excluir titulo.');
      } on FormatException {
        throw ApiExceptionTituloRec('Resposta inválida da API.');
      } catch (e) {
        throw ApiExceptionTituloRec('Erro inesperado: $e');
      }
    }

    static Future<int> incTituloRec(int idempresa) async {
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

    static Future<TituloReceber> getTituloReceberById(String idtitulo) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      final uri = Uri.parse('$Url/$idtitulo'); // <--- URL com o ID na rota

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TituloReceber.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('titulo não encontrada');
      } else {
        throw Exception('Erro ao buscar titulo: ${response.reasonPhrase}');
      }
    }

    static Future<List<TituloReceber>> getTituloReceberByVendaBilhete(String idvenda) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      final uri = Uri.parse('$Url3/$idvenda');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (response.statusCode == 200) {
            final List<dynamic> jsonList = jsonDecode(response.body);

            // Mapeia a lista para objetos TituloReceber
            return jsonList.map((json) => TituloReceber.fromJson(json)).toList();
        } else {
          throw Exception('Erro ao carregar títulos: ${response.statusCode}');
        }


      } else if (response.statusCode == 404) {
        throw Exception('Título não encontrado');
      } else {
        throw Exception('Erro ao buscar título: ${response.reasonPhrase}');
      }
    }

    static Future<void> deleteTituloReceberByVendaBilhete(int idvendabilhete) async {
      final url = Uri.parse('$Url3/$idvendabilhete');//Uri.parse('$baseUrl/$idvenda');
     
      try {
        final response = await http.delete(url);

        if (response.statusCode == 200 || response.statusCode == 204) {
          // Sucesso, venda excluída
          return;
        } else {
          // Erro vindo da API (ex.: 400, 404, 500...)
          final String errorMessage = _parseError(response);
          throw ApiExceptionTituloRec(
              'Erro ao excluir titulo (Status: ${response.statusCode}): $errorMessage');
        }
      } on SocketException {
        throw ApiExceptionTituloRec('Sem conexão com a internet.');
      } on HttpException {
        throw ApiExceptionTituloRec('Erro HTTP ao excluir titulo.');
      } on FormatException {
        throw ApiExceptionTituloRec('Resposta inválida da API.');
      } catch (e) {
        throw ApiExceptionTituloRec('Erro inesperado: $e');
      }
    }

  }

