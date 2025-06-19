
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../services/vendahotel_service.dart';
import '../../services/entidade_service.dart';
import '../../services/itensvendahotel_service.dart';
import '../../services/acomodacao_service.dart';
import '../../services/tiposervico_service.dart';

import '../../models/vendahotel_model.dart';
import '../../models/itensvendahotel_model.dart';
import '../../models/acomodacao_model.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ItemVendaHotelForm extends StatefulWidget {
  final ItensVendaHotel? itemvendahotel;
  final int idVenda;
  final double? width;
  final double? height;
  

  const ItemVendaHotelForm({
    super.key,
    this.itemvendahotel,
    required this.idVenda,
    this.width,
    this.height,
  });

  @override
  _ItemVendaHotelFormState createState() => _ItemVendaHotelFormState();
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


class _ItemVendaHotelFormState extends State<ItemVendaHotelForm> {
  final _formKey = GlobalKey<FormState>();
  late ItensVendaHotel itensVendaHotelAtual;

  final nroController = TextEditingController();
  final nroVendaController = TextEditingController();
  final descricaoController = TextEditingController();
  final paxController = TextEditingController();
  final observacaoController = TextEditingController();
  final valorController = TextEditingController(text: '0,00');
  final taxaController = TextEditingController(text: '0,00');
  final servicoController = TextEditingController(text: '0,00');
  final outrosController = TextEditingController(text: '0,00');
  final extrasController = TextEditingController(text: '0,00');
  final valorfornecedorController = TextEditingController(text: '0,00');
  final comissaoController = TextEditingController(text: '0,00');

  final List<ItensVendaHotel> _itensVendaHotel = [];

  bool _isLoading = true;

  // Datas
  DateTime? dataFornecedor;
  DateTime? dataComissao;
  DateTime? dataPeriodoIni;
  DateTime? dataPeriodoFin;

  // Selecionados
  String? selectedOperadora;
  String? selectedAcomodacao;
  String? selectedFornecedor;
  String? selectedTipoServico;

  bool habilitaSalvarCancelar = true;

  List<Map<String, dynamic>> operadoras = [];
  List<Map<String, dynamic>> acomodacoes = [];
  List<Map<String, dynamic>> fornecedores = [];
  List<Map<String, dynamic>> tiposervicos = [];

  @override
  void initState() {
    super.initState();
    // Inicializa o objeto com o que vier do widget ou cria um novo
    itensVendaHotelAtual = widget.itemvendahotel ?? ItensVendaHotel();  
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
  void didUpdateWidget(covariant ItemVendaHotelForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemvendahotel != oldWidget.itemvendahotel) {
      setState(() {
        itensVendaHotelAtual = widget.itemvendahotel ?? ItensVendaHotel();
      });
    }
  }


  Future<void> _carregarDadosIniciais() async {
    await Future.delayed(const Duration(milliseconds: 500));
    nroVendaController.text = widget.idVenda.toString();
    // print('Item que chegou: ${itensVendaHotelAtual.toJson()}');
    final v = itensVendaHotelAtual;

    descricaoController.text = v.descricao?.toString() ?? '';
    paxController.text = v.pax?.toString() ?? '';
    observacaoController.text = v.observacao?.toString() ?? '';
    valorController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
    .format(v.valorhotel ?? 0.0);
    taxaController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
    .format(v.valortaxa ?? 0.0);
    servicoController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
    .format(v.valortaxaservico ?? 0.0);
    outrosController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
    .format(v.valoroutros ?? 0.0);
    extrasController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
    .format(v.valorextras ?? 0.0);
    valorfornecedorController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
    .format(v.valorfornecedor ?? 0.0);
 
    selectedOperadora = v.idoperadora?.toString();
    selectedFornecedor = v.idfornecedor?.toString();
    selectedAcomodacao = v.idacomodacao?.toString();
    selectedTipoServico = v.tiposervicohotelid?.toString();

    setState(() {}); // Garante que os dados sejam renderizados
    }


  Future<void> loadDropdownData() async {
      final operadorasResponse = await EntidadeService.getCiasDropDown();
      final acomodacoesResponse = await AcomodacaoService.getAcomodacoesDropDown();
      final fornecedoresResponse = await EntidadeService.getFornecedoresDropDown();
      final tiposervicosResponse = await TipoServicoService.getTipoServicoHoteisDropDown();

      //final tipovooResponse = await EntidadeService.getEmissoresDropDown();
      //final tipobilheteResponse = await MoedaService.getMoedasDropDown();

      setState(() {
        operadoras = operadorasResponse.map((f) => {'id': f.identidade, 'nome': f.nome}).toList();
        acomodacoes = acomodacoesResponse.map((g) => {'id': g.id, 'nome': g.nome}).toList();
        fornecedores = fornecedoresResponse.map((g) => {'id': g.identidade, 'nome': g.nome}).toList();
        tiposervicos = tiposervicosResponse.map((g) => {'id': g.id, 'nome': g.nome}).toList();

      });      
    setState(() {});
  }


  double parseValor(String valor) {
    return double.tryParse(valor.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
  }

/*
  void _reabrirFormularioAddBilhete({Map<String, dynamic>? itemvendahotel}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: ItemVendaHotelForm(
            idVenda: int.tryParse(nroVendaController.text) ?? 0,
            itemvendahotel: itemvendahotel != null ? ItensVendaHotel.fromJson(itemvendahotel) : null,
          ),
        ),
      ),
    );
  }
*/

  void limparCampos() {
    descricaoController.clear();
    observacaoController.clear();
    paxController.clear();
    valorController.text = '0,00';
    taxaController.text = '0,00';
    servicoController.text = '0,00';
    outrosController.text = '0,00';
    extrasController.text = '0,00';
    valorfornecedorController.text = '0,00';
    selectedOperadora = selectedFornecedor = selectedAcomodacao = selectedTipoServico = null;
    setState(() {});
  }

  
  void atualizarItensVendaHotel(ItensVendaHotel novo) {
    setState(() {
      itensVendaHotelAtual = novo;
    });
  }


  void onNovo() {

    limparCampos();

    var itensVendaHotelAux = ItensVendaHotel(
      //idvenda: null,
      id: null,
      valorhotel: null,
      valortaxa: null,
      valortaxaservico: null,
      valorcomissao: null,
      valorextras: null,
      valoroutros: null,
      valordu: null,
      valorcomisemissor: null,
      valorcomisvendedor: null,
      valordesconto: null,
      valorfornecedor: null,
      pax: '',
      observacao:  '',
      descricao:  '',
      tiposervico: '',
      datavencimento: null,
      datavencimentofor: null,
      idacomodacao: null,
      periodofin: null,
      periodoini: null,
      tiposervicohotelid: null,
      chave: '',
      idfornecedor: null,
      idoperadora: null,
    );

    atualizarItensVendaHotel(itensVendaHotelAux);

    //setState(() {
    //  Navigator.popUntil(context, (route) => route.isFirst);
    //  _reabrirFormularioAddBilhete();
    //});
  }


  void onSalvar() async{
    if (!_formKey.currentState!.validate()) {
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
              final itemvendahotel = ItensVendaHotel(
              idvenda: int.tryParse(nroVendaController.text) ?? 0,
              id: itensVendaHotelAtual.id ?? 0,
              valorhotel: parseValor(valorController.text),
              valortaxa: parseValor(taxaController.text),
              valortaxaservico: 0,
              valorcomissao: parseValor(servicoController.text),
              valoroutros: parseValor(outrosController.text),
              valorextras: parseValor(extrasController.text),
              valordu: 0,
              valorcomisemissor: 0,
              valorcomisvendedor: 0,
              valordesconto: 0,
              valorfornecedor: parseValor(valorfornecedorController.text),
              periodofin: dataPeriodoFin,
              periodoini: dataPeriodoIni,
              datavencimento: dataComissao,
              datavencimentofor: dataFornecedor,
              pax: paxController.text,
              observacao:  observacaoController.text,
              descricao:  descricaoController.text,
              chave: uuid.v4(),
              idfornecedor: selectedFornecedor!= null ? int.tryParse(selectedFornecedor!) : null,
              idoperadora: selectedOperadora != null ? int.tryParse(selectedOperadora!) : null,
              idacomodacao: selectedAcomodacao != null ? int.tryParse(selectedAcomodacao!) : null,
              tiposervicohotelid: selectedTipoServico != null ? int.tryParse(selectedTipoServico!) : null,
              );

              bool sucesso = false;
              if ((itensVendaHotelAtual.id == null)|| (itensVendaHotelAtual.id == 0)) {

                final idGerado = await ItemVendaHotelService.createItemVendaHotel(itemvendahotel);

                if (idGerado != null) {
                    nroController.text = idGerado.toString();
                    //print('Venda: ${jsonEncode(venda.toJson())}');
                    var itensVendaHotelAtual = ItensVendaHotel(
                    idvenda: int.tryParse(nroVendaController.text) ?? 0,
                    id: idGerado,
                    valorhotel: parseValor(valorController.text),
                    valortaxa: parseValor(taxaController.text),
                    valortaxaservico: 0,
                    valorcomissao: parseValor(servicoController.text),
                    valoroutros: parseValor(outrosController.text),
                    valorextras: parseValor(extrasController.text),
                    valordu: 0,
                    valorcomisemissor: 0,
                    valorcomisvendedor: 0,
                    valordesconto: 0,
                    valorfornecedor: parseValor(valorfornecedorController.text),
                    periodofin: dataPeriodoFin,
                    periodoini: dataPeriodoIni,
                    datavencimento: dataComissao,
                    datavencimentofor: dataFornecedor,
                    pax: paxController.text,
                    observacao:  observacaoController.text,
                    descricao:  descricaoController.text,
                    chave: uuid.v4(),
                    idfornecedor: selectedFornecedor!= null ? int.tryParse(selectedFornecedor!) : null,
                    idoperadora: selectedOperadora != null ? int.tryParse(selectedOperadora!) : null,
                    idacomodacao: selectedAcomodacao != null ? int.tryParse(selectedAcomodacao!) : null,
                    tiposervicohotelid: selectedTipoServico != null ? int.tryParse(selectedTipoServico!) : null,
                    );
                    
                    atualizarItensVendaHotel(itensVendaHotelAtual);                    
                    
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Serviço salvo com sucesso.'),
                        content: const Text('Deseja inserir outro serviço?'),
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

                //sucesso = await ItemVendaHotelService.createItemVendaHotel(itemvendahotel);
              } else {
                sucesso = await ItemVendaHotelService.updateItemVendaHotel(itemvendahotel);

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

    if ((itensVendaHotelAtual.id != 0)&&(itensVendaHotelAtual.id != null)){

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
              await ItemVendaHotelService.deleteItemVendaHotel(id);
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


  void onServico() {
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
                overflow: TextOverflow.ellipsis, //  Evita estouro
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


  Widget buildDropdownFornecedores(
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
              if (value == null && selectedFornecedor == null) {
                return 'fornecedor obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownTipoServicos(
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
              if (value == null && selectedTipoServico == null) {
                return 'tipo serviço obrigatório.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  Widget buildDropdownAcomodacoes(
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
            //validator: (value) {
            //  if (value == null && selectedAcomodacao == null) {
            //    return 'acomodação obrigatória.';
            //  }
            //  return null;
            //},

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }


  /// ---------------------------
  /// DatePicker
  /// ---------------------------
  Widget buildDatePickerPeriodoIni(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { print('DATA $date');
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'período inicial obrigatório.';
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

  Widget buildDatePickerPeriodoFin(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { print('DATA $date');
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'período final obrigatório.';
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

  Widget buildDatePickerFornecedor(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { print('DATA $date');
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'pagamento fornecedor obrigatório.';
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

  Widget buildDatePickerComissao(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { print('DATA $date');
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'recebimento comissão obrigatório.';
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

  Widget buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onChanged,
    bool isRequired = false,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: date != null ? DateFormat('dd/MM/yyyy').format(date) : '',
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: date != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(null),
              )
            : null,
      ),
      validator: (value) {
        if (isRequired && date == null) {
          return '$label obrigatório.';
        }
        return null;
      },
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
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
          onPressed: habilitaSalvarCancelar ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Impr.Trechos'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : null,
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
          onPressed: habilitaSalvarCancelar ?  () => onExcluir(itensVendaHotelAtual.id!) : null,
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
      appBar: AppBar(title: const Text('Add Serviço')),
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

                          buildDropdownTipoServicos(
                            'Tipo Serviço',
                            selectedTipoServico,
                            (value) => setState(() => selectedTipoServico = value),
                            () => setState(() => selectedTipoServico = null),
                            tiposervicos,
                          ),

                          buildDropdownOperadoras(
                            'Operadora',
                            selectedOperadora,
                            (value) => setState(() => selectedOperadora = value),
                            () => setState(() => selectedOperadora = null),
                            operadoras,
                          ),

                          buildDropdownFornecedores(
                            'Fornecedor',
                            selectedFornecedor,
                            (value) => setState(() => selectedFornecedor = value),
                            () => setState(() => selectedFornecedor = null),
                            fornecedores,
                          ),

                          buildDropdownAcomodacoes(
                            'Acomodação',
                            selectedAcomodacao,
                            (value) => setState(() => selectedAcomodacao = value),
                            () => setState(() => selectedAcomodacao = null),
                            acomodacoes,
                          ),

                          buildTextField('Descrição', descricaoController),
                          
                          buildTextFieldPax('Pax', paxController),

                          buildDatePicker(
                            label: 'Periodo Ini',
                            date: dataPeriodoIni,
                            onChanged: (val) => setState(() => dataPeriodoIni = val),
                            isRequired: true,
                          ),

                          buildDatePicker(
                            label: 'Periodo Fin',
                            date: dataPeriodoFin,
                            onChanged: (val) => setState(() => dataPeriodoFin = val),
                            isRequired: true,
                          ),

                          buildTextField('Observacao', observacaoController),

                          buildDatePicker(
                            label: 'Pagto.Fornecedor',
                            date: dataFornecedor,
                            onChanged: (val) => setState(() => dataFornecedor = val),
                            isRequired: true,
                          ),

                          buildDatePicker(
                            label: 'Receb.Comissão',
                            date: dataComissao,
                            onChanged: (val) => setState(() => dataComissao = val),
                            isRequired: true,
                          ),

                          buildTextFieldValorDecimal('Valor', valorController),

                          buildTextFieldValorDecimal('Comissão', comissaoController),

                          buildTextFieldValorDecimal('Tx.Serviço', servicoController),

                          buildTextFieldValorDecimal('Outras Taxas', outrosController),

                          buildTextFieldValorDecimal('Extras', extrasController),

                          buildTextFieldValorDecimal('Fornecedor', valorfornecedorController),

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

                       // const SizedBox(height: 6),

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