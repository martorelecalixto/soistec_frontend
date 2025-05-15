
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistrade/models/centrocusto_model.dart';

import '../models/vendabilhete_model.dart';
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
import '../models/itensvendabilhete_model.dart';

class VendaBilheteForm extends StatefulWidget {
  final VendaBilhete? vendabilhete;
  final double? width;
  final double? height;

  const VendaBilheteForm({
    super.key,
    this.vendabilhete,
    this.width,
    this.height,
  });

  @override
  _VendaBilheteFormState createState() => _VendaBilheteFormState();
}

class _VendaBilheteFormState extends State<VendaBilheteForm> {
  final _formKey = GlobalKey<FormState>();

  final nroController = TextEditingController();
  final solicitanteController = TextEditingController();
  final observacaoController = TextEditingController();
  final faturaController = TextEditingController();
  final reciboController = TextEditingController();
  final valorEntradaController = TextEditingController(text: '0,00');
  final valorTotalController = TextEditingController(text: '0,00');
  final descontoTotalController = TextEditingController(text: '0,00');

  List<ItensVendaBilhete> _itensVendaBilhete = [];

  bool _isLoading = true;

  // Datas
  DateTime? dataVenda;
  DateTime? dataVencimento;

  // Selecionados
  String? selectedFilial;
  String? selectedCliente;
  String? selectedMoeda;
  String? selectedCCusto;
  String? selectedVendedor;
  String? selectedEmissor;
  String? selectedPagamento;
  String? selectedGrupo;

  bool habilitaSalvarCancelar = true;

  List<Map<String, dynamic>> filiais = [];
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> moedas = [];
  List<Map<String, dynamic>> ccustos = [];
  List<Map<String, dynamic>> vendedores = [];
  List<Map<String, dynamic>> emissores = [];
  List<Map<String, dynamic>> pagamentos = [];
  List<Map<String, dynamic>> grupos = [];

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
  if (widget.vendabilhete != null) {
    final v = widget.vendabilhete!;

    nroController.text = v.id?.toString() ?? '';
    solicitanteController.text = v.solicitante ?? '';
    observacaoController.text = v.observacao ?? '';
    faturaController.text = v.idfatura?.toString() ?? '';
    reciboController.text = v.idreciboreceber?.toString() ?? '';
    valorEntradaController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
  .format(v.valorentrada ?? 0.0);//v.valorentrada?.toString() ?? '';
    valorTotalController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
  .format(v.valortotal ?? 0.0);//v.valortotal?.toString() ?? '';
    descontoTotalController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
  .format(v.descontototal ?? 0.0);//v.descontototal?.toString() ?? '';

    dataVenda =  v.datavenda;
    dataVencimento =  v.datavencimento;
    

    selectedFilial = v.idfilial?.toString();
    selectedCliente = v.identidade?.toString();
    selectedMoeda = v.idmoeda?.toString();
    selectedCCusto = v.idcentrocusto?.toString();
    selectedVendedor = v.idvendedor?.toString();
    selectedEmissor = v.idemissor?.toString();
    selectedPagamento = v.idformapagamento?.toString();
    selectedGrupo = v.idgrupo?.toString();
    // Carrega os itens da venda
    _itensVendaBilhete = await ItemVendaBilheteService.getItensVendaBilheteByIdVenda(idvenda: v.idvenda!);

    setState(() {}); // Garante que os dados sejam renderizados
  }
}

  Future<void> loadDropdownData() async {
      final filiaisResponse = await FilialService.getFiliaisDropDown();
      final clientesResponse = await EntidadeService.getClientesDropDown();
      final vendedoresResponse = await EntidadeService.getVendedoresDropDown();
      final emissoresResponse = await EntidadeService.getEmissoresDropDown();
      final moedasResponse = await MoedaService.getMoedasDropDown();
      final gruposResponse = await GrupoService.getGruposDropDown();
      final pagamentosResponse = await FormaPagamentoService.getFormasPagamentoDropDown();
      final ccustoResponse = await CentroCustoService.getCentroCustoDropDown();

      setState(() {
        filiais = filiaisResponse.map((f) => {'id': f.idfilial, 'nome': f.nome}).toList();
        clientes = clientesResponse.map((c) => {'id': c.identidade, 'nome': c.nome}).toList();
        moedas = moedasResponse.map((m) => {'id': m.idmoeda, 'nome': m.nome}).toList();
        ccustos = ccustoResponse.map((c) => {'id': c.id, 'nome': c.nome}).toList();
        vendedores = vendedoresResponse.map((v) => {'id': v.identidade, 'nome': v.nome}).toList();
        emissores = emissoresResponse.map((e) => {'id': e.identidade, 'nome': e.nome}).toList();
        pagamentos = pagamentosResponse.map((p) => {'id': p.idformapagamento, 'nome': p.nome}).toList();
        grupos = gruposResponse.map((g) => {'id': g.id, 'nome': g.nome}).toList();
      });      
    setState(() {});
  }

  void limparCampos() {
    nroController.clear();
    solicitanteController.clear();
    observacaoController.clear();
    faturaController.clear();
    reciboController.clear();
    valorEntradaController.text = '0,00';
    valorTotalController.text = '0,00';
    descontoTotalController.text = '0,00';
    selectedFilial = selectedCliente = selectedCCusto = selectedVendedor =
    selectedEmissor = selectedMoeda = selectedPagamento = selectedGrupo = null;
    dataVenda = dataVencimento = null;
    setState(() {});
  }

  void salvar() {
    setState(() => habilitaSalvarCancelar = false);
    if (nroController.text.trim() == '0') {
      showDialog(
        context: context,
        builder: (_) => const Dialog(child: Text('Add Bilhete Dialog')),
      );
    }
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


  Widget buildDatePicker(String label, DateTime? date, Function(DateTime?) onChanged) {
    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: InputDecoration(labelText: label),
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) onChanged(picked);
              },
              child: Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Selecionar'),
            ),
          ),
        ),
        IconButton(onPressed: () => onChanged(null), icon: const Icon(Icons.clear)),
      ],
    );
  }

  Widget buildMoneyField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label, prefixText: 'R\$ '),
      keyboardType: TextInputType.number,
    );
  }

  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(onPressed: habilitaSalvarCancelar ? null : () => showDialog(context: context, builder: (_) => const Dialog(child: Text('Títulos Dialog'))), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple), child: const Text('Títulos')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? null : () => print('Gerar PDF'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('Requisição')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? null : () => print('Gerar Recibo'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Recibo')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? null : () => showDialog(context: context, builder: (_) => const Dialog(child: Text('Add Bilhete Dialog'))), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), child: const Text('Bilhete')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? limparCampos : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Novo')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? null : () => print('Editar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), child: const Text('Editar')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? salvar : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo), child: const Text('Salvar')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? () => setState(() => habilitaSalvarCancelar = false) : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey), child: const Text('Cancelar')),
        ElevatedButton(onPressed: habilitaSalvarCancelar ? null : () => print('Excluir'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Excluir')),
      ],
    );
  }


Widget buildListView() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Bilhetes da venda',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1100),
            child: SizedBox(
              height: 300, // Altura máxima visível da tabela
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Ações')),
                    DataColumn(label: Text('Pax')),
                    DataColumn(label: Text('Bilhete')),
                    DataColumn(label: Text('Trecho')),
                    DataColumn(label: Text('CIA')),
                    DataColumn(label: Text('Valor')),
                  ],
                  rows: _itensVendaBilhete.map((item) {
                    return DataRow(cells: [
                      DataCell(Row(children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.delete, color: Colors.red)),
                      ])),
                      DataCell(Text(item.pax ?? '')),
                      DataCell(Text(item.bilhete ?? '')),
                      DataCell(Text(item.trecho ?? '')),
                      DataCell(Text(item.observacao ?? '')),
                      DataCell(Text(
                        NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
                            .format(item.valorbilhete ?? 0.0),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Venda Bilhete')),
    body: _isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Aguarde, carregando os dados...",
                  style: TextStyle(fontSize: 16),
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
                            Expanded(child: buildDropdown('Filial', selectedFilial, (value) => setState(() => selectedFilial = value), () => setState(() => selectedFilial = null), filiais)),
                            const SizedBox(width: 16),
                            Expanded(child: buildDatePicker('Data Venda', dataVenda, (val) => setState(() => dataVenda = val))),
                          ]),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(child: buildDropdown('Cliente', selectedCliente, (value) => setState(() => selectedCliente = value), () => setState(() => selectedCliente = null), clientes)),
                            const SizedBox(width: 16),
                            Expanded(child: buildDropdown('C.Custo', selectedCCusto, (value) => setState(() => selectedCCusto = value), () => setState(() => selectedCCusto = null), ccustos)),
                            const SizedBox(width: 16),
                            Expanded(child: buildDatePicker('Data Vencimento', dataVencimento, (val) => setState(() => dataVencimento = val))),
                          ]),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(child: buildDropdown('Vendedor', selectedVendedor, (value) => setState(() => selectedVendedor = value), () => setState(() => selectedVendedor = null), vendedores)),
                            const SizedBox(width: 16),
                            Expanded(child: buildDropdown('Emissor', selectedEmissor, (value) => setState(() => selectedEmissor = value), () => setState(() => selectedEmissor = null), emissores)),
                            const SizedBox(width: 16),
                            Expanded(child: buildDropdown('Moeda', selectedMoeda, (value) => setState(() => selectedMoeda = value), () => setState(() => selectedMoeda = null), moedas)),
                          ]),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(child: buildDropdown('Pagamento', selectedPagamento, (value) => setState(() => selectedPagamento = value), () => setState(() => selectedPagamento = null), pagamentos)),
                            const SizedBox(width: 16),
                            Expanded(child: buildDropdown('Grupo', selectedGrupo, (value) => setState(() => selectedGrupo = value), () => setState(() => selectedGrupo = null), grupos)),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: solicitanteController, decoration: const InputDecoration(labelText: 'Solicitante'))),
                          ]),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(child: TextFormField(controller: observacaoController, decoration: const InputDecoration(labelText: 'Observação'))),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: faturaController,  readOnly: true, decoration: const InputDecoration(labelText: 'Fatura'))),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: reciboController,  readOnly: true, decoration: const InputDecoration(labelText: 'Recibo'))),
                            const SizedBox(width: 16),
                            //Expanded(child: TextFormField(controller: valorEntradaController,  readOnly: true, decoration: const InputDecoration(labelText: 'Val.Entrada'))),
                            //const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: valorTotalController,  readOnly: true, decoration: const InputDecoration(labelText: 'Va.Total'))),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: descontoTotalController,  readOnly: true, decoration: const InputDecoration(labelText: 'Desc.Total'))),
                          ]),
                          const SizedBox(height: 16),
                          buildButtonsRow(),
                          const SizedBox(height: 24),

                          /// LISTA COM TAMANHO FIXO + SCROLL VERTICAL
                          SizedBox(
                            width: double.infinity,
                            height: 400, // ou ajuste conforme necessário
                            child: buildListView(),
                          ),
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
