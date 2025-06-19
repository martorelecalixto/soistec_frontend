
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/itensvendahotel_model.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../config.dart'; // importa o arquivo de configuração

  class ItemVendaHotelService {
     // lib/service/meuService.js
    static const String Url = '${AppConfig.baseUrl}/api/itensvendahotel';
    
    static Future<List<ItensVendaHotel>> getItensVendaHotel({String? idfornecedor, String? idoperadora, String? pax}) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      // Formata datas manualmente
      final queryParams = {
        'empresa': empresa,
        'idcia': idfornecedor ?? '',
        'idoperadora': idoperadora ?? '',
        'pax': pax ?? '',
      };

      final uri = Uri.parse(Url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);

        return jsonData.map((e) => ItensVendaHotel.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao carregar itens vendas');
      }
    }

    static Future<int?> createItemVendaHotel(ItensVendaHotel item) async {

      final resultado = json.encode(item.toJson());
      final response = await http.post(
        Uri.parse(Url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return data['id']; // Aqui você pega o ID retornado
      } else {
        return null;
      }

      //return response.statusCode == 201;
    }

    static Future<bool> updateItemVendaHotel(ItensVendaHotel item) async {
      final response = await http.put(
        Uri.parse('$Url/${item.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      return response.statusCode == 200;
    }

    static Future<bool> deleteItemVendaHotel(int id) async {
      final response = await http.delete(Uri.parse('$Url/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    }

    static Future<ItensVendaHotel> getItensVendaHotelById(String id) async {
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');
    //  print('ENTROU getItensVendaHotelById');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      final uri = Uri.parse('$Url/$id'); // <--- URL com o ID na rota

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ItensVendaHotel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Venda não encontrada');
      } else {
        throw Exception('Erro ao buscar venda: ${response.reasonPhrase}');
      }
      
    }

    static Future<List<ItensVendaHotel>> getItensVendaHotelByIdVenda({required int idvenda}) async {
      final uri = Uri.parse('$Url/porvenda/$idvenda');
      //print('getItensVendaHotelByIdVenda IDVENDA -> ' + idvenda.toString());
     // print('getItensVendaHotelByIdVenda URL->' + uri.toString());
      final response = await http.get(uri);
      //print('RETORNO RESPONSE -> ' + response.statusCode.toString());

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);

        if (jsonData.isEmpty) {
          return []; // Retorna lista vazia se não houver dados
        }

        return jsonData.map((e) => ItensVendaHotel.fromJson(e)).toList();
      } else {
        return []; // Também retorna lista vazia em caso de erro
        // Ou use: throw Exception('Erro ao carregar itens vendas');
      }
    }

  }

