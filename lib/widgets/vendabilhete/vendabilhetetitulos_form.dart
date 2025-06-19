import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import '../../models/tituloreceber_model.dart';
import '../../services/tituloreceber_service.dart';


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

class VendaBilheteTitulosForm extends StatefulWidget {
  final int? idvenda;
  final double? width;
  final double? height;

  const VendaBilheteTitulosForm({
    super.key,
    this.idvenda,
    this.width,
    this.height,
  });

  @override
  _VendaBilheteTitulosFormState createState() => _VendaBilheteTitulosFormState();
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

class _VendaBilheteTitulosFormState extends State<VendaBilheteTitulosForm> {
  final _formKey = GlobalKey<FormState>();

  List<TituloReceber> _titulosreceber = [];
  int idvenda = 0;

  bool _isLoading = true;

  // Datas
  //DateTime? dataVenda;
  //DateTime? dataVencimento;

  bool habilitaSalvarCancelar = true;
  bool bloquearRequisicao = false;

  //int idReq = 0;
  //int idRec = 0;
  //int idTit = 0;

  @override
  void initState() {
    super.initState();
    // Inicializa o objeto com o que vier do widget ou cria um novo
    idvenda = widget.idvenda ?? 0;
    _init();
  }

  void _init() async {
    setState(() => _isLoading = true);
   // await loadDropdownData(); // Aguarda dropdowns
    await _carregarDadosIniciais(); // Só então carrega os dados
    setState(() => _isLoading = false);
  }  
  
  // Se quiser que o estado reaja caso o widget pai mude o objeto
  @override
  void didUpdateWidget(covariant VendaBilheteTitulosForm oldWidget) {
    super.didUpdateWidget(oldWidget);
      setState(() {
        idvenda = widget.idvenda ?? 0;
      });
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

    bool bloquear = await bloquearVenda(); 
    final tit = await TituloReceberService.getTituloReceberByVendaBilhete(
      idvenda.toString()
    );

    setState(() {
      _titulosreceber = tit;
      bloquearRequisicao = bloquear;
    });

    setState(() {
    });
  }

  Future<void> loadDropdownData() async {
    setState(() {
      });      
    setState(() {});
  }

  Future<bool> bloquearVenda() async {
    var bloquear = false;
    return bloquear;
  }

 /// ---------------------------
 /// Buttons
 /// ---------------------------
  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Títulos'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Requisição'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Recibo'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Bilhete'),
        ),
        ElevatedButton(
          onPressed: habilitaSalvarCancelar ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Nova Venda'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? null : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar && (!bloquearRequisicao)) ? null : null,
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
 /*
  Widget buildListView() {
    if (_titulosreceber.isEmpty) {
      return const Center(child: Text('Nenhum bilhete encontrado.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Titulos',
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
                      //DataColumn(label: Text('Ações')),
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Cliente')),
                      DataColumn(label: Text('Pagamento')),
                      DataColumn(label: Text('Descrição')),
                      DataColumn(label: Text('Valor')),
                    ],
                    rows: _titulosreceber.map((item) {
                      return DataRow(cells: [
                      /*
                        DataCell(Row(children: [
                          //IconButton(onPressed: () =>  print('Item clicado: ${item.toJson()}'), icon: const Icon(Icons.edit)),
                          IconButton(onPressed: () =>  null, icon: const Icon(Icons.edit, color: Colors.orange)),
                          if(!bloquearRequisicao)
                          IconButton(onPressed: () => null, icon: const Icon(Icons.delete, color: Colors.red,),  ),
                        ])),
                       */
                        DataCell(Text(item.id != null ? item.id.toString() : '')),
                        DataCell(Text(item.entidade ?? '')),
                        DataCell(Text(item.pagamento ?? '')),
                        DataCell(Text(item.descricao ?? '')),
                        DataCell(Text(
                          NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
                              .format(item.valor ?? 0.0),
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
*/

/*FUNCIONANDO
Widget buildListView() {
  if (_titulosreceber.isEmpty) {
    return const Center(child: Text('Nenhum título encontrado.'));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Títulos',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1200),
            child: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 16,
                  columns: const [
                    //DataColumn(label: Text('Ações')),
                    DataColumn(label: Text('Id')),
                    DataColumn(label: Text('Cliente')),
                    DataColumn(label: Text('Pagamento')),
                    DataColumn(label: Text('Descrição')),
                    DataColumn(label: Text('Valor')),
                  ],
                  rows: _titulosreceber.map((item) {
                    return DataRow(cells: [
                      /*DataCell(SizedBox(
                        width: 90,
                        child: Row(children: [
                          IconButton(
                            onPressed: () {
                              // ação editar
                              print('Editar título ${item.id}');
                            },
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            onPressed: () {
                              // ação excluir
                              print('Excluir título ${item.id}');
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Excluir',
                          ),
                        ]),
                      )),*/
                      DataCell(SizedBox(
                        width: 20,
                        child: Text(item.id?.toString() ?? ''),
                      )),
                      DataCell(SizedBox(
                        width: 200,
                        child: Text(item.entidade ?? ''),
                      )),
                      DataCell(SizedBox(
                        width: 100,
                        child: Text(item.pagamento ?? ''),
                      )),
                      DataCell(SizedBox(
                        width: 300,
                        child: Text(item.descricao ?? ''),
                      )),
                      DataCell(SizedBox(
                        width: 100,
                        child: Text(
                          NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
                              .format(item.valor ?? 0.0),
                        ),
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
*/
Widget buildListView() {
  if (_titulosreceber.isEmpty) {
    return const Center(child: Text('Nenhum título encontrado.'));
  }

  return Container(
    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        columns: const [
        //  DataColumn(label: SizedBox(width: 90, child: Text('Ações'))),
          DataColumn(label: SizedBox(width: 50, child: Text('Id'))),
          DataColumn(label: SizedBox(width: 200, child: Text('Cliente'))),
          DataColumn(label: SizedBox(width: 120, child: Text('Pagamento'))),
          DataColumn(label: SizedBox(width: 400, child: Text('Descrição'))),
          DataColumn(label: SizedBox(width: 100, child: Text('Valor'))),
        ],
        rows: _titulosreceber.map((item) {
          return DataRow(cells: [
           /* DataCell(SizedBox(
              width: 90,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    tooltip: 'Editar',
                    onPressed: () => print('Editar título ${item.id}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Excluir',
                    onPressed: () => print('Excluir título ${item.id}'),
                  ),
                ],
              ),
            )),*/
            DataCell(SizedBox(
              width: 20,
              child: Text(item.id?.toString() ?? ''),
            )),
            DataCell(SizedBox(
              width: 200,
              child: Text(item.entidade ?? ''),
            )),
            DataCell(SizedBox(
              width: 120,
              child: Text(item.pagamento ?? ''),
            )),
            DataCell(SizedBox(
              width: 300,
              child: Text(item.descricao ?? ''),
            )),
            DataCell(SizedBox(
              width: 100,
              child: Text(
                NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2)
                    .format(item.valor ?? 0.0),
              ),
            )),
          ]);
        }).toList(),
      ),
    ),
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
    } else if (maxWidth >= 700) {
      columns = 2;
    } else {
      columns = 1;
    }

    List<Row> rows = [];
    for (int i = 0; i < fields.length; i += columns) {
      rows.add(Row(
        children: fields
            .skip(i)
            .take(columns)
            .map((field) => Expanded(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: field,
                )))
            .toList(),
      ));
    }

    return Column(children: rows);
  }


  /// ---------------------------
  /// Build Geral
  /// ---------------------------
  @override
  Widget build(BuildContext context) {
    bool showDateError = false;
    DateTime? selectedDate;
    return Scaffold(
      appBar: AppBar(title: const Text('Título da Requisição')),
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

                        ]),

                        const SizedBox(height: 24),

                        ///  Botões
                        //buildButtonsRow(),

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
