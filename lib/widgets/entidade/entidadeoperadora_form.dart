
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../models/operadora_model.dart';
import '../../services/entidade_service.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class OperadoraForm extends StatefulWidget {
  final int identidade;
  final double? width;
  final double? height;
  
  const OperadoraForm({
    super.key,
    required this.identidade,
    this.width,
    this.height,
  });

  @override
  _OperadoraFormState createState() => _OperadoraFormState();
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

class _OperadoraFormState extends State<OperadoraForm> {
  final _formKey = GlobalKey<FormState>();
  late Operadora operadoraAtual;

  final label1Controller = TextEditingController();
  final label2Controller = TextEditingController();
  final label3Controller = TextEditingController();
  final label4Controller = TextEditingController();
  final label5Controller = TextEditingController();
  final label6Controller = TextEditingController();
  final label7Controller = TextEditingController();
  final label8Controller = TextEditingController();

  final nroEntidadeController = TextEditingController();
  final nroController = TextEditingController();
  final percomisNacController = TextEditingController(text: '0,00');
  final overNacController = TextEditingController(text: '0,00');
  final percomisIntController = TextEditingController(text: '0,00');
  final overIntController = TextEditingController(text: '0,00');

  final valoriniNac1Controller = TextEditingController(text: '0,00');
  final valorfinNac1Controller = TextEditingController(text: '0,00');
  final valorNac1Controller = TextEditingController(text: '0,00');
  final percNac1Controller = TextEditingController(text: '0,00');

  final valoriniNac2Controller = TextEditingController(text: '0,00');
  final valorfinNac2Controller = TextEditingController(text: '0,00');
  final valorNac2Controller = TextEditingController(text: '0,00');
  final percNac2Controller = TextEditingController(text: '0,00');

  final valoriniInt1Controller = TextEditingController(text: '0,00');
  final valorfinInt1Controller = TextEditingController(text: '0,00');
  final valorInt1Controller = TextEditingController(text: '0,00');
  final percInt1Controller = TextEditingController(text: '0,00');

  final valoriniInt2Controller = TextEditingController(text: '0,00');
  final valorfinInt2Controller = TextEditingController(text: '0,00');
  final valorInt2Controller = TextEditingController(text: '0,00');
  final percInt2Controller = TextEditingController(text: '0,00');

  bool isliqAddTarifaNacIV = false;
  bool isliqAddTaxaNacIV = false;
  bool isliqAddDUNacIV = false;
  bool isliqAddComissaoNacIV = false;
  bool isliqAddOverNacIV = false;

  bool isliqDedTarifaNacIV = false;
  bool isliqDedTaxaNacIV = false;
  bool isliqDedDUNacIV = false;
  bool isliqDedComissaoNacIV = false;
  bool isliqDedOverNacIV = false;

  bool isliqAddTarifaNacCC = false;
  bool isliqAddTaxaNacCC = false;
  bool isliqAddDUNacCC = false;
  bool isliqAddComissaoNacCC = false;
  bool isliqAddOverNacCC = false;

  bool isliqDedTarifaNacCC = false;
  bool isliqDedTaxaNacCC = false;
  bool isliqDedDUNacCC = false;
  bool isliqDedComissaoNacCC = false;
  bool isliqDedOverNacCC = false;

  bool isliqAddTarifaIntIV = false;
  bool isliqAddTaxaIntIV = false;
  bool isliqAddDUIntIV = false;
  bool isliqAddComissaoIntIV = false;
  bool isliqAddOverIntIV = false;

  bool isliqDedTarifaIntIV = false;
  bool isliqDedTaxaIntIV = false;
  bool isliqDedDUIntIV = false;
  bool isliqDedComissaoIntIV = false;
  bool isliqDedOverIntIV = false;

  bool isliqAddTarifaIntCC = false;
  bool isliqAddTaxaIntCC = false;
  bool isliqAddDUIntCC = false;
  bool isliqAddComissaoIntCC = false;
  bool isliqAddOverIntCC = false;

  bool isliqDedTarifaIntCC = false;
  bool isliqDedTaxaIntCC = false;
  bool isliqDedDUIntCC = false;
  bool isliqDedComissaoIntCC = false;
  bool isliqDedOverIntCC = false;

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
  void didUpdateWidget(covariant OperadoraForm oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _carregarDadosIniciais() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final ope = await EntidadeService.getOperadoraById(widget.identidade.toString());

    atualizarOperadoraAtual(ope);

    setState(() {
        label1Controller.text = 'Cálculo Líquido Nac(IV)';
        label2Controller.text = 'Cálculo Líquido Nac(CC)';
        label3Controller.text = 'Cálculo Líquido Int(IV)';
        label4Controller.text = 'Cálculo Líquido Int(CC)';
        label5Controller.text = '';
        label6Controller.text = '';
        label7Controller.text = 'Comissão Nacional';
        label8Controller.text = 'Comissão Internacional';
        
        nroController.text = ope.idoperadora.toString();
        nroEntidadeController.text = widget.identidade.toString();

        percomisNacController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.percomisnac ?? 0.0);
        overNacController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.overnac ?? 0.0);
        percomisIntController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.percomisint ?? 0.0);
        overIntController.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.overint ?? 0.0);

        valoriniNac1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorininac1 ?? 0.0);
        valorfinNac1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorfinnac1 ?? 0.0);
        valorNac1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valornac1 ?? 0.0);
        percNac1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.percnac1 ?? 0.0);

        valoriniNac2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorininac2 ?? 0.0);
        valorfinNac2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorfinnac2 ?? 0.0);
        valorNac2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valornac2 ?? 0.0);
        percNac2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.percnac2 ?? 0.0);

        valoriniInt1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valoriniint1 ?? 0.0);
        valorfinInt1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorfinint1 ?? 0.0);
        valorInt1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorint1 ?? 0.0);
        percInt1Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.percint1 ?? 0.0);

        valoriniInt2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valoriniint2 ?? 0.0);
        valorfinInt2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorfinint2 ?? 0.0);
        valorInt2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.valorint2 ?? 0.0);
        percInt2Controller.text = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
        .format(ope.percint2 ?? 0.0);

        isliqAddTarifaNacIV =  ope.liqaddtarifanaciv ?? false;
        isliqAddTaxaNacIV = ope.liqaddtaxanaciv ?? false;
        isliqAddDUNacIV = ope.liqadddunaciv ?? false;
        isliqAddComissaoNacIV = ope.liqaddcomissaonaciv ?? false;
        isliqAddOverNacIV = ope.liqaddovernaciv ?? false;

        isliqDedTarifaNacIV = ope.liqdedtarifanaciv ?? false;
        isliqDedTaxaNacIV = ope.liqdedtaxanaciv ?? false;
        isliqDedDUNacIV = ope.liqdeddunaciv ?? false;
        isliqDedComissaoNacIV = ope.liqdedcomissaonaciv ?? false;
        isliqDedOverNacIV = ope.liqdedovernaciv ?? false;

        isliqAddTarifaNacCC = ope.liqaddtarifanaccc ?? false;
        isliqAddTaxaNacCC = ope.liqaddtaxanaccc ?? false;
        isliqAddDUNacCC = ope.liqadddunaccc ?? false;
        isliqAddComissaoNacCC = ope.liqaddcomissaonaccc ?? false;
        isliqAddOverNacCC = ope.liqaddovernaccc ?? false;

        isliqDedTarifaNacCC = ope.liqdedtarifanaccc ?? false;
        isliqDedTaxaNacCC = ope.liqdedtaxanaccc ?? false;
        isliqDedDUNacCC = ope.liqdeddunaccc ?? false;
        isliqDedComissaoNacCC = ope.liqdedcomissaonaccc ?? false;
        isliqDedOverNacCC = ope.liqdedovernaccc ?? false;

        isliqAddTarifaIntIV = ope.liqaddtarifaintiv ?? false;
        isliqAddTaxaIntIV = ope.liqaddtaxaintiv ?? false;
        isliqAddDUIntIV = ope.liqaddduintiv ?? false;
        isliqAddComissaoIntIV = ope.liqaddcomissaointiv ?? false;
        isliqAddOverIntIV = ope.liqaddoverintiv ?? false;

        isliqDedTarifaIntIV = ope.liqdedtarifaintiv ?? false;
        isliqDedTaxaIntIV = ope.liqdedtaxaintiv ?? false;
        isliqDedDUIntIV = ope.liqdedduintiv ?? false;
        isliqDedComissaoIntIV = ope.liqdedcomissaointiv ?? false;
        isliqDedOverIntIV = ope.liqdedoverintiv ?? false;

        isliqAddTarifaIntCC = ope.liqaddtarifaintcc ?? false;
        isliqAddTaxaIntCC = ope.liqaddtaxaintcc ?? false;
        isliqAddDUIntCC = ope.liqaddduintcc ?? false;
        isliqAddComissaoIntCC = ope.liqaddcomissaointcc ?? false;
        isliqAddOverIntCC = ope.liqaddoverintcc ?? false;

        isliqDedTarifaIntCC = ope.liqdedtarifaintcc ?? false;
        isliqDedTaxaIntCC = ope.liqdedtaxaintcc ?? false;
        isliqDedDUIntCC = ope.liqdedduintcc ?? false;
        isliqDedComissaoIntCC = ope.liqdedcomissaointcc ?? false;
        isliqDedOverIntCC = ope.liqdedoverintcc ?? false;
    
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
      overNacController.text = '0,00';
      percomisIntController.text = '0,00';
      overIntController.text = '0,00';

      valoriniNac1Controller.text = '0,00';
      valorfinNac1Controller.text = '0,00';
      valorNac1Controller.text = '0,00';
      percNac1Controller.text = '0,00';

      valoriniNac2Controller.text = '0,00';
      valorfinNac2Controller.text = '0,00';
      valorNac2Controller.text = '0,00';
      percNac2Controller.text = '0,00';

      valoriniInt1Controller.text = '0,00';
      valorfinInt1Controller.text = '0,00';
      valorInt1Controller.text = '0,00';
      percInt1Controller.text = '0,00';

      valoriniInt2Controller.text = '0,00';
      valorfinInt2Controller.text = '0,00';
      valorInt2Controller.text = '0,00';
      percInt2Controller.text = '0,00';

      isliqAddTarifaNacIV =  false;
      isliqAddTaxaNacIV = false;
      isliqAddDUNacIV = false;
      isliqAddComissaoNacIV = false;
      isliqAddOverNacIV = false;

      isliqDedTarifaNacIV = false;
      isliqDedTaxaNacIV = false;
      isliqDedDUNacIV = false;
      isliqDedComissaoNacIV = false;
      isliqDedOverNacIV = false;

      isliqAddTarifaNacCC = false;
      isliqAddTaxaNacCC = false;
      isliqAddDUNacCC = false;
      isliqAddComissaoNacCC = false;
      isliqAddOverNacCC = false;

      isliqDedTarifaNacCC = false;
      isliqDedTaxaNacCC = false;
      isliqDedDUNacCC = false;
      isliqDedComissaoNacCC = false;
      isliqDedOverNacCC = false;

      isliqAddTarifaIntIV = false;
      isliqAddTaxaIntIV = false;
      isliqAddDUIntIV = false;
      isliqAddComissaoIntIV = false;
      isliqAddOverIntIV = false;

      isliqDedTarifaIntIV = false;
      isliqDedTaxaIntIV = false;
      isliqDedDUIntIV = false;
      isliqDedComissaoIntIV = false;
      isliqDedOverIntIV = false;

      isliqAddTarifaIntCC = false;
      isliqAddTaxaIntCC = false;
      isliqAddDUIntCC = false;
      isliqAddComissaoIntCC = false;
      isliqAddOverIntCC = false;

      isliqDedTarifaIntCC = false;
      isliqDedTaxaIntCC = false;
      isliqDedDUIntCC = false;
      isliqDedComissaoIntCC = false;
      isliqDedOverIntCC = false;
    setState(() {});
  }
  
  void atualizarOperadoraAtual(Operadora novo) {
    setState(() {
      operadoraAtual = novo;
    });
  }

  void onNovo() {

    limparCampos();

    var operadoraAux = Operadora(
      idoperadora: null
    );

    atualizarOperadoraAtual(operadoraAux);
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
              final operadora = Operadora(
                entidadeid: int.tryParse(nroEntidadeController.text) ?? 0,
                idoperadora: int.tryParse(nroController.text) ?? 0,

                percomisnac: parseValor(percomisNacController.text),
                overnac: parseValor(overNacController.text),
                percomisint: parseValor(percomisIntController.text),
                overint: parseValor(overIntController.text),

                valorininac1:  parseValor(valoriniNac1Controller.text),
                valorfinnac1: parseValor(valorfinNac1Controller.text),
                valornac1: parseValor(valorNac1Controller.text),
                percnac1: parseValor(percNac1Controller.text),

                valorininac2: parseValor(valoriniNac2Controller.text),
                valorfinnac2: parseValor(valorfinNac2Controller.text),
                valornac2: parseValor(valorNac2Controller.text),
                percnac2: parseValor(percNac2Controller.text),

                valoriniint1: parseValor(valoriniInt1Controller.text),
                valorfinint1: parseValor(valorfinInt1Controller.text),
                valorint1: parseValor(valorInt1Controller.text),
                percint1: parseValor(percInt1Controller.text),


                valoriniint2: parseValor(valoriniInt2Controller.text),
                valorfinint2: parseValor(valorfinInt2Controller.text),
                valorint2: parseValor(valorInt2Controller.text),
                percint2: parseValor(percInt2Controller.text),

                liqaddtarifanaciv: isliqAddTarifaNacIV,
                liqaddtaxanaciv: isliqAddTaxaNacIV,
                liqadddunaciv: isliqAddDUNacIV,
                liqaddcomissaonaciv: isliqAddComissaoNacIV,
                liqaddovernaciv: isliqAddOverNacIV,

                liqdedtarifanaciv: isliqDedTarifaNacIV,
                liqdedtaxanaciv: isliqDedTaxaNacIV,
                liqdeddunaciv: isliqDedDUNacIV,
                liqdedcomissaonaciv: isliqDedComissaoNacIV,
                liqdedovernaciv: isliqDedOverNacIV,

                liqaddtarifanaccc: isliqAddTarifaNacCC,
                liqaddtaxanaccc: isliqAddTaxaNacCC,
                liqadddunaccc:  isliqAddDUNacCC,
                liqaddcomissaonaccc: isliqAddComissaoNacCC,
                liqaddovernaccc: isliqAddOverNacCC,

                liqdedtarifanaccc: isliqDedTarifaNacCC,
                liqdedtaxanaccc: isliqDedTaxaNacCC,
                liqdeddunaccc: isliqDedDUNacCC,
                liqdedcomissaonaccc: isliqDedComissaoNacCC,
                liqdedovernaccc: isliqDedOverNacCC,

                liqaddtarifaintiv: isliqAddTarifaIntIV,
                liqaddtaxaintiv: isliqAddTaxaIntIV,
                liqaddduintiv: isliqAddDUIntIV,
                liqaddcomissaointiv: isliqAddComissaoIntIV,
                liqaddoverintiv: isliqAddOverIntIV,

                liqdedtarifaintiv: isliqDedTarifaIntIV,
                liqdedtaxaintiv: isliqDedTaxaIntIV,
                liqdedduintiv: isliqDedDUIntIV,
                liqdedcomissaointiv: isliqDedComissaoIntIV,
                liqdedoverintiv: isliqDedOverIntIV,

                liqaddtarifaintcc: isliqAddTarifaIntCC,
                liqaddtaxaintcc: isliqAddTaxaIntCC,
                liqaddduintcc: isliqAddDUIntCC,
                liqaddcomissaointcc: isliqAddComissaoIntCC,
                liqaddoverintcc: isliqAddOverIntCC,

                liqdedtarifaintcc: isliqDedTarifaIntCC,
                liqdedtaxaintcc: isliqDedTaxaIntCC,
                liqdedduintcc: isliqDedDUIntCC,
                liqdedcomissaointcc: isliqDedComissaoIntCC,
                liqdedoverintcc: isliqDedOverIntCC,
              );

              bool sucesso = false;
              if ((operadoraAtual.idoperadora == null)|| (operadoraAtual.idoperadora == 0)) {

                final idGerado = await EntidadeService.createOperadora(operadora);

                if (idGerado != null) {
                    nroController.text = idGerado.toString();
                    var operadoraAux = Operadora(
                    entidadeid: int.tryParse(nroEntidadeController.text) ?? 0,
                    idoperadora: idGerado,

                    percomisnac: parseValor(percomisNacController.text),
                    overnac: parseValor(overNacController.text),
                    percomisint: parseValor(percomisIntController.text),
                    overint: parseValor(overIntController.text),

                    valorininac1:  parseValor(valoriniNac1Controller.text),
                    valorfinnac1: parseValor(valorfinNac1Controller.text),
                    valornac1: parseValor(valorNac1Controller.text),
                    percnac1: parseValor(percNac1Controller.text),

                    valorininac2: parseValor(valoriniNac2Controller.text),
                    valorfinnac2: parseValor(valorfinNac2Controller.text),
                    valornac2: parseValor(valorNac2Controller.text),
                    percnac2: parseValor(percNac2Controller.text),

                    valoriniint1: parseValor(valoriniInt1Controller.text),
                    valorfinint1: parseValor(valorfinInt1Controller.text),
                    valorint1: parseValor(valorInt1Controller.text),
                    percint1: parseValor(percInt1Controller.text),


                    valoriniint2: parseValor(valoriniInt2Controller.text),
                    valorfinint2: parseValor(valorfinInt2Controller.text),
                    valorint2: parseValor(valorInt2Controller.text),
                    percint2: parseValor(percInt2Controller.text),

                    liqaddtarifanaciv: isliqAddTarifaNacIV,
                    liqaddtaxanaciv: isliqAddTaxaNacIV,
                    liqadddunaciv: isliqAddDUNacIV,
                    liqaddcomissaonaciv: isliqAddComissaoNacIV,
                    liqaddovernaciv: isliqAddOverNacIV,

                    liqdedtarifanaciv: isliqDedTarifaNacIV,
                    liqdedtaxanaciv: isliqDedTaxaNacIV,
                    liqdeddunaciv: isliqDedDUNacIV,
                    liqdedcomissaonaciv: isliqDedComissaoNacIV,
                    liqdedovernaciv: isliqDedOverNacIV,

                    liqaddtarifanaccc: isliqAddTarifaNacCC,
                    liqaddtaxanaccc: isliqAddTaxaNacCC,
                    liqadddunaccc:  isliqAddDUNacCC,
                    liqaddcomissaonaccc: isliqAddComissaoNacCC,
                    liqaddovernaccc: isliqAddOverNacCC,

                    liqdedtarifanaccc: isliqDedTarifaNacCC,
                    liqdedtaxanaccc: isliqDedTaxaNacCC,
                    liqdeddunaccc: isliqDedDUNacCC,
                    liqdedcomissaonaccc: isliqDedComissaoNacCC,
                    liqdedovernaccc: isliqDedOverNacCC,

                    liqaddtarifaintiv: isliqAddTarifaIntIV,
                    liqaddtaxaintiv: isliqAddTaxaIntIV,
                    liqaddduintiv: isliqAddDUIntIV,
                    liqaddcomissaointiv: isliqAddComissaoIntIV,
                    liqaddoverintiv: isliqAddOverIntIV,

                    liqdedtarifaintiv: isliqDedTarifaIntIV,
                    liqdedtaxaintiv: isliqDedTaxaIntIV,
                    liqdedduintiv: isliqDedDUIntIV,
                    liqdedcomissaointiv: isliqDedComissaoIntIV,
                    liqdedoverintiv: isliqDedOverIntIV,

                    liqaddtarifaintcc: isliqAddTarifaIntCC,
                    liqaddtaxaintcc: isliqAddTaxaIntCC,
                    liqaddduintcc: isliqAddDUIntCC,
                    liqaddcomissaointcc: isliqAddComissaoIntCC,
                    liqaddoverintcc: isliqAddOverIntCC,

                    liqdedtarifaintcc: isliqDedTarifaIntCC,
                    liqdedtaxaintcc: isliqDedTaxaIntCC,
                    liqdedduintcc: isliqDedDUIntCC,
                    liqdedcomissaointcc: isliqDedComissaoIntCC,
                    liqdedoverintcc: isliqDedOverIntCC,

                    );
                    
                    atualizarOperadoraAtual(operadoraAux);                    
                    
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Informação.'),
                        content: const Text('Operadora salva com sucesso'),
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

                sucesso = await EntidadeService.updateOperadora(operadora);
                atualizarOperadoraAtual(operadora); 

                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Informação.'),
                    content: const Text('Operadora salva com sucesso.'),
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

    if ((operadoraAtual.idoperadora != 0)&&(operadoraAtual.idoperadora != null)){

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
              await EntidadeService.deleteOperadora(id);
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
          onPressed: (habilitaSalvarCancelar) ?  () => onExcluir(operadoraAtual.idoperadora!) : null,
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
  /// checkbox
  /// ---------------------------
/*
  Widget buildCheckboxGroup() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('+Tarifa', isliqAddTarifaNacIV, (val) => setState(() => isliqAddTarifaNacIV = val!)),
              checkboxItem('+Taxa', isliqAddTaxaNacIV, (val) => setState(() => isliqAddTaxaNacIV = val!)),
              checkboxItem('+RAV', isliqAddDUNacIV, (val) => setState(() => isliqAddDUNacIV = val!)),
              checkboxItem('+Comissão', isliqAddComissaoNacIV, (val) => setState(() => isliqAddComissaoNacIV = val!)),
              checkboxItem('+Over', isliqAddOverNacIV, (val) => setState(() => isliqAddOverNacIV = val!)),
              checkboxItem('-Tarifa', isliqDedTarifaNacIV, (val) => setState(() => isliqDedTarifaNacIV = val!)),
              checkboxItem('-Taxa', isliqDedTaxaNacIV, (val) => setState(() => isliqDedTaxaNacIV = val!)),
              checkboxItem('-RAV', isliqDedDUNacIV, (val) => setState(() => isliqDedDUNacIV = val!)),
              checkboxItem('-Comissão', isliqDedComissaoNacIV, (val) => setState(() => isliqDedComissaoNacIV = val!)),
              checkboxItem('-Over', isliqDedOverNacIV, (val) => setState(() => isliqDedOverNacIV = val!)),
              checkboxItem('+Tarifa', isliqAddTarifaNacCC, (val) => setState(() => isliqAddTarifaNacCC = val!)),
              checkboxItem('+Taxa', isliqAddTaxaNacCC, (val) => setState(() => isliqAddTaxaNacCC = val!)),
              checkboxItem('+RAV', isliqAddDUNacCC, (val) => setState(() => isliqAddDUNacCC = val!)),
              checkboxItem('+Comissão', isliqAddComissaoNacCC, (val) => setState(() => isliqAddComissaoNacCC = val!)),
              checkboxItem('+Over', isliqAddOverNacCC, (val) => setState(() => isliqAddOverNacCC = val!)),
              checkboxItem('-Tarifa', isliqDedTarifaNacCC, (val) => setState(() => isliqDedTarifaNacCC = val!)),
              checkboxItem('-Taxa', isliqDedTaxaNacCC, (val) => setState(() => isliqDedTaxaNacCC = val!)),
              checkboxItem('-RAV', isliqDedDUNacCC, (val) => setState(() => isliqDedDUNacCC = val!)),
              checkboxItem('-Comissão', isliqDedComissaoNacCC, (val) => setState(() => isliqDedComissaoNacCC = val!)),
              checkboxItem('-Over', isliqDedOverNacCC, (val) => setState(() => isliqDedOverNacCC = val!)),
              checkboxItem('+Tarifa', isliqAddTarifaIntIV, (val) => setState(() => isliqAddTarifaIntIV = val!)),
              checkboxItem('+Taxa', isliqAddTaxaIntIV, (val) => setState(() => isliqAddTaxaIntIV = val!)),
              checkboxItem('+RAV', isliqAddDUIntIV, (val) => setState(() => isliqAddDUIntIV = val!)),
              checkboxItem('+Comissão', isliqAddComissaoIntIV, (val) => setState(() => isliqAddComissaoIntIV = val!)),
              checkboxItem('+Over', isliqAddOverIntIV, (val) => setState(() => isliqAddOverIntIV = val!)),
              checkboxItem('-Tarifa', isliqDedTarifaIntIV, (val) => setState(() => isliqDedTarifaIntIV = val!)),
              checkboxItem('-Taxa', isliqDedTaxaIntIV, (val) => setState(() => isliqDedTaxaIntIV = val!)),
              checkboxItem('-RAV', isliqDedDUIntIV, (val) => setState(() => isliqDedDUIntIV = val!)),
              checkboxItem('-Comissão', isliqDedComissaoIntIV, (val) => setState(() => isliqDedComissaoIntIV = val!)),
              checkboxItem('-Over', isliqDedOverIntIV, (val) => setState(() => isliqDedOverIntIV = val!)),
              checkboxItem('+Tarifa', isliqAddTarifaIntCC, (val) => setState(() => isliqAddTarifaIntCC = val!)),
              checkboxItem('+Taxa', isliqAddTaxaIntCC, (val) => setState(() => isliqAddTaxaIntCC = val!)),
              checkboxItem('+RAV', isliqAddDUIntCC, (val) => setState(() => isliqAddDUIntCC = val!)),
              checkboxItem('+Comissão', isliqAddComissaoIntCC, (val) => setState(() => isliqAddComissaoIntCC = val!)),
              checkboxItem('+Over', isliqAddOverIntCC, (val) => setState(() => isliqAddOverIntCC = val!)),
              checkboxItem('-Tarifa', isliqDedTarifaIntCC, (val) => setState(() => isliqDedTarifaIntCC = val!)),
              checkboxItem('-Taxa', isliqDedTaxaIntCC, (val) => setState(() => isliqDedTaxaIntCC = val!)),
              checkboxItem('-RAV', isliqDedDUIntCC, (val) => setState(() => isliqDedDUIntCC = val!)),
              checkboxItem('-Comissão', isliqDedComissaoIntCC, (val) => setState(() => isliqDedComissaoIntCC = val!)),
              checkboxItem('-Over', isliqDedOverIntCC, (val) => setState(() => isliqDedOverIntCC = val!)),
            ],
    );
  }
*/

  Widget buildCheckboxGroup1() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('+Tarifa', isliqAddTarifaNacIV, (val) => setState(() => isliqAddTarifaNacIV = val!)),
              checkboxItem('+Taxa', isliqAddTaxaNacIV, (val) => setState(() => isliqAddTaxaNacIV = val!)),
              checkboxItem('+RAV', isliqAddDUNacIV, (val) => setState(() => isliqAddDUNacIV = val!)),
              checkboxItem('+Comissão', isliqAddComissaoNacIV, (val) => setState(() => isliqAddComissaoNacIV = val!)),
              checkboxItem('+Over', isliqAddOverNacIV, (val) => setState(() => isliqAddOverNacIV = val!)),
            ],
    );
  }

  Widget buildCheckboxGroup2() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('-Tarifa', isliqDedTarifaNacIV, (val) => setState(() => isliqDedTarifaNacIV = val!)),
              checkboxItem('-Taxa', isliqDedTaxaNacIV, (val) => setState(() => isliqDedTaxaNacIV = val!)),
              checkboxItem('-RAV', isliqDedDUNacIV, (val) => setState(() => isliqDedDUNacIV = val!)),
              checkboxItem('-Comissão', isliqDedComissaoNacIV, (val) => setState(() => isliqDedComissaoNacIV = val!)),
              checkboxItem('-Over', isliqDedOverNacIV, (val) => setState(() => isliqDedOverNacIV = val!)),
            ],
    );
  }

  Widget buildCheckboxGroup3() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('+Tarifa', isliqAddTarifaNacCC, (val) => setState(() => isliqAddTarifaNacCC = val!)),
              checkboxItem('+Taxa', isliqAddTaxaNacCC, (val) => setState(() => isliqAddTaxaNacCC = val!)),
              checkboxItem('+RAV', isliqAddDUNacCC, (val) => setState(() => isliqAddDUNacCC = val!)),
              checkboxItem('+Comissão', isliqAddComissaoNacCC, (val) => setState(() => isliqAddComissaoNacCC = val!)),
              checkboxItem('+Over', isliqAddOverNacCC, (val) => setState(() => isliqAddOverNacCC = val!)),
            ],
    );
  }

  Widget buildCheckboxGroup4() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('-Tarifa', isliqDedTarifaNacCC, (val) => setState(() => isliqDedTarifaNacCC = val!)),
              checkboxItem('-Taxa', isliqDedTaxaNacCC, (val) => setState(() => isliqDedTaxaNacCC = val!)),
              checkboxItem('-RAV', isliqDedDUNacCC, (val) => setState(() => isliqDedDUNacCC = val!)),
              checkboxItem('-Comissão', isliqDedComissaoNacCC, (val) => setState(() => isliqDedComissaoNacCC = val!)),
              checkboxItem('-Over', isliqDedOverNacCC, (val) => setState(() => isliqDedOverNacCC = val!)),
            ],
    );
  }

  Widget buildCheckboxGroup5() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('+Tarifa', isliqAddTarifaIntIV, (val) => setState(() => isliqAddTarifaIntIV = val!)),
              checkboxItem('+Taxa', isliqAddTaxaIntIV, (val) => setState(() => isliqAddTaxaIntIV = val!)),
              checkboxItem('+RAV', isliqAddDUIntIV, (val) => setState(() => isliqAddDUIntIV = val!)),
              checkboxItem('+Comissão', isliqAddComissaoIntIV, (val) => setState(() => isliqAddComissaoIntIV = val!)),
              checkboxItem('+Over', isliqAddOverIntIV, (val) => setState(() => isliqAddOverIntIV = val!)),
            ],
    );
  }

  Widget buildCheckboxGroup6() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('-Tarifa', isliqDedTarifaIntIV, (val) => setState(() => isliqDedTarifaIntIV = val!)),
              checkboxItem('-Taxa', isliqDedTaxaIntIV, (val) => setState(() => isliqDedTaxaIntIV = val!)),
              checkboxItem('-RAV', isliqDedDUIntIV, (val) => setState(() => isliqDedDUIntIV = val!)),
              checkboxItem('-Comissão', isliqDedComissaoIntIV, (val) => setState(() => isliqDedComissaoIntIV = val!)),
              checkboxItem('-Over', isliqDedOverIntIV, (val) => setState(() => isliqDedOverIntIV = val!)),
            ],
    );
  }

  Widget buildCheckboxGroup7() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('+Tarifa', isliqAddTarifaIntCC, (val) => setState(() => isliqAddTarifaIntCC = val!)),
              checkboxItem('+Taxa', isliqAddTaxaIntCC, (val) => setState(() => isliqAddTaxaIntCC = val!)),
              checkboxItem('+RAV', isliqAddDUIntCC, (val) => setState(() => isliqAddDUIntCC = val!)),
              checkboxItem('+Comissão', isliqAddComissaoIntCC, (val) => setState(() => isliqAddComissaoIntCC = val!)),
              checkboxItem('+Over', isliqAddOverIntCC, (val) => setState(() => isliqAddOverIntCC = val!)),
            ],
    );
  }

  Widget buildCheckboxGroup8() {
    return Wrap(
        spacing: 16,
            runSpacing: 8,
            children: [
              checkboxItem('-Tarifa', isliqDedTarifaIntCC, (val) => setState(() => isliqDedTarifaIntCC = val!)),
              checkboxItem('-Taxa', isliqDedTaxaIntCC, (val) => setState(() => isliqDedTaxaIntCC = val!)),
              checkboxItem('-RAV', isliqDedDUIntCC, (val) => setState(() => isliqDedDUIntCC = val!)),
              checkboxItem('-Comissão', isliqDedComissaoIntCC, (val) => setState(() => isliqDedComissaoIntCC = val!)),
              checkboxItem('-Over', isliqDedOverIntCC, (val) => setState(() => isliqDedOverIntCC = val!)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Operadora')),
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

                        /*
                        buildFieldGroup(constraints, [

                          buildTextFieldValorDecimal('Comis.Nac.(%)', percomisNacController),
                          buildTextFieldValorDecimal('Over Nac.(%)', overNacController),
                          buildTextFieldValorDecimal('Comis.Int.(%)', percomisIntController),
                          buildTextFieldValorDecimal('Over Int.(%)', overIntController),
                          buildTextFieldValorDecimal('Val.Ini Nac.(1)', valoriniNac1Controller),
                          buildTextFieldValorDecimal('Val.Fin Nac.(1)', valorfinNac1Controller),
                          buildTextFieldValorDecimal('Val.Nac.(1)', valorNac1Controller),
                          buildTextFieldValorDecimal('Perc.Nac.(1)', percNac1Controller),
                          buildTextFieldValorDecimal('Val.Ini Nac.(2)', valoriniNac2Controller),
                          buildTextFieldValorDecimal('Val.Fin Nac.(2)', valorfinNac2Controller),
                          buildTextFieldValorDecimal('Val.Nac.(2)', valorNac2Controller),
                          buildTextFieldValorDecimal('Perc.Nac.(2)', percNac2Controller),
                          buildTextFieldValorDecimal('Val.Ini Int.(1)', valoriniInt1Controller),
                          buildTextFieldValorDecimal('Val Fin Int.(1)', valorfinInt1Controller),
                          buildTextFieldValorDecimal('Val. Int.(1)', valorInt1Controller),
                          buildTextFieldValorDecimal('Per. Int.(1)', percInt1Controller),
                          buildTextFieldValorDecimal('Val.Ini Int.(2)', valoriniInt2Controller),
                          buildTextFieldValorDecimal('Val.Fin Int.(2)', valorfinInt2Controller),
                          buildTextFieldValorDecimal('Val. Int.(2)', valorInt2Controller),
                          buildTextFieldValorDecimal('Per. Int.(2)', percInt2Controller),

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
                        */

                        /*COMISSÃO*/
                        buildFieldGroup(constraints, [

                          buildTextFieldValorDecimal('Comis.Nac.(%)', percomisNacController),
                          buildTextFieldValorDecimal('Over Nac.(%)', overNacController),

                        ]),
                        const SizedBox(height: 12),
                        buildFieldGroup(constraints, [

                          buildTextFieldValorDecimal('Comis.Int.(%)', percomisIntController),
                          buildTextFieldValorDecimal('Over Int.(%)', overIntController),

                        ]),

                        /*COMISSÃO POR INTERVALO NACIONAL*/
                        const SizedBox(height: 24),
                        buildTextField('', label7Controller, readOnly: true),
                        const SizedBox(height: 12),
                        buildFieldGroup(constraints, [

                          buildTextFieldValorDecimal('Val.Ini Nac.(1)', valoriniNac1Controller),
                          buildTextFieldValorDecimal('Val.Fin Nac.(1)', valorfinNac1Controller),
                          buildTextFieldValorDecimal('Val.Nac.(1)', valorNac1Controller),
                          buildTextFieldValorDecimal('Perc.Nac.(1)', percNac1Controller),
                          buildTextFieldValorDecimal('Val.Ini Nac.(2)', valoriniNac2Controller),
                          buildTextFieldValorDecimal('Val.Fin Nac.(2)', valorfinNac2Controller),
                          buildTextFieldValorDecimal('Val.Nac.(2)', valorNac2Controller),
                          buildTextFieldValorDecimal('Perc.Nac.(2)', percNac2Controller),

                        ]),

                        /*COMISSÃO POR INTERVALO INTERNACIONAL*/
                        const SizedBox(height: 24),
                        buildTextField('', label8Controller, readOnly: true),
                        const SizedBox(height: 12),
                        buildFieldGroup(constraints, [

                          buildTextFieldValorDecimal('Val.Ini Int.(1)', valoriniInt1Controller),
                          buildTextFieldValorDecimal('Val Fin Int.(1)', valorfinInt1Controller),
                          buildTextFieldValorDecimal('Val. Int.(1)', valorInt1Controller),
                          buildTextFieldValorDecimal('Per. Int.(1)', percInt1Controller),
                          buildTextFieldValorDecimal('Val.Ini Int.(2)', valoriniInt2Controller),
                          buildTextFieldValorDecimal('Val.Fin Int.(2)', valorfinInt2Controller),
                          buildTextFieldValorDecimal('Val. Int.(2)', valorInt2Controller),
                          buildTextFieldValorDecimal('Per. Int.(2)', percInt2Controller),

                        ]),

                        const SizedBox(height: 24),
                        buildTextField('', label1Controller, readOnly: true),
                        buildCheckboxGroup1(),
                        buildCheckboxGroup2(),
                        buildTextField('', label2Controller, readOnly: true),
                        buildCheckboxGroup3(),
                        buildCheckboxGroup4(),
                        buildTextField('', label3Controller, readOnly: true),
                        buildCheckboxGroup5(),
                        buildCheckboxGroup6(),
                        buildTextField('', label4Controller, readOnly: true),
                        buildCheckboxGroup7(),
                        buildCheckboxGroup8(),


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
