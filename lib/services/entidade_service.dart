import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entidade_model.dart';
import '../models/hotel_model.dart';
import '../models/ciaaerea_model.dart';
import '../models/operadora_model.dart';
import '../models/emissor_model.dart';
import '../models/vendedor_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // importa o arquivo de configuração
import 'package:intl/intl.dart';

class ApiExceptionEntidade implements Exception {
  final String message;
  ApiExceptionEntidade(this.message);

  @override
  String toString() => message;
}

class EntidadeService {
  static const String url = '${AppConfig.baseUrl}/api/entidades';
  static const String urlCia = '${AppConfig.baseUrl}/api/entidades/ciaaerea';
  static const String urlOperadora = '${AppConfig.baseUrl}/api/entidades/operadora';
  static const String urlVendedor = '${AppConfig.baseUrl}/api/entidades/vendedor';
  static const String urlEmissor = '${AppConfig.baseUrl}/api/entidades/emissor';
  static const String urlHotel = '${AppConfig.baseUrl}/api/entidades/hotel';
  //static const String baseUrl = 'https://soistec-api.onrender.com/api/entidades';

  static Future<List<Entidade>> getCiasDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar vendedores');
    }
  }

  static Future<List<Entidade>> getEmissoresDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar emissores');
    }
  }

  static Future<List<Entidade>> getVendedoresDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar vendedores');
    }
  }

  static Future<List<Entidade>> getClientesDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar clientes');
    }
  }

  static Future<List<Entidade>> getFornecedoresDropDown() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final queryParams = {
      'empresa': empresa,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');

      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar clientes');
    }
  }

  static Future<List<Entidade>> getEntidades({String? nome, DateTime? datainicial, DateTime? datafinal}) async {
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
      'nome': nome ?? '',
      'datainicial': dataInicialStr ?? '',
      'datafinal': dataFinalStr ?? '',
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);

      //print('Dados filial_service: $jsonData');
      return jsonData.map((e) => Entidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar entidades');
    }
  }

  static Future<int?> createEntidade(Entidade entidade) async {
    //print('createEntidade 01');
    final resultado = json.encode(entidade.toJson());
     //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entidade.toJson()),
    );
    //print('createEntidade 02 ' + Url);
    //print('createEntidade 03 ' + response.body);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['identidade']; // Aqui você pega o ID retornado
    } else {
      return null;
    }
  }

  static Future<bool> updateEntidade(Entidade entidade) async {
    final response = await http.put(
      Uri.parse('$url/${entidade.identidade}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entidade.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteEntidade(int identidade) async {
    final response = await http.delete(Uri.parse('$url/$identidade'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Entidade> getEntidadeById(String identidade) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$url/$identidade'); // <--- URL com o ID na rota

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Entidade.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Entidade não encontrada');
    } else {
      throw Exception('Erro ao buscar entidade: ${response.reasonPhrase}');
    }
  }


  static Future<int?> createCiaAerea(CiaAerea cia) async {
    final resultado = json.encode(cia.toJson());
    final response = await http.post(
      Uri.parse(urlCia),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cia.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['idciaaerea']; // Aqui você pega o ID retornado
    } else {
      return null;
    }
  }

  static Future<bool> updateCiaAerea(CiaAerea cia) async {
    final response = await http.put(
      Uri.parse('$urlCia/${cia.idciaaerea}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cia.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteCiaAerea(int idciaaerea) async {
    final response = await http.delete(Uri.parse('$urlCia/$idciaaerea'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<CiaAerea> getCiaAereaById(String identidade) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$urlCia/$identidade'); // <--- URL com o ID na rota

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return CiaAerea.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Cia não encontrada');
    } else {
      throw Exception('Erro ao buscar cia: ${response.reasonPhrase}');
    }
  }


  static Future<int?> createOperadora(Operadora operadora) async {
    //print('createEntidade 01');
    final resultado = json.encode(operadora.toJson());
     //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(urlOperadora),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(operadora.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['idoperadora']; // Aqui você pega o ID retornado
    } else {
      return null;
    }
  }

  static Future<bool> updateOperadora(Operadora operadora) async {
    final response = await http.put(
      Uri.parse('$urlOperadora/${operadora.idoperadora}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(operadora.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteOperadora(int idoperadora) async {
    final response = await http.delete(Uri.parse('$urlOperadora/$idoperadora'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Operadora> getOperadoraById(String idoperadora) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$urlOperadora/$idoperadora'); // <--- URL com o ID na rota

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Operadora.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Operadora não encontrada');
    } else {
      throw Exception('Erro ao buscar operadora: ${response.reasonPhrase}');
    }
  }


  static Future<int?> createVendedor(Vendedor vendedor) async {
    //print('createEntidade 01');
    final resultado = json.encode(vendedor.toJson());
     //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(urlVendedor),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vendedor.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']; // Aqui você pega o ID retornado
    } else {
      return null;
    }
  }

  static Future<bool> updateVendedor(Vendedor vendedor) async {
    final response = await http.put(
      Uri.parse('$urlVendedor/${vendedor.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vendedor.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteVendedor(int id) async {
    final response = await http.delete(Uri.parse('$urlVendedor/$id'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Vendedor> getVendedorById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$urlVendedor/$id'); // <--- URL com o ID na rota

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Vendedor.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Vendedor não encontrada');
    } else {
      throw Exception('Erro ao buscar vendedor: ${response.reasonPhrase}');
    }
  }


  static Future<int?> createEmissor(Emissor emissor) async {
    //print('createEntidade 01');
    final resultado = json.encode(emissor.toJson());
     //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(urlEmissor),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(emissor.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['idemissor']; // Aqui você pega o ID retornado
    } else {
      return null;
    }
  }

  static Future<bool> updateEmissor(Emissor emissor) async {
    final response = await http.put(
      Uri.parse('$urlEmissor/${emissor.idemissor}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(emissor.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteEmissor(int idemissor) async {
    final response = await http.delete(Uri.parse('$urlEmissor/$idemissor'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Emissor> getEmissorById(String idemissor) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$urlEmissor/$idemissor'); // <--- URL com o ID na rota

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Emissor.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Emissor não encontrada');
    } else {
      throw Exception('Erro ao buscar emissor: ${response.reasonPhrase}');
    }
  }


  static Future<int?> createHotel(Hotel hotel) async {
    //print('createEntidade 01');
    final resultado = json.encode(hotel.toJson());
     //print('Dados decodificados: $resultado');
    final response = await http.post(
      Uri.parse(urlHotel),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(hotel.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['idhotel']; // Aqui você pega o ID retornado
    } else {
      return null;
    }
  }

  static Future<bool> updateHotel(Hotel hotel) async {
    print('ENTROU updateHotel');
    final response = await http.put(
      Uri.parse('$urlHotel/${hotel.idhotel}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(hotel.toJson()),
    );
    print(response.body);
    return response.statusCode == 200;
  }

  static Future<bool> deleteHotel(int idhotel) async {
    final response = await http.delete(Uri.parse('$urlHotel/$idhotel'));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<Hotel> getHotelById(String idhotel) async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    final uri = Uri.parse('$urlHotel/$idhotel'); // <--- URL com o ID na rota

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Hotel.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Hotel não encontrada');
    } else {
      throw Exception('Erro ao buscar hotel: ${response.reasonPhrase}');
    }
  }



}
