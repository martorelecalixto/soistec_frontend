
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  //import '../models/vendabilhete_model.dart';
  import '../config.dart'; // importa o arquivo de configuração

  class IncVendaHotelService {
     // lib/service/meuService.js
    static const String Url = '${AppConfig.baseUrl}/api/incvendashotel';
    

    static Future<int> incVendaHotel(int idempresa) async {
      final uri = Uri.parse('$Url/$idempresa');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decodifica o JSON
        final valor = data['novoId']; // Acessa o campo novoId

        if (valor != null && valor is int) {
          return valor;
        } else {
          throw Exception('Campo novoId não encontrado ou inválido: ${response.body}');
        }
      } else {
        throw Exception('Erro ao buscar ID: ${response.statusCode}');
      }
    }


  }

