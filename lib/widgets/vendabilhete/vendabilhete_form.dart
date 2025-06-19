
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/tituloreceber_model.dart';
import '../../services/tituloreceber_service.dart';
import '../../widgets/vendabilhete/vendabilhetetitulos_form.dart';

import '../../services/filial_service.dart';
import '../../services/moeda_service.dart';
import '../../services/entidade_service.dart';
import '../../services/vendabilhete_service.dart';
import '../../services/formapagamento_service.dart';
import '../../services/grupo_service.dart';
import '../../services/centrocusto_service.dart';
import '../../services/itensvendabilhete_service.dart';
import '../../services/incvendabilhete_service.dart';
import '../../services/reciboreceber_service.dart';
import '../../services/increciboreceber_service.dart';
import '../../services/inctituloreceber_service.dart';

import '../../models/centrocusto_model.dart';
import '../../models/vendabilhete_model.dart';
import '../../models/itensvendabilhete_model.dart';
import '../../models/reciboreceber_model.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/vendabilhete/itemvendabilhete_form.dart';

String _formatarData(dynamic data) {
  try {
    if (data == null || data.toString().isEmpty) return '';
    final date = DateTime.tryParse(data.toString());
    if (date == null) return data.toString();
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return data.toString();
  }
}

String _formatarMoeda(dynamic valor) {
  if (valor == null) return '';
  try {
    final numero = double.tryParse(valor.toString()) ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(numero);
  } catch (e) {
    return '';
  }
}

String formatarDataPorExtenso(DateTime data) {
  const List<String> meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
  ];

  String dia = data.day.toString().padLeft(2, '0');
  String mes = meses[data.month - 1];
  String ano = data.year.toString();

  return '$dia de $mes de $ano';
}

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

class CentavosInputFormatter extends TextInputFormatter {
  final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
    locale: 'pt_BR',
    decimalDigits: 2,
    name: '',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) digitsOnly = '0';

    double value = double.parse(digitsOnly) / 100.0;

    final newText = currencyFormat.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _VendaBilheteFormState extends State<VendaBilheteForm> {
  final _formKey = GlobalKey<FormState>();

  late VendaBilhete vendaBilheteAtual;

  final nroController = TextEditingController();
  final solicitanteController = TextEditingController();
  final observacaoController = TextEditingController();
  final faturaController = TextEditingController();
  final reciboController = TextEditingController();
  final valorEntradaController = TextEditingController(text: '0,00');
  final valorTotalController = TextEditingController(text: '0,00');
  final descontoTotalController = TextEditingController(text: '0,00');
 
  List<ItensVendaBilhete> _itensVendaBilhete = [];
  final List<Map<String, dynamic>> _tituloreceber = [];


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
  bool bloquearRequisicao = false;

  List<Map<String, dynamic>> filiais = [];
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> moedas = [];
  List<Map<String, dynamic>> ccustos = [];
  List<Map<String, dynamic>> vendedores = [];
  List<Map<String, dynamic>> emissores = [];
  List<Map<String, dynamic>> pagamentos = [];
  List<Map<String, dynamic>> grupos = [];

  int idReq = 0;
  int idRec = 0;
  int idTit = 0;

  @override
  void initState() {
    super.initState();
    // Inicializa o objeto com o que vier do widget ou cria um novo
    vendaBilheteAtual = widget.vendabilhete ?? VendaBilhete();    
    _init();
  }


  void _init() async {
    setState(() => _isLoading = true);
    await loadDropdownData(); // Aguarda dropdowns
    await _carregarDadosIniciais(); // Só então carrega os dados
    setState(() => _isLoading = false);
  }  

  
  void atualizarVendaBilheteAtual(VendaBilhete novo) {
    setState(() {
      vendaBilheteAtual = novo;
    });
  }


  void atualizarValorTotalVenda() async{
    var uuid = Uuid();
    double total = getTotalVenda();
    //print(total.toString());

    var vendabilhete = VendaBilhete(
        idvenda: vendaBilheteAtual.idvenda ?? 0,
        id: vendaBilheteAtual.id,
        datavenda: vendaBilheteAtual.datavenda,
        idreciboreceber: vendaBilheteAtual.idreciboreceber != 0 ? vendaBilheteAtual.idreciboreceber : null,//vendaBilheteAtual.idreciboreceber,
        datavencimento: vendaBilheteAtual.datavencimento,
        documento: '', // ou algum campo se houver
        valortotal: total,
        descontototal: vendaBilheteAtual.descontototal,
        valorentrada: vendaBilheteAtual.valorentrada,
        observacao: vendaBilheteAtual.observacao,
        solicitante: vendaBilheteAtual.solicitante,
        identidade: vendaBilheteAtual.identidade,
        idvendedor: vendaBilheteAtual.idvendedor,
        idemissor: vendaBilheteAtual.idemissor,
        idmoeda: vendaBilheteAtual.idmoeda,
        idformapagamento: vendaBilheteAtual.idformapagamento,
        idfilial: vendaBilheteAtual.idfilial,
        idfatura: vendaBilheteAtual.idfatura != 0 ? vendaBilheteAtual.idfatura : null,//vendaBilheteAtual.idfatura,
        chave: uuid.v4(),
        empresa: vendaBilheteAtual.empresa,
        idcentrocusto: vendaBilheteAtual.idcentrocusto != 0 ? vendaBilheteAtual.idcentrocusto : null,//vendaBilheteAtual.idcentrocusto,
        idgrupo: vendaBilheteAtual.idgrupo != 0 ? vendaBilheteAtual.idgrupo : null,//vendaBilheteAtual.idgrupo,
        excluido: false,
      );

    bool sucesso = await VendaBilheteService.updateVendaBilhete(vendabilhete);
    setState(() {
      valorTotalController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
          .format(total ?? 0.0);//total.toString();
    });    

      //atualizarVendaBilheteAtual(vendabilhete);    
  }


  void onSalvarTitulo() async{
    if (!_formKey.currentState!.validate()) {
      return; // Sai da função e não executa mais nada.
    }else{
        if ((vendaBilheteAtual.idvenda != null)|| (vendaBilheteAtual.idvenda != 0)) {
         
          //Deletar titulos existentes
          await TituloReceberService.deleteTituloReceberByVendaBilhete(vendaBilheteAtual.idvenda!);
          

          final meioPagamento = await FormaPagamentoService.getFormaPagamentoById(vendaBilheteAtual.idformapagamento.toString());
          
          if(meioPagamento.gerartitulovenda == true){
           
           try{
              var uuid = Uuid();
              final prefs = await SharedPreferences.getInstance();
              final empresa = prefs.getString('empresa');
              final idempresa = prefs.getInt('idempresa');

              if (empresa == null || empresa.isEmpty) {
                throw Exception('Empresa não definida nas preferências.');
              }

              //BuscarId//
              if (idempresa != null) {
                  idTit = await IncTituloRecService.incTituloRec(idempresa);
              } else {
                throw Exception('ID da empresa não encontrado.');
              }

             // if (_formKey.currentState!.validate()) {
              final titulo = TituloReceber(
                idtitulo: null,
                id: idTit,
                dataemissao: dataVenda,
                datavencimento: dataVencimento,
                datacompetencia: dataVencimento,
                documento: 'Requisição bilhete Nº ${nroController.text}', // ou algum campo se houver
                valor: parseValor(valorTotalController.text),
                valorpago: 0,
                descontopago: 0,
                juropago: 0,
                parcela: 1,
                descricao: observacaoController.text,
                identidade: selectedCliente != null ? int.tryParse(selectedCliente!) : null,
                idmoeda: selectedMoeda != null ? int.tryParse(selectedMoeda!) : null,
                idformapagamento: selectedPagamento != null ? int.tryParse(selectedPagamento!) : null,
                idfilial: selectedFilial != null ? int.tryParse(selectedFilial!) : null,
                idfatura: null,
                idvendabilhete: vendaBilheteAtual.idvenda!,
                chave: uuid.v4(),
                empresa: empresa,
                idcentrocusto: selectedCCusto != null ? int.tryParse(selectedCCusto!) : null,
              );

                bool sucesso = false;
                //if ((vendaBilheteAtual?.idvenda == null)|| (vendaBilheteAtual?.idvenda == 0)) {

                final idGerado = await TituloReceberService.createTituloReceber(titulo);
                if (idGerado != null) {
                  
                    setState(() {
                    });
                }  

              setState(() {
                habilitaSalvarCancelar = true;
              });

            } catch (e) {
              print('Erro de conexão: $e');
            }  
            

          }// Se pagamento gera titulo na venda
        }// Se idvenda > 0
    }
  }

  // Se quiser que o estado reaja caso o widget pai mude o objeto
  @override
  void didUpdateWidget(covariant VendaBilheteForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vendabilhete != oldWidget.vendabilhete) {
      setState(() {
        vendaBilheteAtual = widget.vendabilhete ?? VendaBilhete();
      });
    }
  }


  void _abrirFormularioAddBilhete({Map<String, dynamic>? itemvendabilhete,}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: ItemVendaBilheteForm(
            idVenda: int.tryParse(vendaBilheteAtual.idfatura.toString()) ?? 0, //widget.vendabilhete!.idvenda.toString()) ?? 0
            idFatura: int.tryParse(vendaBilheteAtual.idreciboreceber.toString()) ?? 0,
            idReciboReceber: int.tryParse(vendaBilheteAtual.idvenda.toString()) ?? 0,
            itemvendabilhete: itemvendabilhete != null ? ItensVendaBilhete.fromJson(itemvendabilhete) : null,
          ),
        ),
      ),
    );

    // Atualizar Listview
    await _carregarDadosIniciais();

    atualizarValorTotalVenda();

  }


  void _abrirFormularioTitulo({Map<String, dynamic>? tituloreceber,}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: VendaBilheteTitulosForm(
            idvenda: int.tryParse(vendaBilheteAtual.idvenda.toString()) ?? 0, //widget.vendabilhete!.idvenda.toString()) ?? 0
            //tituloreceber: tituloreceber != null ? TituloReceber.fromJson(tituloreceber) : null,
          ),
        ),
      ),
    );

    // Atualizar Listview
    await _carregarDadosIniciais();

    atualizarValorTotalVenda();

  }


  void limparCampos() async {
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
    _itensVendaBilhete = await ItemVendaBilheteService.getItensVendaBilheteByIdVenda(idvenda: 0);
    setState(() {});
  }


  void onNovo() {

    limparCampos();

    idReq = 0;

    var vendaBilheteAux = VendaBilhete(
          idvenda: null,
          id: null,
          datavenda: null,
          datavencimento: null,
          documento: '', // ou algum campo se houver
          valortotal: 0,
          descontototal: 0,
          valorentrada: 0,
          observacao: '',
          solicitante: '',
          identidade: null,
          idvendedor: null,
          idemissor: null,
          idmoeda: null,
          idformapagamento: null,
          idfilial: null,
          idfatura: null,
          idreciboreceber: null,
          chave: '',
          excluido: false,
          empresa: '',
          idcentrocusto: null,
          idgrupo: null,
        );

        atualizarVendaBilheteAtual(vendaBilheteAux);

  }


  void onSalvar() async{
    if (!_formKey.currentState!.validate()) {
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
            if ((vendaBilheteAtual.idvenda == null)|| (vendaBilheteAtual.idvenda == 0)) {
              idReq = await IncVendaBilheteService.incVendaBilhete(idempresa);
              nroController.text = idReq.toString();
            }else{ 
                idReq = vendaBilheteAtual.id ?? 0;
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
              idvenda: vendaBilheteAtual.idvenda ?? 0,
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
              idfatura: int.tryParse(faturaController.text) != 0 ? int.tryParse(faturaController.text) : null,
              idreciboreceber: int.tryParse(reciboController.text) != 0 ? int.tryParse(reciboController.text) : null,
              chave: uuid.v4(),
              excluido: false,
              empresa: empresa,
              idcentrocusto: selectedCCusto != null ? int.tryParse(selectedCCusto!) : null,
              idgrupo: selectedGrupo != null ? int.tryParse(selectedGrupo!) : null,
            );

            bool sucesso = false;
            if ((vendaBilheteAtual.idvenda == null)|| (vendaBilheteAtual.idvenda == 0)) {

                final idGerado = await VendaBilheteService.createVendaBilhete(vendabilhete);
                if (idGerado != null) {
                  
                  var vendaBilheteAux = VendaBilhete(
                        idvenda: idGerado,
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

                      atualizarVendaBilheteAtual(vendaBilheteAux);

                     // if(parseValor(valorTotalController.text) > 0)
                     //   onSalvarTitulo();

                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirmação'),
                          content: const Text('Requisição salva com sucesso'),
                          actions: [
                           // TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
                          ],
                        ),
                      );

                      AddBilhete();

                    //print('Venda: ${jsonEncode(venda.toJson())}');
                    setState(() {
                    });
                }  

            } else {
             
              sucesso = await VendaBilheteService.updateVendaBilhete(vendabilhete);
              
              //print(vendabilhete.toJson());
              atualizarVendaBilheteAtual(vendabilhete);
            

              if(parseValor(valorTotalController.text) > 0)
              { 
                onSalvarTitulo();
              }

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
              //Navigator.pop(context, true);
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


  void onExcluir(int? idvenda) async{
    if ((vendaBilheteAtual.idvenda != 0)&&(vendaBilheteAtual.idvenda != null)){

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Deseja realmente excluir esta venda?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
          ],
        ),
      );
      if (confirmar == true) {
          try {
            if(idvenda != null){
              await VendaBilheteService.deleteVendaBilhete(idvenda);
              //mostrarMensagem(context, 'Venda excluída com sucesso!', titulo: 'Sucesso');
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Sucesso'),
                    content: const Text('Venda excluída com sucesso!'),
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


  void onExcluirItem(int? id) async{
    
    if ((id != 0)&&(id != null)){

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
            
            _carregarDadosIniciais();
           // _reabrirFormularioRequisicao(vendabilhete: widget.vendabilhete?.toJson());
            //Navigator.pop(context, true);
          
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


  void onTitulo() async {
        // Itens da venda atualiza separado para evitar travar UI
///    final tituloreceber = await TituloReceberService.getTituloReceberByVendaBilhete(
 //     vendaBilheteAtual.idvenda.toString()
 //   );

   // _abrirFormularioTitulo(tituloreceber: tituloreceber.toJson());
    
  }


  void onRecibo() {
    // TODO: lógica do botão Recibo
  }


  void onSalvarRecibo() async{
    if (!_formKey.currentState!.validate()){
      return; // Sai da função e não executa mais nada.
    }else{
        try{
          // TODO: lógica do botão Salvar
          var uuid = Uuid();
          final prefs = await SharedPreferences.getInstance();
          final empresa = prefs.getString('empresa');
          final idempresa = prefs.getInt('idempresa');

          if (empresa == null || empresa.isEmpty) {
            throw Exception('Empresa não definida nas preferências.');
          }

          //BuscarId//
          if (idempresa != null) {
            if ((vendaBilheteAtual.idreciboreceber == null)|| (vendaBilheteAtual.idreciboreceber == 0)) {
              idRec = await IncReciboRecService.incReciboRec(idempresa);
              reciboController.text = idRec.toString();
              String? nomeCliente = getClienteSelecionado(selectedCliente, clientes);
              final descricao = gerarTextoRecibo(nomeCliente: getClienteSelecionado(selectedCliente, clientes)!, valor: valorTotalController.text, formaPagamento: getPagamentoSelecionado(selectedPagamento, pagamentos)!, itensVenda: _itensVendaBilhete);

              if (_formKey.currentState!.validate()) {
                final recibo = ReciboReceber(
                  id: idRec,
                  identidade: selectedCliente != null ? int.tryParse(selectedCliente!) : null,
                  idmoeda: selectedMoeda != null ? int.tryParse(selectedMoeda!) : null,
                  idfilial: selectedFilial != null ? int.tryParse(selectedFilial!) : null,
                  chave: uuid.v4(),
                  empresa: empresa,
                  valor: parseValor(valorTotalController.text),
                  descricao: descricao,
                  dataemissao: DateTime.now(),
                );

                final idReciboGerado = await ReciboReceberService.createReciboReceber(recibo);

                var vendabilheterecibo = VendaBilhete(
                  idvenda: vendaBilheteAtual.idvenda ?? 0,
                  id: vendaBilheteAtual.id,
                  datavenda: vendaBilheteAtual.datavenda,
                  idreciboreceber: idReciboGerado,
                  datavencimento: vendaBilheteAtual.datavencimento,
                  documento: '', // ou algum campo se houver
                  valortotal: vendaBilheteAtual.valortotal,
                  descontototal: vendaBilheteAtual.descontototal,
                  valorentrada: vendaBilheteAtual.valorentrada,
                  observacao: vendaBilheteAtual.observacao,
                  solicitante: vendaBilheteAtual.solicitante,
                  identidade: vendaBilheteAtual.identidade,
                  idvendedor: vendaBilheteAtual.idvendedor,
                  idemissor: vendaBilheteAtual.idemissor,
                  idmoeda: vendaBilheteAtual.idmoeda,
                  idformapagamento: vendaBilheteAtual.idformapagamento,
                  idfilial: vendaBilheteAtual.idfilial,
                  idfatura: vendaBilheteAtual.idfatura,
                  chave: uuid.v4(),//vendaBilheteAtual.chave,
                  empresa: vendaBilheteAtual.empresa,
                  idcentrocusto: vendaBilheteAtual.idcentrocusto,
                  idgrupo: vendaBilheteAtual.idgrupo,
                  excluido: false,
                );

                reciboController.text = idReciboGerado.toString();

                bool sucessoRecibo = await VendaBilheteService.updateVendaBilhete(vendabilheterecibo);

                atualizarVendaBilheteAtual(vendabilheterecibo);
                    
                onImprimirRecibo();

              }

            }else{ 
                idRec= vendaBilheteAtual.idreciboreceber ?? 0;
                //reciboController.text = idRec.toString();     
                onImprimirRecibo();                   
              }

          } else {
            throw Exception('ID da empresa não encontrado.');
          }


          setState(() {
            habilitaSalvarCancelar = true;
          });

        } catch (e) {
          print('Erro de conexão: $e');
        }    
    }

  }


  void onImprimirRecibo() async{
    if ((vendaBilheteAtual.idreciboreceber != 0)&&(vendaBilheteAtual.idreciboreceber != null)){

      double totalValorBilhete = 0;
      double totalValorTaxaBilhete = 0;
      double totalValorTaxaServico = 0;
      double totalValorAssento = 0;
      double totalGeral = 0;

      for (var item in _itensVendaBilhete) {
        totalValorBilhete += item.valorbilhete ?? 0;
        totalValorTaxaBilhete += item.valortaxabilhete ?? 0;
        totalValorTaxaServico += item.valortaxaservico ?? 0;
        totalValorAssento += item.valorassento ?? 0;
      }

      totalGeral = totalValorBilhete + totalValorTaxaBilhete + totalValorTaxaServico + totalValorAssento;
      /*###################################################*/
      final pdf = pw.Document();
      //final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final enderecoFilial = await FilialService.getFilialById(vendaBilheteAtual.idfilial.toString());
      //final enderecoEntidade = await EntidadeService.getEntidadeById(vendaBilheteAtual!.identidade.toString());
      final  recibo = await ReciboReceberService.getReciboReceberById(vendaBilheteAtual.idreciboreceber.toString());
      //final cnpj = await EntidadeService.getEntidadeById(vendaBilheteAtual!.cnpjcpf.toString());

      final logomarca = '${retirarcaracteres(enderecoFilial.cnpjcpf!)}.png';
      //final imageLogo = await imageFromAssetBundle('assets/02731674000191.png'); 
      //final imageLogo = await imageFromAssetBundle('assets/logo.png'); 
      final imageLogo = await imageFromAssetBundle('assets/$logomarca'); // substitua pelo caminho correto do seu logo

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                /*##########################1º RECIBO####################################*/
                // 1. Cabeçalho
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 256), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Recibo Nº ${vendaBilheteAtual.recibo.toString().padLeft(5, '0')}'),
                            pw.Text(' '),
                            pw.Text(' '),
                            pw.Text('R\$${totalGeral.toStringAsFixed(2)}' ?? '0,00'),
                          ],
                        ),
                      ),
                    ),                    

                    /*
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Recibo Nº ' + vendaBilheteAtual.recibo.toString().padLeft(5, '0')),
                          pw.Text(' '),
                          pw.Text(' '),
                          pw.Text('R\$' + totalGeral.toStringAsFixed(2) ?? '0,00'),
                        ],
                      ),
                    ),
                    */
                  ],
                ),

                pw.SizedBox(height: 16),

                // 2. Descrição
                pw.Text(recibo.descricao.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),

                pw.SizedBox(height: 12),

                // 3. Assinaturas
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(' '),
                          pw.SizedBox(height: 32),
                          //pw.Divider(thickness: 1),
                          pw.Text('  '),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 32),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(''),
                          pw.SizedBox(height: 32),
                          pw.Text('${enderecoFilial.cidade}, ${formatarDataPorExtenso(DateTime.now())}'),
                          pw.SizedBox(height: 32),
                          pw.Divider(thickness: 1),
                          pw.Text(enderecoFilial.nome.toString()),
                        ],
                      ),
                    ),
                  ],
                ),


                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('   '),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                         // pw.Text(enderecoFilial.nome.toString(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${enderecoFilial.logradouro}, ${enderecoFilial.numero} ${enderecoFilial.complemento}'),
                          pw.Text('${enderecoFilial.bairro},${enderecoFilial.cidade} - ${enderecoFilial.estado}, ${enderecoFilial.cep}'),
                          pw.Text('Tel: ${enderecoFilial.telefone1}  Cel: ${enderecoFilial.celular1}'),
                          pw.Text('CNPJ: ${enderecoFilial.cnpjcpf}  Email: ${enderecoFilial.email}'),
                        ],
                      ),
                    ),
                  ],
                ),

                /*##########################2º RECIBO####################################*/
                pw.SizedBox(height: 64),

                // 1. Cabeçalho
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.SizedBox(width: 16),
                    /*pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Recibo Nº ' + vendaBilheteAtual.recibo.toString().padLeft(5, '0')),
                          pw.Text(' '),
                          pw.Text(' '),
                          pw.Text('R\$' + totalGeral.toStringAsFixed(2) ?? '0,00'),
                        ],
                      ),
                    ),*/

                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 256), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Recibo Nº ${vendaBilheteAtual.recibo.toString().padLeft(5, '0')}'),
                            pw.Text(' '),
                            pw.Text(' '),
                            pw.Text('R\$${totalGeral.toStringAsFixed(2)}' ?? '0,00'),
                          ],
                        ),
                      ),
                    ),                    


                  ],
                ),

                pw.SizedBox(height: 16),

                // 2. Descrição
                pw.Text(recibo.descricao.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),

                pw.SizedBox(height: 12),

                // 3. Assinaturas
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(' '),
                          pw.SizedBox(height: 32),
                          //pw.Divider(thickness: 1),
                          pw.Text('  '),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 32),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(''),
                          pw.SizedBox(height: 32),
                          pw.Text('${enderecoFilial.cidade}, ${formatarDataPorExtenso(DateTime.now())}'),
                          pw.SizedBox(height: 32),
                          pw.Divider(thickness: 1),
                          pw.Text(enderecoFilial.nome.toString()),
                        ],
                      ),
                    ),
                  ],
                ),


                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('   '),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                         // pw.Text(enderecoFilial.nome.toString(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${enderecoFilial.logradouro}, ${enderecoFilial.numero} ${enderecoFilial.complemento}'),
                          pw.Text('${enderecoFilial.bairro},${enderecoFilial.cidade} - ${enderecoFilial.estado}, ${enderecoFilial.cep}'),
                          pw.Text('Tel: ${enderecoFilial.telefone1}  Cel: ${enderecoFilial.celular1}'),
                          pw.Text('CNPJ: ${enderecoFilial.cnpjcpf}  Email: ${enderecoFilial.email}'),
                        ],
                      ),
                    ),
                  ],
                ),
                /*##############################################################*/


              ],


            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Recibo_bilhete.pdf',
      );
    }

  }


  void AddBilhete() {
    if ((vendaBilheteAtual.idvenda != 0)&&(vendaBilheteAtual.idvenda != null)){
      _abrirFormularioAddBilhete();
    }
  }


  void imprimirPDFRequisicao() async {
    if ((vendaBilheteAtual.idvenda != 0)&&(vendaBilheteAtual.idvenda != null)){

       // 🔥 Monta a lista para a tabela
      final itensTabela = _itensVendaBilhete.map((item) => [
        item.pax.toString(),
        item.bilhete ?? '',
        item.trecho ?? '',
        item.tipovoo ?? '',
        //item.cia ?? '',
        'R\$ ${item.valorbilhete?.toStringAsFixed(2) ?? '0,00'}',
        'R\$ ${item.valortaxabilhete?.toStringAsFixed(2) ?? '0,00'}',
        'R\$ ${item.valortaxaservico?.toStringAsFixed(2) ?? '0,00'}',
        'R\$ ${item.valorassento?.toStringAsFixed(2) ?? '0,00'}',
      ]).toList();      

      // Defina as larguras das colunas proporcionalmente
      final columnWidths = {
        0: const pw.FlexColumnWidth(2.0), // PAX
        1: const pw.FlexColumnWidth(1.0), // Bilhete
        2: const pw.FlexColumnWidth(1.0), // Trecho
        3: const pw.FlexColumnWidth(0.5), // Tipo Voo
        4: const pw.FlexColumnWidth(0.5), // CIA
        5: const pw.FlexColumnWidth(0.8), // Tarifa
        6: const pw.FlexColumnWidth(0.8), // Taxa Bilhete
        7: const pw.FlexColumnWidth(0.8), // Taxa Serviço
        8: const pw.FlexColumnWidth(0.8), // Assento
      };


      double totalValorBilhete = 0;
      double totalValorTaxaBilhete = 0;
      double totalValorTaxaServico = 0;
      double totalValorAssento = 0;
      double totalGeral = 0;

      for (var item in _itensVendaBilhete) {
        totalValorBilhete += item.valorbilhete ?? 0;
        totalValorTaxaBilhete += item.valortaxabilhete ?? 0;
        totalValorTaxaServico += item.valortaxaservico ?? 0;
        totalValorAssento += item.valorassento ?? 0;
      }

      totalGeral = totalValorBilhete + totalValorTaxaBilhete + totalValorTaxaServico + totalValorAssento;

      final pdf = pw.Document();
      final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final enderecoFilial = await FilialService.getFilialById(vendaBilheteAtual.idfilial.toString());
      final enderecoEntidade = await EntidadeService.getEntidadeById(vendaBilheteAtual.identidade.toString());
      //final cnpj = await EntidadeService.getEntidadeById(vendaBilheteAtual!.cnpjcpf.toString());

      final logomarca = '${retirarcaracteres(enderecoFilial.cnpjcpf!)}.png';
      //final imageLogo = await imageFromAssetBundle('assets/02731674000191.png'); 
      //final imageLogo = await imageFromAssetBundle('assets/logo.png'); 
      final imageLogo = await imageFromAssetBundle('assets/$logomarca'); // substitua pelo caminho correto do seu logo

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
                          pw.Text(enderecoFilial.nome.toString(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          pw.Text('${enderecoFilial.logradouro}, ${enderecoFilial.numero} ${enderecoFilial.complemento}'),
                          pw.Text('${enderecoFilial.bairro},${enderecoFilial.cidade} - ${enderecoFilial.estado}, ${enderecoFilial.cep}'),
                          pw.Text('Tel: ${enderecoFilial.telefone1}  Cel: ${enderecoFilial.celular1}'),
                          pw.Text('CNPJ: ${enderecoFilial.cnpjcpf}  Email: ${enderecoFilial.email}'),
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
                    pw.Text('Nº ${vendaBilheteAtual.id.toString().padLeft(5, '0')}'),
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
                pw.Text('Cliente: ${enderecoEntidade.nome}'),
                pw.Text('${enderecoEntidade.logradouro},${enderecoEntidade.numero}  ${enderecoEntidade.complemento}, ${enderecoEntidade.bairro}, ${enderecoEntidade.cidade} - ${enderecoEntidade.estado}, ${enderecoEntidade.cep}'),
                pw.SizedBox(height: 12),

                // 3. Observação
                pw.Text('Observação:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                // 4. Conteúdo da Observação
                pw.Text(vendaBilheteAtual.observacao.toString()),
                pw.SizedBox(height: 12),


                // 5. Lista de itens
                pw.Table(
                  columnWidths: columnWidths,
                  border: null, // 🔥 Sem linhas da tabela
                  children: [
                    // 🔥 Cabeçalho personalizado
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        for (final header in [
                          'Pax', 'Bilhete', 'Trecho', 'T.Voo', 'Cia',
                          'Tarifa', 'Taxa', 'Serviço', 'Assento'
                        ])
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              header,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // 🔥 Dados dos itens
                    ..._itensVendaBilhete.map(
                      (item) => pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.white,
                        ),
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(item.pax.toString(), style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(item.bilhete ?? '', style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(item.trecho ?? '', style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text((item.tipovoo ?? '').length >= 3 ? item.tipovoo!.substring(0, 3) : (item.tipovoo ?? ''), style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(item.cia ?? '', style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('R\$ ${item.valorbilhete?.toStringAsFixed(2) ?? '0,00'}', style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('R\$ ${item.valortaxabilhete?.toStringAsFixed(2) ?? '0,00'}', style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('R\$ ${item.valortaxaservico?.toStringAsFixed(2) ?? '0,00'}', style: pw.TextStyle(fontSize: 8))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('R\$ ${item.valorassento?.toStringAsFixed(2) ?? '0,00'}', style: pw.TextStyle(fontSize: 8))),
                        ],
                      ),
                    ),
                  ],
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
                          pw.Text('Total Tarifa: R\$ ${totalValorBilhete.toStringAsFixed(2)}'),
                          pw.Text('Total Taxa: R\$ ${totalValorTaxaBilhete.toStringAsFixed(2)}'),
                          pw.Text('Total Serviço: R\$ ${totalValorTaxaServico.toStringAsFixed(2)}'),
                          pw.Text('Total Assento: R\$ ${totalValorAssento.toStringAsFixed(2)}'),
                          pw.SizedBox(height: 8),
                          pw.Text('Total Geral: R\$ ${totalGeral.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Pagamento: ${vendaBilheteAtual.pagamento}'),
                          pw.Text('Vencimento: ${_formatarData(vendaBilheteAtual.datavencimento.toString())}' ),
                          pw.Text('Vendedor: ${vendaBilheteAtual.vendedor}'),
                          pw.Text('Emissor: ${vendaBilheteAtual.emissor}'),
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
                            'Recebi(emos) de ${enderecoFilial.nome},   a(s) passagem(ns) discriminada(s), reconhecendo-o SOLICITAÇÃO Sr(a):',
                            textAlign: pw.TextAlign.justify,
                          ),
                          pw.SizedBox(height: 32),
                          pw.Divider(thickness: 1),
                          pw.Text(vendaBilheteAtual.solicitante.toString()),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 32),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(''),
                          pw.SizedBox(height: 32),
                          pw.Text('${enderecoFilial.cidade}, ${formatarDataPorExtenso(DateTime.now())}'),
                          pw.SizedBox(height: 32),
                          pw.Divider(thickness: 1),
                          pw.Text(enderecoEntidade.nome.toString()),
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
        filename: 'Requisicao_bilhete.pdf',
      );
    }
  }


  double getTotalVenda(){
      double totalValorBilhete = 0;
      double totalValorTaxaBilhete = 0;
      double totalValorTaxaServico = 0;
      double totalValorAssento = 0;

      for (var item in _itensVendaBilhete) {
        totalValorBilhete += item.valorbilhete ?? 0;
        totalValorTaxaBilhete += item.valortaxabilhete ?? 0;
        totalValorTaxaServico += item.valortaxaservico ?? 0;
        totalValorAssento += item.valorassento ?? 0;
       // print(totalValorBilhete.toString() +' - '+ totalValorTaxaBilhete.toString() +' - '+ totalValorTaxaServico.toString() +' - '+ totalValorAssento.toString());
      }

      return totalValorBilhete + totalValorTaxaBilhete + totalValorTaxaServico + totalValorAssento;
  }


  String metodoValorPorExtenso(String valor) {
    final unidades = [
      '',
      'um',
      'dois',
      'três',
      'quatro',
      'cinco',
      'seis',
      'sete',
      'oito',
      'nove'
    ];
    final especiais = [
      'dez',
      'onze',
      'doze',
      'treze',
      'quatorze',
      'quinze',
      'dezesseis',
      'dezessete',
      'dezoito',
      'dezenove'
    ];
    final dezenas = [
      '',
      'dez',
      'vinte',
      'trinta',
      'quarenta',
      'cinquenta',
      'sessenta',
      'setenta',
      'oitenta',
      'noventa'
    ];
    final centenas = [
      '',
      'cento',
      'duzentos',
      'trezentos',
      'quatrocentos',
      'quinhentos',
      'seiscentos',
      'setecentos',
      'oitocentos',
      'novecentos'
    ];

    double numero = double.tryParse(valor.replaceAll(',', '.')) ?? 0;
    int inteiro = numero.floor();
    int centavos = ((numero - inteiro) * 100).round();

    String escreveParte(int n) {
      if (n == 100) return 'cem';

      String texto = '';

      int c = n ~/ 100;
      int d = (n % 100) ~/ 10;
      int u = n % 10;

      if (c != 0) {
        texto += centenas[c];
      }

      if (d == 1) {
        texto += (texto.isEmpty ? '' : ' e ') + especiais[u];
      } else {
        if (d != 0) {
          texto += (texto.isEmpty ? '' : ' e ') + dezenas[d];
        }
        if (u != 0) {
          texto += (texto.isEmpty ? '' : ' e ') + unidades[u];
        }
      }

      return texto;
    }

    String reais = inteiro == 0
        ? ''
        : '${escreveParte(inteiro)} ${inteiro == 1 ? "real" : "reais"}';

    String cent = centavos == 0
        ? ''
        : '${escreveParte(centavos)} ${centavos == 1 ? "centavo" : "centavos"}';

    if (reais.isNotEmpty && cent.isNotEmpty) {
      return '$reais e $cent';
    } else if (reais.isNotEmpty) {
      return reais;
    } else if (cent.isNotEmpty) {
      return cent;
    } else {
      return 'zero real';
    }
  }


  String? getClienteSelecionado(String? selectedValue, List<Map<String, dynamic>> options) {
    final item = options.firstWhere(
      (element) => element['id'].toString() == selectedValue,
      orElse: () => {},
    );

    return item.isNotEmpty ? item['nome'].toString() : null;
  }


  String? getPagamentoSelecionado(String? selectedValue, List<Map<String, dynamic>> options) {
    final item = options.firstWhere(
      (element) => element['id'].toString() == selectedValue,
      orElse: () => {},
    );

    return item.isNotEmpty ? item['nome'].toString() : null;
  }


  String? getCiaSelecionado(String? selectedValue, List<Map<String, dynamic>> options) {
    final item = options.firstWhere(
      (element) => element['id'].toString() == selectedValue,
      orElse: () => {},
    );

    return item.isNotEmpty ? item['nome'].toString() : null;
  }


  String gerarTextoRecibo({
    required String nomeCliente,
    required String valor,
    required String formaPagamento,
    required List<ItensVendaBilhete> itensVenda,
  }) {
    String texto = 'Recebemos de $nomeCliente\n'
        'a importância de $valor (${metodoValorPorExtenso(valor)}) - $formaPagamento - '
        'como valor de entrada proveniente da prestação dos serviços discriminados a seguir: ';

    for (var item in itensVenda) {
      texto += 'Compra de passagem aérea em favor de ${item.pax} '
          '(${item.trecho} Bilhete: ${item.bilhete}) pela cia aérea ${item.cia} - ';
    }

    texto += 'Para maior clareza e validade firmamos o presente recibo.';

    return texto;
  }


  double parseValor(String valor) {
    return double.tryParse(
      valor
          .replaceAll('R\$', '') // Remove "R$"
          .replaceAll(' ', '')    // Remove espaços
          .replaceAll('.', '')    // Remove pontos dos milhares
          .replaceAll(',', '.')   // Troca vírgula por ponto decimal
    ) ?? 0.0;
  }


  String retirarcaracteres(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9]'), '');
  }


  Future<void> _carregarDadosIniciais() async {
    await Future.delayed(const Duration(milliseconds: 500));
    /*
    Perceba que usei dois setState():
    🔸Um para os dados fixos (campos).
    🔸Outro para os itens, pois é uma Future.
    🔸Isso garante que a UI reconstrua corretamente.
    */

    final v = vendaBilheteAtual;

    bool bloquear = await bloquearVenda(); 

    setState(() {
      nroController.text = v.id?.toString() ?? '';
      solicitanteController.text = v.solicitante ?? '';
      observacaoController.text = v.observacao ?? '';
      faturaController.text = v.fatura?.toString() ?? '';
      reciboController.text = v.recibo?.toString() ?? '';

      valorEntradaController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
          .format(v.valorentrada ?? 0.0);
      valorTotalController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
          .format(v.valortotal ?? 0.0);
      descontoTotalController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
          .format(v.descontototal ?? 0.0);

      dataVenda = v.datavenda;
      dataVencimento = v.datavencimento;

      selectedFilial = v.idfilial?.toString();
      selectedCliente = v.identidade?.toString();
      selectedMoeda = v.idmoeda?.toString();
      selectedCCusto = v.idcentrocusto?.toString();
      selectedVendedor = v.idvendedor?.toString();
      selectedEmissor = v.idemissor?.toString();
      selectedPagamento = v.idformapagamento?.toString();
      selectedGrupo = v.idgrupo?.toString();
      bloquearRequisicao = bloquear;

    });

    // Itens da venda atualiza separado para evitar travar UI
    final itens = await ItemVendaBilheteService.getItensVendaBilheteByIdVenda(
      idvenda: v.idvenda ?? 0,
    );

    setState(() {
      _itensVendaBilhete = itens;
    });
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


  Future<bool> bloquearVenda() async {
    var bloquear = false;

    if ((vendaBilheteAtual.idreciboreceber != 0)&&(vendaBilheteAtual.idreciboreceber != null)) {
      bloquear = true;
    }

    if ((vendaBilheteAtual.idfatura != 0)&&(vendaBilheteAtual.idfatura != null)) {
      bloquear = true;
    }

    try {
      final temBaixa = await VendaBilheteService.getTemBaixa(vendaBilheteAtual.idvenda.toString());
      if ((temBaixa > 0)) {
        bloquear = true;
      }
    } catch (e) {
      print('Erro ao verificar baixa: $e');
    }

    return bloquear;
  }

 /// ---------------------------
 /// Dropdown
 /// ---------------------------
   Widget buildDropdownFilials(
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


  Widget buildDropdownClientes(
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


  Widget buildDropdownMoedas(
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


  Widget buildDropdownVendedors(
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


  Widget buildDropdownEmissors(
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


  Widget buildDropdownPagamento(
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
      validator: (value) {
        if (value == null && selectedGrupo == null) {
          return 'meio pagamento obrigatório.';
        }
        return null;
      },

    );
  }


  Widget buildDropdownCliente(
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
      validator: (value) {
        if (value == null && selectedCliente == null) {
          return 'cliente obrigatório.';
        }
        return null;
      },

    );
  }


  Widget buildDropdownFilial(
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
      validator: (value) {
        if (value == null && selectedFilial == null) {
          return 'filial obrigatória.';
        }
        return null;
      },

    );
  }


  Widget buildDropdownMoeda(
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
      validator: (value) {
        if (value == null && selectedMoeda == null) {
          return 'moeda obrigatória.';
        }
        return null;
      },

    );
  }


  Widget buildDropdownVendedor(
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
      validator: (value) {
        if (value == null && selectedVendedor == null) {
          return 'vendedor obrigatório.';
        }
        return null;
      },

    );
  }


  Widget buildDropdownEmissor(
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
      validator: (value) {
        if (value == null && selectedEmissor == null) {
          return 'emissor obrigatório.';
        }
        return null;
      },

    );
  }


 /// ---------------------------
 /// DatePicker
 /// ---------------------------

  Widget buildDatePickerVendas(
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
 /// TextField
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


  Widget buildMoneyField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label, prefixText: 'R\$ '),
      keyboardType: TextInputType.number,
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
        CentavosInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '',
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
 /// Buttons
 /// ---------------------------
  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? _abrirFormularioTitulo : null,
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
          onPressed: (habilitaSalvarCancelar) ? onSalvarRecibo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Recibo'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? AddBilhete : null,
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
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? onSalvar : null,
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
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? () => onExcluir(widget.vendabilhete!.idvenda!) : null,
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
 /// ListView
 /// ---------------------------
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
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Pax')),
                      DataColumn(label: Text('Bilhete')),
                      DataColumn(label: Text('Trecho')),
                      DataColumn(label: Text('CIA')),
                      DataColumn(label: Text('Valor')),
                    ],
                    rows: _itensVendaBilhete.map((item) {
                      return DataRow(cells: [
                        DataCell(Row(children: [
                          //IconButton(onPressed: () =>  print('Item clicado: ${item.toJson()}'), icon: const Icon(Icons.edit)),
                          IconButton(onPressed: () =>  _abrirFormularioAddBilhete(itemvendabilhete: item.toJson()), icon: const Icon(Icons.edit, color: Colors.orange)),
                          if(!bloquearRequisicao)
                          IconButton(onPressed: () => onExcluirItem(item.id), icon: const Icon(Icons.delete, color: Colors.red,),  ),
                        ])),
                        DataCell(Text(item.id != null ? item.id.toString() : '')),
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
  /// Build Geral
  /// ---------------------------
  @override
  Widget build(BuildContext context) {
    bool showDateError = false;
    DateTime? selectedDate;
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

                          buildTextField('Nro', nroController, readOnly: true),

                          buildDropdownFilial(
                            'Filial',
                            selectedFilial,
                            (value) => setState(() => selectedFilial = value),
                            () => setState(() => selectedFilial = null),
                            filiais,
                          ),

                          //buildDatePickerVenda('Data Venda', dataVenda, (val) => setState(() => dataVenda = val)),

                          buildDatePicker(
                            label: 'Data Venda',
                            date: dataVenda,
                            onChanged: (val) => setState(() => dataVenda = val),
                            isRequired: true,
                          ),

                          buildDropdownCliente(
                            'Cliente',
                            selectedCliente,
                            (value) => setState(() => selectedCliente = value),
                            () => setState(() => selectedCliente = null),
                            clientes,
                          ),
                          
                          buildDropdown(
                            'C.Custo',
                            selectedCCusto,
                            (value) => setState(() => selectedCCusto = value),
                            () => setState(() => selectedCCusto = null),
                            ccustos,
                          ),

                          //buildDatePicker('Data Vencimento', dataVencimento, (val) => setState(() => dataVencimento = val)),

                          buildDatePicker(
                            label: 'Data Vencimento',
                            date: dataVencimento,
                            onChanged: (val) => setState(() => dataVencimento = val),
                            isRequired: true,
                          ),

                          buildDropdownVendedor(
                            'Vendedor',
                            selectedVendedor,
                            (value) => setState(() => selectedVendedor = value),
                            () => setState(() => selectedVendedor = null),
                            vendedores,
                          ),

                          buildDropdownEmissor(
                            'Emissor',
                            selectedEmissor,
                            (value) => setState(() => selectedEmissor = value),
                            () => setState(() => selectedEmissor = null),
                            emissores,
                          ),

                          buildDropdownMoeda(
                            'Moeda',
                            selectedMoeda,
                            (value) => setState(() => selectedMoeda = value),
                            () => setState(() => selectedMoeda = null),
                            moedas,
                          ),

                          buildDropdownPagamento(
                            'Pagamento',
                            selectedPagamento,
                            (value) => setState(() => selectedPagamento = value),
                            () => setState(() => selectedPagamento = null),
                            pagamentos,
                          ),

                          buildDropdown(
                            'Grupo',
                            selectedGrupo,
                            (value) => setState(() => selectedGrupo = value),
                            () => setState(() => selectedGrupo = null),
                            grupos,
                          ),

                          buildTextField('Solicitante', solicitanteController),

                          buildTextField('Observação', observacaoController),

                          buildTextField('Fatura', faturaController, readOnly: true),

                          buildTextField('Recibo', reciboController, readOnly: true),

                          buildTextFieldValorDecimal('Val.Total', valorTotalController, readOnly: true),

                          buildTextFieldValorDecimal('Desc.Total', descontoTotalController, readOnly: true),

                        ]),

                        const SizedBox(height: 24),

                        ///  Botões
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
