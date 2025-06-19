import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/acomodacao_model.dart';
import '../../services/acomodacao_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcomodacaoForm extends StatefulWidget {
  final Acomodacao? acomodacao;
  const AcomodacaoForm({super.key, this.acomodacao});

  @override
  _AcomodacaoFormState createState() => _AcomodacaoFormState();
}

class _AcomodacaoFormState extends State<AcomodacaoForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _nomeController = TextEditingController();

  final double fontSize = 12.0; // tamanho padrão da fonte  

  @override
  void initState() {
    super.initState();
    if (widget.acomodacao != null) {
      final f = widget.acomodacao!;
      _nomeController.text = f.nome ?? '';
    }
  }


  void _salvar() async {
    final prefs = await SharedPreferences.getInstance();
    final empresa = prefs.getString('empresa');

    if (empresa == null || empresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    if (_formKey.currentState!.validate()) {
      final acomodacao = Acomodacao(
        id: widget.acomodacao?.id ?? 0,
        nome: _nomeController.text,
        empresa: empresa,
      );

      bool sucesso;
      if (widget.acomodacao == null) {
        //print('ENTROU INSERT');
        sucesso = await AcomodacaoService.createAcomodacao(acomodacao);
      } else {
        //print('ENTROU UPDATE');
        sucesso = await AcomodacaoService.updateAcomodacao(acomodacao);
      }

      if (sucesso) {
        Navigator.pop(context, true);
      } else {
        // Trate o erro conforme necessário
      }
    }
  }

  Widget _buildResponsiveForm(double width) {
    int columns;
    if (width >= 1200) {
      columns = 4;
    } else if (width >= 900) {
      columns = 3;
    } else if (width >= 500) {
      columns = 2;
    } else {
      columns = 1;
    }
   

    // Lista de campos com suas respectivas larguras em colunas
    final fields = [
      {'widget': _buildTextField(_nomeController, 'Nome', validator: true), 'colSpan': columns},
    ];

    List<Widget> rows = [];
    List<Widget> currentRow = [];
    int currentColCount = 0;

    for (var field in fields) {
      int colSpan = field['colSpan'] as int;
      if (currentColCount + colSpan > columns) {
        rows.add(Row(
          children: currentRow,
        ));
        currentRow = [];
        currentColCount = 0;
      }
      currentRow.add(
        Expanded(
          flex: colSpan,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // menor espaçamento  //const EdgeInsets.all(8.0),
            child: field['widget'] as Widget,
          ),
        ),
      );
      currentColCount += colSpan;
    }

    if (currentRow.isNotEmpty) {
      rows.add(Row(
        children: currentRow,
      ));
    }

    return Column(
      children: rows,
    );
  }

Widget _buildTextField(
  TextEditingController controller,
  String label, {
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



@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 8,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Form(
              key: _formKey,
              child: 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cadastro de Acomodação',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildResponsiveForm(constraints.maxWidth),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _salvar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      ],
                    ),
              
              

            ),
          ),
        ),
      );
    },
  );
}


}
