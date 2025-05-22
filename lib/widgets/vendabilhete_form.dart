
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
import '../services/incvendabilhete_service.dart';

import 'package:sistrade/models/centrocusto_model.dart';
import '../models/vendabilhete_model.dart';
import '../models/itensvendabilhete_model.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:sistrade/widgets/itemvendabilhete_form.dart';

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

  int idReq = 0;

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


  void _abrirFormulario({Map<String, dynamic>? itemvendabilhete}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 900,
          height: 350,
          child: ItemVendaBilheteForm(
            itemvendabilhete: itemvendabilhete != null ? ItensVendaBilhete.fromJson(itemvendabilhete) : null,
          ),
        ),
      ),
    );
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


  double parseValor(String valor) {
    return double.tryParse(valor.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
  }


  void _abrirFormularioNovo({Map<String, dynamic>? vendabilhete}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1200,
          height: 800,
          child: VendaBilheteForm(
            vendabilhete: vendabilhete != null ? VendaBilhete.fromJson(vendabilhete) : null,
          ),
        ),
      ),
    );

  }


  void onNovo() {

    setState(() {
      //habilitaSalvarCancelar = true;
      Navigator.pop(context, true);
      _abrirFormularioNovo();
      idReq = 0;
    });
  }


  void onEditar() {
    setState(() {
      habilitaSalvarCancelar = true;
    });
  }


  void onSalvar() async{
    if (!_formKey.currentState!.validate()) {
      //print('Campos obrigatórios não preenchidos.');
      return; // Sai da função e não executa mais nada.
    }else{
        try{
          // TODO: lógica do botão Salvar
          var uuid = Uuid();
          final prefs = await SharedPreferences.getInstance();
          final empresa = prefs.getString('empresa');
          final idempresa = prefs.getInt('idempresa');

          //BuscarId//
          if (idempresa != null) {
            if ((widget.vendabilhete == null)||(widget.vendabilhete?.idvenda == 0)) {
              idReq = await IncVendaBilheteService.incVendaBilhete(idempresa);
              nroController.text = idReq.toString();
            }else{ 
                idReq = widget.vendabilhete?.id ?? 0;
                nroController.text = idReq.toString();        
              }

          } else {
            throw Exception('ID da empresa não encontrado.');
          }

          if (empresa == null || empresa.isEmpty) {
            throw Exception('Empresa não definida nas preferências.');
          }

          if (_formKey.currentState!.validate()) {
            final vendabilhete = VendaBilhete(
              idvenda: widget.vendabilhete?.idvenda ?? 0,
              id: idReq,
              datavenda: dataVenda,
              datavencimento: dataVencimento,
              documento: '', // ou algum campo se houver
              valortotal: parseValor(valorTotalController.text),
              descontototal: parseValor(descontoTotalController.text),
              valorentrada: parseValor(valorEntradaController.text),
              observacao: observacaoController.text,
              solicitante: solicitanteController.text,
              identidade: selectedCliente != null ? int.tryParse(selectedCliente!) : null,
              idvendedor: selectedVendedor != null ? int.tryParse(selectedVendedor!) : null,
              idemissor: selectedEmissor != null ? int.tryParse(selectedEmissor!) : null,
              idmoeda: selectedMoeda != null ? int.tryParse(selectedMoeda!) : null,
              idformapagamento: selectedPagamento != null ? int.tryParse(selectedPagamento!) : null,
              idfilial: selectedFilial != null ? int.tryParse(selectedFilial!) : null,
              idfatura: int.tryParse(faturaController.text),
              idreciboreceber: int.tryParse(reciboController.text),
              chave: uuid.v4(),
              excluido: false,
              empresa: empresa,
              idcentrocusto: selectedCCusto != null ? int.tryParse(selectedCCusto!) : null,
              idgrupo: selectedGrupo != null ? int.tryParse(selectedGrupo!) : null,
            );
            
            bool sucesso;
            if (widget.vendabilhete == null) {
              sucesso = await VendaBilheteService.createVendaBilhete(vendabilhete);
            } else {
              sucesso = await VendaBilheteService.updateVendaBilhete(vendabilhete);
            }

            if (sucesso) {
              Navigator.pop(context, true);
            } else {
              // Trate o erro conforme necessário
            }
          }

          setState(() {
            habilitaSalvarCancelar = true;
          });

        } catch (e) {
          print('Erro de conexão: $e');
        }    
    }
  }


  void onCancelar() {
    setState(() {
      habilitaSalvarCancelar = true;
      // TODO: lógica do botão Cancelar
    });
  }


  void onExcluir() {
    if ((widget.vendabilhete != null)&&(widget.vendabilhete?.idvenda != 0)&&(widget.vendabilhete?.idvenda != null)){

    }
  }


  void onTitulo() {
    // TODO: lógica do botão Títulos
  }


  void onRequisicao() {
    // TODO: lógica do botão Requisição
  }


  void onRecibo() {
    // TODO: lógica do botão Recibo
    if ((widget.vendabilhete != null)&&(widget.vendabilhete?.idvenda != 0)&&(widget.vendabilhete?.idvenda != null)){
    
    }
  }


  void onBilhete() {
    if ((widget.vendabilhete != null)&&(widget.vendabilhete?.idvenda != 0)&&(widget.vendabilhete?.idvenda != null)){
      _abrirFormulario();
    }
  }


  Widget buildDropdownFilial(
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
            validator: (value) {
              if (value == null && selectedGrupo == null) {
                return 'filial obrigatória.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownCliente(
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
            validator: (value) {
              if (value == null && selectedGrupo == null) {
                return 'cliente obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownMoeda(
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
            validator: (value) {
              if (value == null && selectedGrupo == null) {
                return 'moeda obrigatória.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownVendedor(
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
            validator: (value) {
              if (value == null && selectedGrupo == null) {
                return 'vendedor obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownEmissor(
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
            validator: (value) {
              if (value == null && selectedGrupo == null) {
                return 'emissor obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownPagamento(
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
            validator: (value) {
              if (value == null && selectedGrupo == null) {
                return 'meio pagamento obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
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


  Widget buildDatePickerEmissao(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { 
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'data venda obrigatória.';
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                errorText: formFieldState.errorText,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          onChanged(picked);
                          formFieldState.didChange(picked);
                        }
                      },
                      child: Text(
                        date != null
                            ? DateFormat('dd/MM/yyyy').format(date)
                            : 'Selecionar',
                        style: TextStyle(
                          color: date != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      onChanged(null);
                      formFieldState.didChange(null);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  Widget buildDatePickerVencimento(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { print('DATA $date');
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'data vencimento obrigatória.';
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                errorText: formFieldState.errorText,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          onChanged(picked);
                          formFieldState.didChange(picked);
                        }
                      },
                      child: Text(
                        date != null
                            ? DateFormat('dd/MM/yyyy').format(date)
                            : 'Selecionar',
                        style: TextStyle(
                          color: date != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      onChanged(null);
                      formFieldState.didChange(null);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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


  void imprimirPDFRequisicao() async {
    if ((widget.vendabilhete != null)&&(widget.vendabilhete?.idvenda != 0)&&(widget.vendabilhete?.idvenda != null)){

      final pdf = pw.Document();
      final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

      final imageLogo = await imageFromAssetBundle('assets/logo.png'); // substitua pelo caminho correto do seu logo

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 1. Cabeçalho
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Empresa Exemplo Ltda.', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Rua das Flores, 123'),
                          pw.Text('Centro, Recife - PE, 50000-000'),
                          pw.Text('Tel: (81) 99999-9999  Cel: (81) 98888-8888'),
                          pw.Text('CNPJ: 12.345.678/0001-90  Email: contato@exemplo.com'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // 2. Título
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Text('REQUISIÇÃO', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
                    pw.Text('Nº 123456'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Data Emissão: $dataAtual'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('Cliente: João da Silva'),
                pw.Text('Av. Principal, 456, Apto 101, Boa Viagem, Recife - PE, 51000-000'),
                pw.SizedBox(height: 12),

                // 3. Observação
                pw.Text('Observação:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                // 4. Conteúdo da Observação
                pw.Text('Solicitação de emissão de bilhetes conforme acordado com o cliente.'),
                pw.SizedBox(height: 12),

                // 5. Lista de itens
                pw.Table.fromTextArray(
                  headers: ['PAX', 'Bilhete', 'Valor'],
                  data: [
                    ['1', '0001234567890', 'R\$ 200,00'],
                    ['2', '0001234567891', 'R\$ 220,00'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellHeight: 20,
                ),
                pw.SizedBox(height: 12),

                // 6. Totais
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Bilhetes: 2'),
                          pw.Text('Total Serviços: R\$ 50,00'),
                          pw.Text('Total Taxas: R\$ 30,00'),
                          pw.Text('Total Assentos: R\$ 40,00'),
                          pw.Text('Total Geral: R\$ 320,00'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Pagamento: Cartão de Crédito'),
                          pw.Text('Vencimento: 30/09/2025'),
                          pw.Text('Vendedor: Maria Vendedora'),
                          pw.Text('Emissor: José Emissor'),
                          pw.Text(''),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // 7. Assinaturas
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'Recebi(emos) de Empresa Exemplo Ltda., a(s) passagem(ns) discriminada(s), reconhecendo-o SOLICITAÇÃO Sr(a):',
                            textAlign: pw.TextAlign.justify,
                          ),
                          pw.SizedBox(height: 32),
                          pw.Divider(thickness: 1),
                          pw.Text('João Solicitante'),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 32),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text('Recife, 25 de setembro de 2025'),
                          pw.SizedBox(height: 32),
                          pw.Divider(thickness: 1),
                          pw.Text('João da Silva'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'requisicao.pdf',
      );
    }
  }


  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onTitulo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Títulos'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? imprimirPDFRequisicao : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Requisição'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onRecibo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Recibo'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onBilhete : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Bilhete'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onNovo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Nova Venda'),
        ),
        /*ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onEditar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
          child: const Text('Editar'),
        ),*/
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onSalvar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
        /*ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onCancelar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancelar'),
        ),*/
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onExcluir : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }


  Widget buildListView() {
    if (_itensVendaBilhete.isEmpty) {
      return const Center(child: Text('Nenhum bilhete encontrado.'));
    }

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
                //width: 1200,
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
      appBar: AppBar(title: const Text('Requisição de Bilhete')),
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
                              Expanded(child: buildDropdownFilial('Filial', selectedFilial, (value) => setState(() => selectedFilial = value), () => setState(() => selectedFilial = null), filiais)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDatePickerEmissao('Data Venda', dataVenda, (val) => setState(() => dataVenda = val))),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: buildDropdownCliente('Cliente', selectedCliente, (value) => setState(() => selectedCliente = value), () => setState(() => selectedCliente = null), clientes)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdown('C.Custo', selectedCCusto, (value) => setState(() => selectedCCusto = value), () => setState(() => selectedCCusto = null), ccustos)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDatePicker('Data Vencimento', dataVencimento, (val) => setState(() => dataVencimento = val))),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: buildDropdownVendedor('Vendedor', selectedVendedor, (value) => setState(() => selectedVendedor = value), () => setState(() => selectedVendedor = null), vendedores)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdownEmissor('Emissor', selectedEmissor, (value) => setState(() => selectedEmissor = value), () => setState(() => selectedEmissor = null), emissores)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdownMoeda('Moeda', selectedMoeda, (value) => setState(() => selectedMoeda = value), () => setState(() => selectedMoeda = null), moedas)),
                            ]),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(child: buildDropdownPagamento('Pagamento', selectedPagamento, (value) => setState(() => selectedPagamento = value), () => setState(() => selectedPagamento = null), pagamentos)),
                              const SizedBox(width: 16),
                              Expanded(child: buildDropdown('Grupo', selectedGrupo, (value) => setState(() => selectedGrupo = value), () => setState(() => selectedGrupo = null), grupos)),
                              const SizedBox(width: 16),
                              Expanded(child: TextFormField(controller: solicitanteController, decoration: const InputDecoration(labelText: 'Solicitante'),  
                                        //validator: (value) {
                                        //      if ((value == null || value.isEmpty) && (observacaoController.text.isEmpty)) {
                                        //        return 'Preencha o solicitante ou a observação';
                                        //      }
                                        //      return null;
                                        //},
                                        )),
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
