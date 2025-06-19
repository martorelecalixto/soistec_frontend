
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/hotel_model.dart';
import '../../services/entidade_service.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class HotelForm extends StatefulWidget {
  final int identidade;
  final double? width;
  final double? height;
  
  const HotelForm({
    super.key,
    required this.identidade,
    this.width,
    this.height,
  });

  @override
  _HotelFormState createState() => _HotelFormState();
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

class _HotelFormState extends State<HotelForm> {
  final _formKey = GlobalKey<FormState>();
  late Hotel hotelAtual;

  final label1Controller = TextEditingController();
  final label2Controller = TextEditingController();

  final nroEntidadeController = TextEditingController();
  final nroController = TextEditingController();
  final percomisNacController = TextEditingController(text: '0,00');
  final percomisIntController = TextEditingController(text: '0,00');
  final prazofaturamentoController = TextEditingController();

  bool _isLoading = true;

  bool habilitaSalvarCancelar = true;

  @override
  void initState() {
    super.initState();
    // Inicializa o objeto com o que vier do widget ou cria um novo
    
    _init();
  }

  void _init() async {
    setState(() => _isLoading = true);
    await _carregarDadosIniciais(); // Só então carrega os dados
    setState(() => _isLoading = false);
  } 

  // Se quiser que o estado reaja caso o widget pai mude o objeto
  @override
  void didUpdateWidget(covariant HotelForm oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _carregarDadosIniciais() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final hot = await EntidadeService.getHotelById(widget.identidade.toString());

    atualizarhotelAtual(hot);

    setState(() {
        label1Controller.text = 'Comissão Aereo';
        label2Controller.text = 'Comissão Serviço';
        
        nroController.text = hot.idhotel.toString();
        nroEntidadeController.text = widget.identidade.toString();

        percomisNacController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(hot.percomis ?? 0.0);
        percomisIntController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(hot.percomisint ?? 0.0);
        prazofaturamentoController.text = hot.prazofaturamento.toString();
    
      }); // Garante que os dados sejam renderizados
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

  void limparCampos() {
      nroController.text = '0';
      nroEntidadeController.text = widget.identidade.toString();

      percomisNacController.text = '0,00';
      percomisIntController.text = '0,00';
      prazofaturamentoController.text = '0';

    setState(() {});
  }
  
  void atualizarhotelAtual(Hotel novo) {
    setState(() {
      hotelAtual = novo;
    });
  }

  void onNovo() {

    limparCampos();

    var hotelAux = Hotel(
      idhotel: null,
      entidadeid: int.tryParse(nroEntidadeController.text) ?? 0,
      percomis: 0,
      percomisint: 0,
      prazofaturamento: 0,
    );

    atualizarhotelAtual(hotelAux);
  }

  void onSalvar() async{
    if (!_formKey.currentState!.validate()) {
      //print('Campos obrigatórios não preenchidos.');
      return; // Sai da função e não executa mais nada.
    }else{
        try{
            final prefs = await SharedPreferences.getInstance();
            final empresa = prefs.getString('empresa');

            if (widget.identidade == 0) {
              throw Exception('Entidade obrigatória.');
            }

            if (_formKey.currentState!.validate()) {
              final hotel = Hotel(
                entidadeid: int.tryParse(nroEntidadeController.text) ?? 0,
                idhotel: int.tryParse(nroController.text) ?? 0,
                percomis: parseValor(percomisNacController.text),
                percomisint: parseValor(percomisIntController.text),
                prazofaturamento: int.tryParse(prazofaturamentoController.text) ?? 0,
              );

              bool sucesso = false;
              if ((hotelAtual.idhotel == null)|| (hotelAtual.idhotel == 0)) {

                final idGerado = await EntidadeService.createHotel(hotel);

                if (idGerado != null) {
                    nroController.text = idGerado.toString();
                    var hotelAux = Hotel(
                    entidadeid: int.tryParse(nroEntidadeController.text) ?? 0,
                    idhotel: idGerado,
                    percomis: parseValor(percomisNacController.text),
                    percomisint: parseValor(percomisIntController.text),
                    prazofaturamento: int.tryParse(prazofaturamentoController.text) ?? 0,
                    );
                    
                    atualizarhotelAtual(hotelAux);                    
                    
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Informação.'),
                        content: const Text('Hotel salva com sucesso'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('OK')),
                          //TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
                        ],
                      ),
                    );

                    if(confirmar == true){
                      onNovo();
                    }

                    setState(() {
                    });
                }  

              } else {
                print('SALVAR 01');

                sucesso = await EntidadeService.updateHotel(hotel);
                atualizarhotelAtual(hotel); 

                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Informação.'),
                    content: const Text('Vendedor salva com sucesso.'),
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

    if ((hotelAtual.idhotel != 0)&&(hotelAtual.idhotel != null)){

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
              await EntidadeService.deleteHotel(id);
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
            if (e is ApiExceptionEntidade) {
              mostrarMensagem(context, e.message, titulo: 'Erro');
            } else {
              mostrarMensagem(context, 'Erro inesperado: $e', titulo: 'Erro');
            }
          }

      }


    }
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
        childAspectRatio: 6, // Controle da altura (quanto maior, mais achatado)
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
  /// Botões
  /// ---------------------------
  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar) ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Novo'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar) ? onSalvar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar) ?  () => onExcluir(hotelAtual.idhotel!) : null,
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
      appBar: AppBar(title: const Text('Hotel')),
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

                        const SizedBox(height: 12),
                        buildFieldGroup(constraints, [

                          buildTextFieldValorDecimal('Comis.Nac.(%)', percomisNacController),
                          buildTextFieldValorDecimal('Comis.Int.(%)', percomisIntController),
                          buildTextField('Prazo Faturamento', prazofaturamentoController),

                        ]),


                        buildFieldGroup(constraints, [

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
                              buildTextField('Nro', nroEntidadeController, readOnly: true),
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
