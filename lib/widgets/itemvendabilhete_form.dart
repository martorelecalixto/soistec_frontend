
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
import 'package:uuid/uuid.dart';

class ItemVendaBilheteForm extends StatefulWidget {
  final ItensVendaBilhete? itemvendabilhete;
  final int idVenda;
  final double? width;
  final double? height;
  

  const ItemVendaBilheteForm({
    super.key,
    this.itemvendabilhete,
    required this.idVenda,
    this.width,
    this.height,
  });

  @override
  _ItemVendaBilheteFormState createState() => _ItemVendaBilheteFormState();
}


class CentavosInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.parse(newText) / 100;

    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);

    String newString = formatter.format(value);

    return TextEditingValue(
      text: newString.trim(),
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}


class _ItemVendaBilheteFormState extends State<ItemVendaBilheteForm> {
  final _formKey = GlobalKey<FormState>();
  late ItensVendaBilhete itensVendaBilheteAtual;

  final nroVendaController = TextEditingController();
  final nroController = TextEditingController();
  final nrovooController = TextEditingController();
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
    // Inicializa o objeto com o que vier do widget ou cria um novo
    itensVendaBilheteAtual = widget.itemvendabilhete ?? ItensVendaBilhete();  
    _init();
  }


  void _init() async {
    setState(() => _isLoading = true);
    await loadDropdownData(); // Aguarda dropdowns
    await _carregarDadosIniciais(); // Só então carrega os dados
    setState(() => _isLoading = false);
  } 

  // Se quiser que o estado reaja caso o widget pai mude o objeto
  @override
  void didUpdateWidget(covariant ItemVendaBilheteForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemvendabilhete != oldWidget.itemvendabilhete) {
      setState(() {
        itensVendaBilheteAtual = widget.itemvendabilhete ?? ItensVendaBilhete();
      });
    }
  }


  Future<void> _carregarDadosIniciais() async {
    await Future.delayed(const Duration(milliseconds: 500));
    nroVendaController.text = widget.idVenda.toString();
    // print('Item que chegou: ${itensVendaBilheteAtual.toJson()}');
    if (itensVendaBilheteAtual != null) {
      final v = itensVendaBilheteAtual!;

      nroController.text = v.id?.toString() ?? '';
      bilheteController.text = v.bilhete?.toString() ?? '';
      trechoController.text = v.trecho?.toString() ?? '';
      nrovooController.text = v.voo?.toString() ?? '';
      paxController.text = v.pax?.toString() ?? '';
      observacaoController.text = v.observacao?.toString() ?? '';
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
      //final tipovooResponse = await EntidadeService.getEmissoresDropDown();
      //final tipobilheteResponse = await MoedaService.getMoedasDropDown();

      setState(() {
        operadoras = operadorasResponse.map((f) => {'id': f.identidade, 'nome': f.nome}).toList();
        cias = ciasResponse.map((c) => {'id': c.identidade, 'nome': c.nome}).toList();
        voos = voosResponse.map((m) => {'id': m.identidade, 'nome': m.nome}).toList();

        /// Tipos de Voo fixos
        tipovoo = [
          {'id': 'NACIONAL', 'nome': 'NACIONAL'},
          {'id': 'INTERNACIONAL', 'nome': 'INTERNACIONAL'},
        ];

        /// Tipos de Bilhete fixos
        tipobilhete = [
          {'id': 'NORMAL', 'nome': 'NORMAL'},
          {'id': 'CONJUGADO', 'nome': 'CONJUGADO'},
          {'id': 'SUBSTITUTO', 'nome': 'SUBSTITUTO'},
          {'id': 'INCREMENTO', 'nome': 'INCREMENTO'},
        ];

        //tipovoo = tipovooResponse.map((c) => {'id': c.identidade, 'nome': c.nome}).toList();
        //tipobilhete = tipobilheteResponse.map((v) => {'id': v.idmoeda, 'nome': v.nome}).toList();
      });      
    setState(() {});
  }


  double parseValor(String valor) {
    return double.tryParse(valor.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
  }


  void _reabrirFormularioAddBilhete({Map<String, dynamic>? itemvendabilhete}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: ItemVendaBilheteForm(
            idVenda: int.tryParse(nroVendaController.text) ?? 0,
            itemvendabilhete: itemvendabilhete != null ? ItensVendaBilhete.fromJson(itemvendabilhete) : null,
          ),
        ),
      ),
    );
  }


  void limparCampos() {
    nroController.clear();
    bilheteController.clear();
    observacaoController.clear();
    paxController.clear();
    trechoController.clear();
    nrovooController.clear();
    valorController.text = '0,00';
    taxaController.text = '0,00';
    servicoController.text = '0,00';
    assentoController.text = '0,00';
    selectedOperadora = selectedCia = selectedVoo = selectedTipoBilhete =
    selectedTipoVoo = null;
    setState(() {});
  }

  
  void atualizarItensVendaBilhete(ItensVendaBilhete novo) {
    setState(() {
      itensVendaBilheteAtual = novo;
    });
  }


  void onNovo() {

    limparCampos();

    var itensVendaBilheteAux = ItensVendaBilhete(
     // idvenda: null,
      id: null,
      valorbilhete: null,
      valortaxabilhete: null,
      valorassento: null,
      valortaxaservico: null,
      valorcomisagente: null,
      valorcomisemissor: null,
      valorcomisvendedor: null,
      valordesconto: null,
      valorfornecedor: null,
      valornet: null,
      valortotal: null,
      pax: '',
      observacao:  '',
      trecho:  '',
      bilhete:  '',
      cancelado: false,
      chave: '',
      idciaaerea: null,
      idoperadora: null,
      tipobilhete: '',
      tipovoo: '',
      voo: '',
    );

    atualizarItensVendaBilhete(itensVendaBilheteAux);

    //setState(() {
    //  Navigator.popUntil(context, (route) => route.isFirst);
    //  _reabrirFormularioAddBilhete();
    //});
  }


  void onSalvar() async{
    if (!_formKey.currentState!.validate()) {
      //print('Campos obrigatórios não preenchidos.');
      return; // Sai da função e não executa mais nada.
    }else{
        try{
            var uuid = Uuid();
            final prefs = await SharedPreferences.getInstance();
            final empresa = prefs.getString('empresa');

            if (empresa == null || empresa.isEmpty) {
              throw Exception('Empresa não definida nas preferências.');
            }

            if (_formKey.currentState!.validate()) {
              final itemvendabilhete = ItensVendaBilhete(
              idvenda: int.tryParse(nroVendaController.text) ?? 0,
              id: itensVendaBilheteAtual?.id ?? 0,
              valorbilhete: parseValor(valorController.text),
              valortaxabilhete: parseValor(taxaController.text),
              valorassento: parseValor(assentoController.text),
              valortaxaservico: parseValor(servicoController.text),
              valorcomisagente: 0,
              valorcomisemissor: 0,
              valorcomisvendedor: 0,
              valordesconto: 0,
              valorfornecedor: 0,
              valornet: 0,
              valortotal: 0,
              pax: paxController.text,
              observacao:  observacaoController.text,
              trecho:  trechoController.text,
              bilhete:  bilheteController.text,
              cancelado: false,
              chave: uuid.v4(),
              idciaaerea: selectedCia != null ? int.tryParse(selectedCia!) : null,
              idoperadora: selectedOperadora != null ? int.tryParse(selectedOperadora!) : null,
              tipobilhete: selectedTipoBilhete != '' ? selectedTipoBilhete! : '',
              tipovoo: selectedTipoVoo != '' ? selectedTipoVoo! : '',
              voo: nrovooController.text,
              );

              bool sucesso = false;
              if ((itensVendaBilheteAtual?.id == null)|| (itensVendaBilheteAtual?.id == 0)) {

                final idGerado = await ItemVendaBilheteService.createItemVendaBilhete(itemvendabilhete);

                if (idGerado != null) {
                    nroController.text = idGerado.toString();
                    //final item = await ItemVendaBilheteService.getItensVendaBilheteById(idGerado.toString());
                    //_reabrirFormularioAddBilhete(itemvendabilhete: item.toJson());
                    //print('Venda: ${jsonEncode(venda.toJson())}');
                    var itensVendaBilheteAtual = ItensVendaBilhete(
                    idvenda: int.tryParse(nroVendaController.text) ?? 0,
                    id: idGerado,
                    valorbilhete: parseValor(valorController.text),
                    valortaxabilhete: parseValor(taxaController.text),
                    valorassento: parseValor(assentoController.text),
                    valortaxaservico: parseValor(servicoController.text),
                    valorcomisagente: 0,
                    valorcomisemissor: 0,
                    valorcomisvendedor: 0,
                    valordesconto: 0,
                    valorfornecedor: 0,
                    valornet: 0,
                    valortotal: 0,
                    pax: paxController.text,
                    observacao:  observacaoController.text,
                    trecho:  trechoController.text,
                    bilhete:  bilheteController.text,
                    cancelado: false,
                    chave: uuid.v4(),
                    idciaaerea: selectedCia != null ? int.tryParse(selectedCia!) : null,
                    idoperadora: selectedOperadora != null ? int.tryParse(selectedOperadora!) : null,
                    tipobilhete: selectedTipoBilhete != '' ? selectedTipoBilhete! : '',
                    tipovoo: selectedTipoVoo != '' ? selectedTipoVoo! : '',
                    voo: nrovooController.text,
                    );
                    
                    atualizarItensVendaBilhete(itensVendaBilheteAtual);                    
                    
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Bilhete salvo com sucesso.'),
                        content: const Text('Deseja inserir outro bilhete?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
                        ],
                      ),
                    );

                    if(confirmar == true){
                      onNovo();
                    }

                    setState(() {
                    });
                }  

                //sucesso = await ItemVendaBilheteService.createItemVendaBilhete(itemvendabilhete);
              } else {
                //print('ENTROU UPDATE');
                sucesso = await ItemVendaBilheteService.updateItemVendaBilhete(itemvendabilhete);

                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Informação.'),
                    content: const Text('Requisição salva com sucesso.'),
                    actions: [
                      //TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
                    ],
                  ),
                );

              }

              if (sucesso) {
               // Navigator.pop(context, true);
              } else {
                // Trate o erro conforme necessário
              }
            }

            setState(() {
             // habilitaSalvarCancelar = false;
            });

        } catch (e) {
          print('Erro de conexão: $e ');
        }    
    }

  }


  void onExcluir(int? id) async{

    if ((itensVendaBilheteAtual?.id != 0)&&(itensVendaBilheteAtual?.id != null)){

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Deseja realmente excluir registro ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
          ],
        ),
      );
      if (confirmar == true) {
          try {
            if(id != null){
              await ItemVendaBilheteService.deleteItemVendaBilhete(id);
              //mostrarMensagem(context, 'Venda excluída com sucesso!', titulo: 'Sucesso');
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Sucesso'),
                    content: const Text('Registro excluído com sucesso!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );              
              
              Navigator.pop(context, true);
            }

          } catch (e) {
            if (e is ApiException) {
              mostrarMensagem(context, e.message, titulo: 'Erro');
            } else {
              mostrarMensagem(context, 'Erro inesperado: $e', titulo: 'Erro');
            }
          }

      }


    }
  }


  void onTitulo() {
    // TODO: lógica do botão Títulos
  }


  void onBilhete() {
    // TODO: lógica do botão Bilhete
    
  }

  /// ---------------------------
  /// Dropdown
  /// ---------------------------
  Widget buildDropdown(
    String label,
    String? selectedValue,
    Function(String?) onChanged,
    VoidCallback onClear,
    List<Map<String, dynamic>> options,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // 🔥 Isso resolve o estouro
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: selectedValue != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
      ),
      items: options
          .map(
            (item) => DropdownMenuItem<String>(
              value: item['id'].toString(),
              child: Text(
                item['nome'],
                overflow: TextOverflow.ellipsis, // 🔥 Evita estouro
                softWrap: false,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
  

  Widget buildDropdownOperadoras(
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
              if (value == null && selectedOperadora == null) {
                return 'operadora obrigatória.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownCias(
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
              if (value == null && selectedCia == null) {
                return 'cia obrigatória.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownTipoVoo(
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
              if (value == null && selectedTipoVoo == null) {
                return 'tipo voo obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownTipoBilhete(
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
              if (value == null && selectedTipoBilhete == null) {
                return 'tipo bilhete obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }

  /// ---------------------------
  /// Layout Responsivo
  /// ---------------------------
  Widget buildFieldGroup(BoxConstraints constraints, List<Widget> fields) {
    double maxWidth = constraints.maxWidth;

    int columns;
    if (maxWidth >= 1400) {
      columns = 4;
    } else if (maxWidth >= 1000) {
      columns = 3;
    } else if (maxWidth >= 600) {
      columns = 2;
    } else {
      columns = 1;
    }

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 6, // 🔥 Controle da altura (quanto maior, mais achatado)
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: fields,
    );
  }

  /// ---------------------------
  /// Campo de Texto
  /// ---------------------------
  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }


  Widget buildTextFieldPax(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
           if ((value == null || value.isEmpty)) {
              return 'Pax obrigatório.';
            }
            return null;
      },      
    );
  }


  Widget buildTextFieldBilhete(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
     int maxLength = 8,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
       maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '', // Oculta o contador (opcional)
      ),
      validator: (value) {
           if ((value == null || value.isEmpty)) {
              return 'Bilhete obrigatório.';
            }
            return null;
      },      
    );
  }


  Widget buildTextFieldTrecho(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
           if ((value == null || value.isEmpty)) {
              return 'Trecho obrigatório.';
            }
            return null;
      },      
    );
  }


  Widget buildTextFieldValorDecimal(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Só números
        CentavosInputFormatter(), // Formata para 0,00
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '', // opcional, remove contador
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Valor não pode ser nulo.';
        }
        return null;
      },
    );
  }


  /// ---------------------------
  /// Botões
  /// ---------------------------
  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onTitulo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Impr.Trechos'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onTitulo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Trechos'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onNovo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Novo'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onSalvar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ?  () => onExcluir(itensVendaBilheteAtual!.id!) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }

  /// ---------------------------
  /// Build Geral
  /// ---------------------------
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        buildFieldGroup(constraints, [

                          buildDropdownOperadoras(
                            'Operadora',
                            selectedOperadora,
                            (value) => setState(() => selectedOperadora = value),
                            () => setState(() => selectedOperadora = null),
                            operadoras,
                          ),

                          buildDropdownCias(
                            'Cia',
                            selectedCia,
                            (value) => setState(() => selectedCia = value),
                            () => setState(() => selectedCia = null),
                            cias,
                          ),

                          buildTextField('Nro Voo', nrovooController),
                          
                          buildDropdownTipoBilhete(
                            'T.Bilhete',
                            selectedTipoBilhete,
                            (value) => setState(() => selectedTipoBilhete = value),
                            () => setState(() => selectedTipoBilhete = null),
                            tipobilhete,
                          ),
                          
                          buildDropdownTipoVoo(
                            'T.Voo',
                            selectedTipoVoo,
                            (value) => setState(() => selectedTipoVoo = value),
                            () => setState(() => selectedTipoVoo = null),
                            tipovoo,
                          ),
                          
                          buildTextFieldBilhete('Bilhete', bilheteController),

                          buildTextFieldPax('Pax', paxController),

                          buildTextFieldTrecho('Trecho', trechoController),

                          buildTextField('Observacao', observacaoController),

                          buildTextFieldValorDecimal('Valor', valorController),

                          buildTextFieldValorDecimal('Taxa', taxaController),

                          buildTextFieldValorDecimal('Serviço', servicoController),

                          buildTextFieldValorDecimal('Assento', assentoController),

                          Visibility(
                            visible: false,
                            maintainState: true,
                            maintainAnimation: true,
                            maintainSize: true,
                            child: buildFieldGroup(constraints, [
                              buildTextField('Nro', nroController, readOnly: true),
                            ]),
                          ),  

                          Visibility(
                            visible: false,
                            maintainState: true,
                            maintainAnimation: true,
                            maintainSize: true,
                            child: buildFieldGroup(constraints, [
                              buildTextField('Nro', nroVendaController, readOnly: true),
                            ]),
                          ),                      


                        ]),

                        const SizedBox(height: 24),

                        ///  Botões
                        buildButtonsRow(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }


  void mostrarMensagem(BuildContext context, String mensagem, {String titulo = 'Atenção'}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


}
