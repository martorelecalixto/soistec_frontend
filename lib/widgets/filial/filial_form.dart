import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/filial_model.dart';
import '../../services/filial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilialForm extends StatefulWidget {
  final Filial? filial;
  const FilialForm({super.key, this.filial});

  @override
  _FilialFormState createState() => _FilialFormState();
}

class _FilialFormState extends State<FilialForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _razaoSocialController = TextEditingController();
  final TextEditingController _cnpjCpfController = TextEditingController();
  final TextEditingController _celular1Controller = TextEditingController();
  final TextEditingController _celular2Controller = TextEditingController();
  final TextEditingController _telefone1Controller = TextEditingController();
  final TextEditingController _telefone2Controller = TextEditingController();
  final TextEditingController _redesSociaisController = TextEditingController();
  final TextEditingController _homeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  // Máscaras
  final _cnpjCpfMask = MaskTextInputFormatter(mask: '##.###.###/####-##');
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');
  final _cepMask = MaskTextInputFormatter(mask: '#####-###');

  final double fontSize = 12.0; // tamanho padrão da fonte  

  @override
  void initState() {
    super.initState();
    if (widget.filial != null) {
      final f = widget.filial!;
      _nomeController.text = f.nome ?? '';
      _razaoSocialController.text = f.razaosocial ?? '';
      _cnpjCpfController.text = f.cnpjcpf ?? '';
      _celular1Controller.text = f.celular1 ?? '';
      _celular2Controller.text = f.celular2 ?? '';
      _telefone1Controller.text = f.telefone1 ?? '';
      _telefone2Controller.text = f.telefone2 ?? '';
      _redesSociaisController.text = f.redessociais ?? '';
      _homeController.text = f.home ?? '';
      _emailController.text = f.email ?? '';
      _cepController.text = f.cep ?? '';
      _logradouroController.text = f.logradouro ?? '';
      _numeroController.text = f.numero ?? '';
      _complementoController.text = f.complemento ?? '';
      _bairroController.text = f.bairro ?? '';
      _cidadeController.text = f.cidade ?? '';
      _estadoController.text = f.estado ?? '';
    }
  }

  Future<void> _buscarCep(String cep) async {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _logradouroController.text = data['logradouro'] ?? '';
        _bairroController.text = data['bairro'] ?? '';
        _cidadeController.text = data['localidade'] ?? '';
        _estadoController.text = data['uf'] ?? '';
      });
    }
  }

  void _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    if (_formKey.currentState!.validate()) {
      final filial = Filial(
        idfilial: widget.filial?.idfilial ?? 0,
        nome: _nomeController.text,
        razaosocial: _razaoSocialController.text,
        cnpjcpf: _cnpjCpfController.text,
        celular1: _celular1Controller.text,
        celular2: _celular2Controller.text,
        telefone1: _telefone1Controller.text,
        telefone2: _telefone2Controller.text,
        redessociais: _redesSociaisController.text,
        home: _homeController.text,
        email: _emailController.text,
        cep: _cepController.text,
        logradouro: _logradouroController.text,
        numero: _numeroController.text,
        complemento: _complementoController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoController.text,
        empresa: empresa,
      );

      bool sucesso;
      if (widget.filial == null) {
        //print('ENTROU INSERT');
        sucesso = await FilialService.createFilial(filial);
      } else {
        //print('ENTROU UPDATE');
        sucesso = await FilialService.updateFilial(filial);
      }

      if (sucesso) {
        Navigator.pop(context, true);
      } else {
        // Trate o erro conforme necessário
      }
    }
  }

  Widget _buildResponsiveForm(double width) {
    int columns;
    if (width >= 1200) {
      columns = 4;
    } else if (width >= 900) {
      columns = 3;
    } else if (width >= 500) {
      columns = 2;
    } else {
      columns = 1;
    }
   

    // Lista de campos com suas respectivas larguras em colunas
    final fields = [
      {'widget': _buildTextField(_nomeController, 'Nome', validator: true), 'colSpan': columns},
      {'widget': _buildTextField(_razaoSocialController, 'Razão Social'), 'colSpan': columns},
      {'widget': _buildTextField(_cnpjCpfController, 'CNPJ/CPF', inputFormatters: [_cnpjCpfMask]), 'colSpan': 1},
      {'widget': _buildTextField(_celular1Controller, 'Celular 1', inputFormatters: [_telefoneMask]), 'colSpan': 1},
      {'widget': _buildTextField(_celular2Controller, 'Celular 2', inputFormatters: [_telefoneMask]), 'colSpan': 1},
      {'widget': _buildTextField(_telefone1Controller, 'Telefone 1', inputFormatters: [_telefoneMask]), 'colSpan': 1},
      {'widget': _buildTextField(_telefone2Controller, 'Telefone 2', inputFormatters: [_telefoneMask]), 'colSpan': 1},
      {'widget': _buildTextField(_redesSociaisController, 'Redes Sociais'), 'colSpan': columns},
      {'widget': _buildTextField(_homeController, 'Home'), 'colSpan': columns},
      {'widget': _buildTextField(_emailController, 'Email', validator: true), 'colSpan': columns},
      {'widget': _buildTextField(_cepController, 'CEP', inputFormatters: [_cepMask], keyboardType: TextInputType.number, onFieldSubmitted: _buscarCep), 'colSpan': 1},
      {'widget': _buildTextField(_logradouroController, 'Logradouro'), 'colSpan': columns - 1},
      {'widget': _buildTextField(_numeroController, 'Número'), 'colSpan': 1},
      {'widget': _buildTextField(_complementoController, 'Complemento'), 'colSpan': 1},
      {'widget': _buildTextField(_bairroController, 'Bairro'), 'colSpan': 1},
      {'widget': _buildTextField(_cidadeController, 'Cidade'), 'colSpan': columns - 1},
      {'widget': _buildTextField(_estadoController, 'Estado'), 'colSpan': 1},
    ];

    List<Widget> rows = [];
    List<Widget> currentRow = [];
    int currentColCount = 0;

    for (var field in fields) {
      int colSpan = field['colSpan'] as int;
      if (currentColCount + colSpan > columns) {
        rows.add(Row(
          children: currentRow,
        ));
        currentRow = [];
        currentColCount = 0;
      }
      currentRow.add(
        Expanded(
          flex: colSpan,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // menor espaçamento  //const EdgeInsets.all(8.0),
            child: field['widget'] as Widget,
          ),
        ),
      );
      currentColCount += colSpan;
    }

    if (currentRow.isNotEmpty) {
      rows.add(Row(
        children: currentRow,
      ));
    }

    return Column(
      children: rows,
    );
  }

Widget _buildTextField(
  TextEditingController controller,
  String label, {
  bool validator = false,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
  void Function(String)? onFieldSubmitted,
}) {
  return TextFormField(
    controller: controller,
    style: TextStyle(fontSize: fontSize),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: fontSize),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    validator: validator ? (value) => value!.isEmpty ? 'Informe o $label' : null : null,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
    onFieldSubmitted: onFieldSubmitted,
  );
}


@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 8,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Form(
              key: _formKey,
              child: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cadastro de Filial',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildResponsiveForm(constraints.maxWidth),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _salvar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ],
                    ),
              

            ),
          ),
        ),
      );
    },
  );
}


}
