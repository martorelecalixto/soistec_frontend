import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/filial_model.dart';
import '../services/filial_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FilialForm extends StatefulWidget {
  final Filial? filial;

  const FilialForm({Key? key, this.filial}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    if (widget.filial != null) {
      final f = widget.filial!;
      _nomeController.text = f.nome;
      _razaoSocialController.text = f.razaosocial;
      _cnpjCpfController.text = f.cnpjcpf;
      _celular1Controller.text = f.celular1;
      _celular2Controller.text = f.celular2;
      _telefone1Controller.text = f.telefone1;
      _telefone2Controller.text = f.telefone2;
      _redesSociaisController.text = f.redessociais;
      _homeController.text = f.home;
      _emailController.text = f.email;
      _cepController.text = f.cep;
      _logradouroController.text = f.logradouro;
      _numeroController.text = f.numero;
      _complementoController.text = f.complemento;
      _bairroController.text = f.bairro;
      _cidadeController.text = f.cidade;
      _estadoController.text = f.estado;
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
      );

      bool sucesso;
      if (widget.filial == null) {
        sucesso = await FilialService.createFilial(filial);
      } else {
        sucesso = await FilialService.updateFilial(filial);
      }

      if (sucesso) {
        Navigator.pop(context, true);
      } else {
        // Trate o erro conforme necessário
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campos do formulário
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _razaoSocialController,
                decoration: const InputDecoration(labelText: 'Razão Social'),
              ),
              TextFormField(
                controller: _cnpjCpfController,
                decoration: const InputDecoration(labelText: 'CNPJ/CPF'),
                inputFormatters: [_cnpjCpfMask],
              ),
              TextFormField(
                controller: _celular1Controller,
                decoration: const InputDecoration(labelText: 'Celular 1'),
                inputFormatters: [_telefoneMask],
              ),
              TextFormField(
                controller: _celular2Controller,
                decoration: const InputDecoration(labelText: 'Celular 2'),
                inputFormatters: [_telefoneMask],
              ),
              TextFormField(
                controller: _telefone1Controller,
                decoration: const InputDecoration(labelText: 'Telefone 1'),
                inputFormatters: [_telefoneMask],
              ),
              TextFormField(
                controller: _telefone2Controller,
                decoration: const InputDecoration(labelText: 'Telefone 2'),
                inputFormatters: [_telefoneMask],
              ),
              TextFormField(
                controller: _redesSociaisController,
                decoration: const InputDecoration(labelText: 'Redes Sociais'),
              ),
              TextFormField(
                controller: _homeController,
                decoration: const InputDecoration(labelText: 'Home'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Informe o email' : null,
              ),
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: 'CEP'),
                keyboardType: TextInputType.number,
                onFieldSubmitted: _buscarCep,
              ),
              TextFormField(
                controller: _logradouroController,
                decoration: const InputDecoration(labelText: 'Logradouro'),
              ),
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: 'Número'),
              ),
              TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(labelText: 'Complemento'),
              ),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro'),
              ),
              TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade'),
              ),
              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _salvar,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
