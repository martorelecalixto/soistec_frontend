
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sistrade/services/filial_service.dart';
import 'package:sistrade/services/moeda_service.dart';
import 'package:sistrade/services/entidade_service.dart';
import '../services/vendabilhete_service.dart';
import '../services/entidade_service.dart';
import '../services/moeda_service.dart';
import '../services/filial_service.dart';
import '../services/formapagamento_service.dart';
import '../services/grupo_service.dart';
import '../services/centrocusto_service.dart';
import '../services/itensvendabilhete_service.dart';

import 'package:sistrade/models/centrocusto_model.dart';
import '../models/vendabilhete_model.dart';
import '../models/itensvendabilhete_model.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';


class ItemVendaBilheteForm extends StatefulWidget {
  final ItensVendaBilhete? itemvendabilhete;
  final double? width;
  final double? height;

  const ItemVendaBilheteForm({
    super.key,
    this.itemvendabilhete,
    this.width,
    this.height,
  });

  @override
  _ItemVendaBilheteFormState createState() => _ItemVendaBilheteFormState();
}

class _ItemVendaBilheteFormState extends State<ItemVendaBilheteForm> {
  final _formKey = GlobalKey<FormState>();

  final nroController = TextEditingController();
  final bilheteController = TextEditingController();
  final paxController = TextEditingController();
  final trechoController = TextEditingController();
  final observacaoController = TextEditingController();
  final valorController = TextEditingController(text: '0,00');
  final taxaController = TextEditingController(text: '0,00');
  final servicoController = TextEditingController(text: '0,00');
  final assentoController = TextEditingController(text: '0,00');

  final List<ItensVendaBilhete> _itensVendaBilhete = [];

  bool _isLoading = true;

  // Selecionados
  String? selectedOperadora;
  String? selectedCia;
  String? selectedVoo;
  String? selectedTipoVoo;
  String? selectedTipoBilhete;

  bool habilitaSalvarCancelar = true;

  List<Map<String, dynamic>> operadoras = [];
  List<Map<String, dynamic>> cias = [];
  List<Map<String, dynamic>> voos = [];
  List<Map<String, dynamic>> tipovoo = [];
  List<Map<String, dynamic>> tipobilhete = [];
  @override
  void initState() {
    super.initState();
    _init();
  }

void _init() async {
  setState(() => _isLoading = true);
  await loadDropdownData(); // Aguarda dropdowns
  await _carregarDadosIniciais(); // Só então carrega os dados
  setState(() => _isLoading = false);
} 

  Future<void> _carregarDadosIniciais() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (widget.itemvendabilhete != null) {
      final v = widget.itemvendabilhete!;

      nroController.text = v.id?.toString() ?? '';
      valorController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
      .format(v.valorbilhete ?? 0.0);
      taxaController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
      .format(v.valortaxabilhete ?? 0.0);
      servicoController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
      .format(v.valortaxaservico ?? 0.0);
      assentoController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
      .format(v.valorassento ?? 0.0);
      
      selectedOperadora = v.idoperadora?.toString();
      selectedCia = v.idciaaerea?.toString();
      selectedVoo = v.voo?.toString();
      selectedTipoVoo = v.tipovoo?.toString();
      selectedTipoBilhete = v.tipobilhete?.toString();

      setState(() {}); // Garante que os dados sejam renderizados
    }
  }

  Future<void> loadDropdownData() async {
      final operadorasResponse = await EntidadeService.getCiasDropDown();
      final ciasResponse = await EntidadeService.getCiasDropDown();
      final voosResponse = await EntidadeService.getVendedoresDropDown();
      final tipovooResponse = await EntidadeService.getEmissoresDropDown();
      final tipobilheteResponse = await MoedaService.getMoedasDropDown();

      setState(() {
        operadoras = operadorasResponse.map((f) => {'id': f.identidade, 'nome': f.nome}).toList();
        cias = ciasResponse.map((c) => {'id': c.identidade, 'nome': c.nome}).toList();
        voos = voosResponse.map((m) => {'id': m.identidade, 'nome': m.nome}).toList();
        tipovoo = tipovooResponse.map((c) => {'id': c.identidade, 'nome': c.nome}).toList();
        tipobilhete = tipobilheteResponse.map((v) => {'id': v.idmoeda, 'nome': v.nome}).toList();
      });      
    setState(() {});
  }

  void limparCampos() {
    nroController.clear();
    bilheteController.clear();
    observacaoController.clear();
    paxController.clear();
    valorController.text = '0,00';
    taxaController.text = '0,00';
    servicoController.text = '0,00';
    assentoController.text = '0,00';
    selectedOperadora = selectedCia = selectedVoo = selectedTipoBilhete =
    selectedTipoVoo = null;
    setState(() {});
  }

  void onNovo() {
    setState(() {
      habilitaSalvarCancelar = true;
      limparCampos();
    });
  }

  void onEditar() {
    setState(() {
      habilitaSalvarCancelar = true;
    });
  }

  void onSalvar() async{
      final prefs = await SharedPreferences.getInstance();
      final empresa = prefs.getString('empresa');

      if (empresa == null || empresa.isEmpty) {
        throw Exception('Empresa não definida nas preferências.');
      }

      if (_formKey.currentState!.validate()) {
        final itemvendabilhete = ItensVendaBilhete(
         idvenda: widget.itemvendabilhete?.idvenda ?? 0,
         id: widget.itemvendabilhete?.id ?? 0,
         valorbilhete: 0,
         valortaxabilhete: 0,
         valorassento: 0,
         valortaxaservico: 0,
         valorcomisagente: 0,
         valorcomisemissor: 0,
         valorcomisvendedor: 0,
         valordesconto: 0,
         valorfornecedor: 0,
         valornet: 0,
         valortotal: 0,
         pax: widget.itemvendabilhete?.pax,
         observacao:  widget.itemvendabilhete?.observacao,
         trecho:  widget.itemvendabilhete?.trecho,
         bilhete:  widget.itemvendabilhete?.bilhete,
         cancelado: false,
         chave: '',
         idciaaerea: widget.itemvendabilhete?.idciaaerea ?? 0,
         idoperadora: widget.itemvendabilhete?.idoperadora ?? 0,
         tipobilhete: widget.itemvendabilhete?.tipobilhete ?? '',
         tipovoo: widget.itemvendabilhete?.tipovoo ?? '',
         voo: widget.itemvendabilhete?.voo ?? '',
        );

        bool sucesso;
        if (widget.itemvendabilhete == null) {
          //print('ENTROU INSERT');
          sucesso = await ItemVendaBilheteService.createItemVendaBilhete(itemvendabilhete);
        } else {
          //print('ENTROU UPDATE');
          sucesso = await ItemVendaBilheteService.updateItemVendaBilhete(itemvendabilhete);
        }

        if (sucesso) {
          Navigator.pop(context, true);
        } else {
          // Trate o erro conforme necessário
        }
      }

    setState(() {
      habilitaSalvarCancelar = false;

    });
  }

  void onCancelar() {
    setState(() {
      habilitaSalvarCancelar = false;
    });
  }

  void onExcluir() {
    // TODO: lógica do botão Excluir
  }

  void onTitulo() {
    // TODO: lógica do botão Títulos
  }

  void onRequisicao() {
    // TODO: lógica do botão Requisição
  }

  void onRecibo() {
    // TODO: lógica do botão Recibo
  }

  void onBilhete() {
    // TODO: lógica do botão Bilhete
    
  }


  Widget buildDropdown(
    String label,
    String? selectedValue,
    Function(String?) onChanged,
    VoidCallback onClear,
    List<Map<String, dynamic>> options,
  ) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(labelText: label),
            items: options
                .map((item) => DropdownMenuItem(
                      value: item['id'].toString(),
                      child: Text(item['nome']),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : onTitulo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Impr.Trechos'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : onTitulo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Trechos'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : onRecibo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Recibo'),
        ),
       // ElevatedButton(
       //   onPressed: habilitaSalvarCancelar ? null : onBilhete,
       //   style: ElevatedButton.styleFrom(
       //     backgroundColor: Colors.teal,
       //     foregroundColor: Colors.white,
       //   ),
       //   child: const Text('Bilhete'),
       // ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : onNovo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Novo'),
        ),
       // ElevatedButton(
       //   onPressed: habilitaSalvarCancelar ? null : onEditar,
       //   style: ElevatedButton.styleFrom(
       //     backgroundColor: Colors.amber,
       //     foregroundColor: Colors.white,
       //   ),
       //   child: const Text('Editar'),
      //  ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onSalvar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onCancelar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : onExcluir,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bilhete')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Aguarde, carregando os dados...",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                        
                          children: [
                            Row(children: [
                              Expanded(child: TextFormField(controller: nroController,  readOnly: true, decoration: const InputDecoration(labelText: 'Nro'))),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdown('Operadora', selectedOperadora, (value) => setState(() => selectedOperadora = value), () => setState(() => selectedOperadora = null), operadoras)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdown('Cia', selectedCia, (value) => setState(() => selectedCia = value), () => setState(() => selectedCia = null), cias)),
                              const SizedBox(width: 16),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: buildDropdown('Voo', selectedVoo, (value) => setState(() => selectedVoo = value), () => setState(() => selectedVoo = null), voos)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdown('T.Bilhete', selectedTipoBilhete, (value) => setState(() => selectedTipoBilhete = value), () => setState(() => selectedTipoBilhete = null), tipobilhete)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdown('T.Voo', selectedTipoVoo, (value) => setState(() => selectedTipoVoo = value), () => setState(() => selectedTipoVoo = null), tipovoo)),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: TextFormField(controller: valorController,  readOnly: false, decoration: const InputDecoration(labelText: 'Valor'))),
                              const SizedBox(width: 16),
                              Expanded(child: TextFormField(controller: taxaController,  readOnly: false, decoration: const InputDecoration(labelText: 'Taxa'))),
                              const SizedBox(width: 16),
                              Expanded(child: TextFormField(controller: servicoController,  readOnly: false, decoration: const InputDecoration(labelText: 'Serviço'))),
                              const SizedBox(width: 16),
                              Expanded(child: TextFormField(controller: assentoController,  readOnly: false, decoration: const InputDecoration(labelText: 'Assento'))),
                            ]),
                            const SizedBox(height: 10),
                            buildButtonsRow(),
                            const SizedBox(height: 10),
                          ],                          
                        
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

}
