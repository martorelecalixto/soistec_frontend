
import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../services/entidade_service.dart';
//import '../services/vendabilhete_service.dart';
//import '../services/itensvendabilhete_service.dart';
import '../../services/atividade_service.dart';

import '../../models/entidade_model.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/entidade/entidadeciaaerea_form.dart';
import '../../widgets/entidade/entidadeoperadora_form.dart';
import '../../widgets/entidade/entidadevendedor_form.dart';
import '../../widgets/entidade/entidadeemissor_form.dart';
import '../../widgets/entidade/entidadehotel_form.dart';

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

class EntidadeForm extends StatefulWidget {
  final Entidade? entidade;
  final double? width;
  final double? height;

  const EntidadeForm({
    super.key,
    this.entidade,
    this.width,
    this.height,
  });

  @override
  _EntidadeFormState createState() => _EntidadeFormState();
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

class _EntidadeFormState extends State<EntidadeForm> {
  final _formKey = GlobalKey<FormState>();

  late Entidade entidadeAtual;

  final nroController = TextEditingController();
  final nomeController = TextEditingController();
  final fantasiaController = TextEditingController();
  final cnpjcpfController = TextEditingController();
  final celular1Controller = TextEditingController();
  final celular2Controller = TextEditingController();
  final telefone1Controller = TextEditingController();
  final telefone2Controller = TextEditingController();
  final emailController = TextEditingController();

  // Máscaras
  final _cnpjCpfMask = MaskTextInputFormatter(mask: '##.###.###/####-##');
  final _telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');

  final double fontSize = 12.0; // tamanho padrão da fonte  

  bool isCliente = false;
  bool isFornecedor = false;
  bool isCiaaerea = false;
  bool isOperadora = false;
  bool isHotel = false;
  bool isVendedor = false;
  bool isEmissor = false;
  bool isLocadora = false;
  bool isTerrestre = false;
  bool isSeguro = false;
  bool isMotorista = false;
  bool isGuia = false;

  bool _isLoading = true;

  // Datas
  DateTime? dataCadastro;
  DateTime? dataNascimento;

  // Selecionados
  String? selectedAtividade;

  bool habilitaSalvarCancelar = true;
  bool bloquearRequisicao = false;

  List<Map<String, dynamic>> atividades = [];


  @override
  void initState() {
    super.initState();
    // Inicializa o objeto com o que vier do widget ou cria um novo
    entidadeAtual = widget.entidade ?? Entidade();    
    _init();
  }


  void _init() async {
    setState(() => _isLoading = true);
    await loadDropdownData(); // Aguarda dropdowns
    await _carregarDadosIniciais(); // Só então carrega os dados
    setState(() => _isLoading = false);
  }  

  
  void atualizarEntidadeAtual(Entidade novo) {
    setState(() {
      entidadeAtual = novo;
    });
  }


  // Se quiser que o estado reaja caso o widget pai mude o objeto
  @override
  void didUpdateWidget(covariant EntidadeForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entidade != oldWidget.entidade) {
      setState(() {
        entidadeAtual = widget.entidade ?? Entidade();
      });
    }
  }

  void _abrirFormularioHotel() async {
    
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 300,
          child: HotelForm(
            identidade: int.tryParse(entidadeAtual.identidade.toString()) ?? 0,
          ),
        ),
      ),
    );

    // Atualizar Listview
    await _carregarDadosIniciais();

  }


  void _abrirFormularioEmissor() async {
    
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: VendedorForm(
            identidade: int.tryParse(entidadeAtual.identidade.toString()) ?? 0,
          ),
        ),
      ),
    );

    // Atualizar Listview
    await _carregarDadosIniciais();

  }


  void _abrirFormularioVendedor() async {
    
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: VendedorForm(
            identidade: int.tryParse(entidadeAtual.identidade.toString()) ?? 0,
          ),
        ),
      ),
    );

    // Atualizar Listview
    await _carregarDadosIniciais();

  }


  void _abrirFormularioOperadora() async {
    
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: OperadoraForm(
            identidade: int.tryParse(entidadeAtual.identidade.toString()) ?? 0,
          ),
        ),
      ),
    );

    // Atualizar Listview
    await _carregarDadosIniciais();

  }


  void _abrirFormularioCiaAerea() async {
    
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1000,//1200
          height: 500,
          child: CiaAereaForm(
            identidade: int.tryParse(entidadeAtual.identidade.toString()) ?? 0,
          ),
        ),
      ),
    );

    // Atualizar Listview
    await _carregarDadosIniciais();

  }

  
  void limparCampos() async {
    nroController.clear();
    nomeController.clear();
    fantasiaController.clear();
    cnpjcpfController.clear();
    celular1Controller.clear();
    celular2Controller.clear();
    telefone1Controller.clear();
    telefone2Controller.clear();
    dataCadastro = dataNascimento = null;
    setState(() {});
  }


  void onNovo() {

    limparCampos();

    var entidadeAux = Entidade(
          identidade: null,
          nome: '',
          fantasia: '',
          cnpjcpf: '',
          celular1: '',
          celular2: '',
          telefone1: '',
          telefone2: '',
          datacadastro: null,
          datanascimento: null,
          email: '',
          ativo: false,
          for_: false,
          cli: false,
          vend: false,
          emis: false,
          mot: false,
          gui: false,
          cia: false,
          ope: false,
          hot: false,
          sigla: '',
          cartaosigla1: '',
          cartaonumero1: '',
          cartaomesvencimento1: null,
          cartaoanovencimento1: null,
          cartaodiafechamento1: null,
          cartaotitular1: '',
          cartaosigla2: '',
          cartaonumero2: '',
          cartaomesvencimento2: null,
          cartaoanovencimento2: null,
          cartaodiafechamento2: null,
          cartaotitular2: '',
          chave: '',
          atividadeid: null,
          empresa: '',
          seg: false,
          ter: false,
          loc: false,
          sexo: false,
          pes: false,
          documento: '',
          tipodocumento: '',
          cep: '',
          logradouro: '',
          numero: '',
          complemento: '',
          bairro: '',
          cidade: '',
          estado: '',
        );

    atualizarEntidadeAtual(entidadeAux);
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

          if (empresa == null || empresa.isEmpty) {
            throw Exception('Empresa não definida nas preferências.');
          }

          if (_formKey.currentState!.validate()) {
            final entidade = Entidade(
              identidade: entidadeAtual.identidade ?? 0,
              nome: nomeController.text,
              fantasia: fantasiaController.text,
              cnpjcpf: cnpjcpfController.text,
              celular1: celular1Controller.text,
              celular2: celular2Controller.text,
              telefone1: telefone1Controller.text,
              telefone2: telefone2Controller.text,
              datacadastro: dataCadastro,
              datanascimento: dataNascimento,
              email: emailController.text,
              ativo: true,
              for_: isFornecedor,
              cli: isCliente,
              vend: isVendedor,
              emis: isEmissor,
              mot: isMotorista,
              gui: isGuia,
              cia: isCiaaerea,
              ope: isOperadora,
              hot: isHotel,
              sigla: '',
              cartaosigla1: '',
              cartaonumero1: '',
              cartaomesvencimento1: null,
              cartaoanovencimento1: null,
              cartaodiafechamento1: null,
              cartaotitular1: '',
              cartaosigla2: '',
              cartaonumero2: '',
              cartaomesvencimento2: null,
              cartaoanovencimento2: null,
              cartaodiafechamento2: null,
              cartaotitular2: '',
              chave: uuid.v4(),
              atividadeid: selectedAtividade != null ? int.tryParse(selectedAtividade!) : null,
              empresa: empresa,
              seg: isSeguro,
              ter: isTerrestre,
              loc: isLocadora,
              sexo: false,
              pes: false,
              documento: '',
              tipodocumento: '',
              cep: '',
              logradouro: '',
              numero: '',
              complemento: '',
              bairro: '',
              cidade: '',
              estado: '',
            );

            bool sucesso = false;
            if ((entidadeAtual.identidade == null)|| (entidadeAtual.identidade == 0)) {


                final idGerado = await EntidadeService.createEntidade(entidade);
                if (idGerado != null) {
                  
                  var entidadeAux = Entidade(
                        identidade: entidadeAtual.identidade ?? 0,//idGerado,
                        nome: nomeController.text,
                        fantasia: fantasiaController.text,
                        cnpjcpf: cnpjcpfController.text,
                        celular1: celular1Controller.text,
                        celular2: celular2Controller.text,
                        telefone1: telefone1Controller.text,
                        telefone2: telefone2Controller.text,
                        datacadastro: dataCadastro,
                        datanascimento: dataNascimento,
                        email: emailController.text,
                        ativo: true,
                        for_: isFornecedor,
                        cli: isCliente,
                        vend: isVendedor,
                        emis: isEmissor,
                        mot: isMotorista,
                        gui: isGuia,
                        cia: isCiaaerea,
                        ope: isCiaaerea,
                        hot: isHotel,
                        sigla: '',
                        cartaosigla1: '',
                        cartaonumero1: '',
                        cartaomesvencimento1: null,
                        cartaoanovencimento1: null,
                        cartaodiafechamento1: null,
                        cartaotitular1: '',
                        cartaosigla2: '',
                        cartaonumero2: '',
                        cartaomesvencimento2: null,
                        cartaoanovencimento2: null,
                        cartaodiafechamento2: null,
                        cartaotitular2: '',
                        chave: uuid.v4(),
                        atividadeid: selectedAtividade != null ? int.tryParse(selectedAtividade!) : null,
                        empresa: empresa,
                        seg: isSeguro,
                        ter: isTerrestre,
                        loc: isLocadora,
                        sexo: false,
                        pes: false,
                        documento: '',
                        tipodocumento: '',
                        cep: '',
                        logradouro: '',
                        numero: '',
                        complemento: '',
                        bairro: '',
                        cidade: '',
                        estado: '',
                      );

                      atualizarEntidadeAtual(entidadeAux);

                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirmação'),
                          content: const Text('Entidade salva com sucesso'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
                          ],
                        ),
                      );

                    setState(() {
                    });
                }  

            } else {
             
              sucesso = await EntidadeService.updateEntidade(entidade);
              
              atualizarEntidadeAtual(entidade);
            
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Informação.'),
                  content: const Text('Entidade salva com sucesso.'),
                  actions: [
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


  void onExcluir(int? identidade) async{
    if ((entidadeAtual.identidade != 0)&&(entidadeAtual.identidade != null)){

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Deseja realmente excluir esta entidade?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
          ],
        ),
      );
      if (confirmar == true) {
          try {
            if(identidade != null){
              await EntidadeService.deleteEntidade(identidade);
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
            if (e is ApiExceptionEntidade) {
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


/*
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

      */


    }
  }


  void AddCliente() {
    //if ((entidadeAtual.identidade != 0)&&(entidadeAtual.identidade != null)){
    //  _abrirFormularioCiaAerea();
   // }
  }


  String? getAtividadeSelecionado(String? selectedValue, List<Map<String, dynamic>> options) {
    final item = options.firstWhere(
      (element) => element['id'].toString() == selectedValue,
      orElse: () => {},
    );

    return item.isNotEmpty ? item['nome'].toString() : null;
  }


  String retirarcaracteres(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9]'), '');
  }


  Future<void> loadDropdownData() async {
      final atividadesResponse = await AtividadeService.getAtividadesDropDown();

      setState(() {
        atividades = atividadesResponse.map((f) => {'id': f.id, 'nome': f.nome}).toList();
      });      
    setState(() {});
  }


  Future<void> _carregarDadosIniciais() async {
      await Future.delayed(const Duration(milliseconds: 500));

      final v = entidadeAtual;      

      setState(() {
        nroController.text = v.identidade?.toString() ?? '';
        nomeController.text = v.nome ?? '';
        fantasiaController.text = v.fantasia ?? '';
        cnpjcpfController.text = v.cnpjcpf?.toString() ?? '';
        emailController.text = v.email?.toString() ?? '';
        celular1Controller.text = v.celular1?.toString() ?? '';
        celular2Controller.text = v.celular2?.toString() ?? '';
        telefone1Controller.text = v.telefone1?.toString() ?? '';
        telefone2Controller.text = v.telefone2?.toString() ?? '';
        isCliente = v.cli ?? false;
        isFornecedor = v.for_ ?? false;
        isCiaaerea = v.cia ?? false;
        isHotel = v.hot ?? false;
        isVendedor = v.vend ?? false;
        isEmissor = v.emis ?? false;
        isLocadora = v.loc ?? false;
        isTerrestre = v.ter ?? false;
        isSeguro = v.seg ?? false;
        isOperadora = v.ope ?? false;
        isMotorista = v.mot ?? false;
        isGuia = v.gui ?? false;


        dataCadastro = v.datacadastro;
        dataNascimento = v.datanascimento;

        selectedAtividade = v.atividadeid?.toString();
      });


      setState(() {
      });
    }


 /// ---------------------------
 /// Dropdown
 /// ---------------------------
   Widget _buildDropdownAtividades(
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
              if (value == null && selectedAtividade == null) {
                return 'atividade obrigatória.';
              }
              return null;
            },

          ),
        ),
        IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
      ],
    );
  }

  Widget buildDropdownAtividades(
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
      //validator: (value) {
      //  if (value == null && selectedAtividade == null) {
      //    return 'filial obrigatória.';
      //  }
      //  return null;
      //},

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


 /// ---------------------------
 /// DatePicker
 /// ---------------------------
  Widget buildDatePickerCadastro(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { 
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'data cadastro obrigatória.';
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

  Widget buildDatePickerNascimento(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isRequired = false,
  }) { print('DATA $date');
    return FormField<DateTime>(
      validator: (_) {
        if (date == null) {//isRequired && 
          return 'data nascimento obrigatória.';
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
  Widget _buildTextField(
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


  Widget buildTextField(
    String label,
    TextEditingController controller,
     {
    bool readOnly = false,
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


 /// ---------------------------
 /// Buttons
 /// ---------------------------
  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? onNovo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Nova Entidade'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? onSalvar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? () => onExcluir(widget.entidade!.identidade!) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }

  Widget buildButtonsRowTop() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isCliente)) ? AddCliente : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: bgColor,

            disabledForegroundColor:  bgColor,
            disabledBackgroundColor:  bgColor,    
            elevation: 0,
            shadowColor: bgColor,   
            enableFeedback: false,     
            overlayColor: bgColor,            
          ),          
          child: const Text('Cliente'),
        ),
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isFornecedor)) ? AddCliente : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,//Colors.purple[300],
            foregroundColor: bgColor,

            disabledForegroundColor:  bgColor,
            disabledBackgroundColor:  bgColor,    
            elevation: 0,
            shadowColor:  bgColor,   
            enableFeedback: false,     
            overlayColor:  bgColor,            
          ), 
          autofocus: false,          
          child: const Text('Fornecedor'),                    
        ),
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isCiaaerea)) ? _abrirFormularioCiaAerea : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[300],
            foregroundColor: Colors.white,
          ),
          child: const Text('Cia Aerea'),
        ),
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isHotel)) ? _abrirFormularioHotel : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[500],
            foregroundColor: Colors.white,
          ),
          child: const Text('Hotel'),
        ),
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isVendedor)) ? _abrirFormularioVendedor : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan[500],
            foregroundColor: Colors.white,
          ),
          child: const Text('Vendedor'),
        ),
       ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isEmissor)) ? _abrirFormularioEmissor : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan[300],
            foregroundColor: Colors.white,
          ),
          child: const Text('Emissor'),
        ),
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isOperadora)) ? _abrirFormularioOperadora : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan[200],
            foregroundColor: Colors.white,
          ),
          child: const Text('Operadora'),
        ),
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isLocadora)) ? onNovo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:bgColor,// Colors.deepPurpleAccent[200],
            foregroundColor: bgColor,

            disabledForegroundColor:  bgColor,
            disabledBackgroundColor:  bgColor,    
            elevation: 0,
            shadowColor:  bgColor,   
            enableFeedback: false,     
            overlayColor:  bgColor,            
          ),
          child: const Text('Locadora'),
        ),
        ElevatedButton(
          onPressed: ((habilitaSalvarCancelar)&&(isLocadora)) ? onNovo : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,// Colors.deepPurpleAccent[100],
            foregroundColor: bgColor,

            disabledForegroundColor:  bgColor,
            disabledBackgroundColor:  bgColor,    
            elevation: 0,
            shadowColor:  bgColor,   
            enableFeedback: false,     
            overlayColor:  bgColor,            
          ),
          child: const Text('Seguradora'),
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
  /// checkbox
  /// ---------------------------
  Widget buildCheckboxGroup() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('Cliente', isCliente, (val) => setState(() => isCliente = val!)),
              checkboxItem('Fornecedor', isFornecedor, (val) => setState(() => isFornecedor = val!)),
              checkboxItem('Cia.Aerea', isCiaaerea, (val) => setState(() => isCiaaerea = val!)),
              checkboxItem('Hotel', isHotel, (val) => setState(() => isHotel = val!)),
              checkboxItem('Vendedor', isVendedor, (val) => setState(() => isVendedor = val!)),
              checkboxItem('Emissor', isEmissor, (val) => setState(() => isEmissor = val!)),
              checkboxItem('Operadora', isOperadora, (val) => setState(() => isOperadora = val!)),
              checkboxItem('Locadora', isLocadora, (val) => setState(() => isLocadora = val!)),
              checkboxItem('Seguradora', isSeguro, (val) => setState(() => isSeguro = val!)),
            ],
    );
  }


  Widget checkboxItem(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
      ],
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
      appBar: AppBar(title: const Text('Entidade')),
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

                        ///  Botões Down
                        buildButtonsRowTop(),

                        const SizedBox(height: 24),

                        buildCheckboxGroup(),

                        const SizedBox(height: 24),

                        buildFieldGroup(constraints, [

                          buildTextField('Nro', nroController, readOnly: true),

                          buildDropdownAtividades(
                            'Atividade',
                            selectedAtividade,
                            (value) => setState(() => selectedAtividade = value),
                            () => setState(() => selectedAtividade = null),
                            atividades,
                          ),

                          buildDatePicker(
                            label: 'Data Cadastro',
                            date: dataCadastro,
                            onChanged: (val) => setState(() => dataCadastro = val),
                            isRequired: true,
                          ),
                          
                          buildDatePicker(
                            label: 'Data Nascimento',
                            date: dataNascimento,
                            onChanged: (val) => setState(() => dataNascimento = val),
                            isRequired: true,
                          ),

                          buildTextField('Nome', nomeController, readOnly: false),

                          buildTextField('Fantasia', fantasiaController, readOnly: false),

                          buildTextField('CNPJ/CPF', cnpjcpfController, readOnly: false, inputFormatters: [_cnpjCpfMask]),

                          buildTextField('E-mail', emailController, readOnly: false),

                          buildTextField('Telefone(1)', telefone1Controller, readOnly: false, inputFormatters: [_telefoneMask]),

                          buildTextField('Telefone(2)', telefone2Controller, readOnly: false, inputFormatters: [_telefoneMask]),

                          buildTextField('Celular(1)', celular1Controller, readOnly: false, inputFormatters: [_telefoneMask]),

                          buildTextField('Celular(2)', celular2Controller, readOnly: false, inputFormatters: [_telefoneMask]),

                        ]),

                        const SizedBox(height: 24),

                        ///  Botões Down
                        buildButtonsRow(),

                       // const SizedBox(height: 24),

                        /// LISTA COM TAMANHO FIXO + SCROLL VERTICAL
                      //  SizedBox(
                      //    width: double.infinity,
                      //    height: 400, // ou ajuste conforme necessário
                          ////child: buildListView(),
                      //  ),
                                              
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
