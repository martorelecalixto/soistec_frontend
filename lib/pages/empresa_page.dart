import 'package:flutter/material.dart';
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

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';


//import 'package:sistrade/layout/base_layout.dart';
import '../../models/empresa_model.dart';
import '../../services/empresa_service.dart';
//import 'package:sistrade/widgets/filial_form.dart';
import '../../constants.dart';

class EmpresaScreen extends StatefulWidget {
  const EmpresaScreen({super.key});

  @override
  _EmpresaScreenState createState() => _EmpresaScreenState();
}

class _EmpresaScreenState extends State<EmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> empresas = [];
  List<Map<String, dynamic>> empresasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  bool habilitaSalvarCancelar = true;
  bool bloquearRequisicao = false; 
  bool exibirFormulario = false; 

  // Datas
  DateTime? dataVenda;
  DateTime? dataVencimento;

  // Controladores de texto
  final TextEditingController nroController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController razaoSocialController = TextEditingController();
  final TextEditingController cnpjCpfController = TextEditingController();
  final TextEditingController celular1Controller = TextEditingController();
  final TextEditingController celular2Controller = TextEditingController();
  final TextEditingController telefone1Controller = TextEditingController();
  final TextEditingController telefone2Controller = TextEditingController();
  final TextEditingController redesSociaisController = TextEditingController();
  final TextEditingController homeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();

  // Máscaras
  final cnpjCpfMask = MaskTextInputFormatter(mask: '##.###.###/####-##');
  final telefoneMask = MaskTextInputFormatter(mask: '(##) #####-####');
  final cepMask = MaskTextInputFormatter(mask: '#####-###');

  final double fontSize = 12.0; // tamanho padrão da fonte  


  @override
  void initState() {
    super.initState();
    _carregarEmpresas();
  }

  Future<void> _buscarCep(String cep) async {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        logradouroController.text = data['logradouro'] ?? '';
        bairroController.text = data['bairro'] ?? '';
        cidadeController.text = data['localidade'] ?? '';
        estadoController.text = data['uf'] ?? '';
      });
    }
  }

  Future<void> _carregarEmpresas() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final codigoempresa = prefs.getString('empresa');
      final idempresa = prefs.getInt('idempresa');

      //final List<Empresa> resultado = await EmpresaService.getEmpresas();
      final Empresa empresa = await EmpresaService.getEmpresaById(idempresa.toString());

      setState(() {
        nroController.text = empresa.idempresa?.toString() ?? '';
        nomeController.text = empresa.nome ?? '';
        razaoSocialController.text = empresa.razaosocial ?? '';
        cnpjCpfController.text = empresa.cnpjcpf ?? '';
        celular1Controller.text = empresa.celular1 ?? '';
        celular2Controller.text = empresa.celular2 ?? '';
        telefone1Controller.text = empresa.telefone1 ?? '';
        telefone2Controller.text = empresa.telefone2 ?? '';
        redesSociaisController.text = empresa.redessociais ?? '';
        homeController.text = empresa.home ?? '';
        emailController.text = empresa.email ?? '';
        cepController.text = empresa.cep ?? '';
        logradouroController.text = empresa.logradouro ?? '';
        numeroController.text = empresa.numero ?? '';
        complementoController.text = empresa.complemento ?? '';
        bairroController.text = empresa.bairro ?? '';
        cidadeController.text = empresa.cidade ?? '';
        estadoController.text = empresa.estado ?? '';

        habilitaSalvarCancelar = true;

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void onSalvar() async {
    try{
    final prefs = await SharedPreferences.getInstance();
    final codigoempresa = prefs.getString('empresa');

    if (codigoempresa == null || codigoempresa.isEmpty) {
      throw Exception('Empresa não definida nas preferências.');
    }

    if (_formKey.currentState!.validate()) {
      final empresa = Empresa(
        idempresa:  int.tryParse(nroController.text) != 0 ? int.tryParse(nroController.text) : null,
        nome: nomeController.text,
        razaosocial: razaoSocialController.text,
        cnpjcpf: cnpjCpfController.text,
        celular1: celular1Controller.text,
        celular2: celular2Controller.text,
        telefone1: telefone1Controller.text,
        telefone2: telefone2Controller.text,
        redessociais: redesSociaisController.text,
        home: homeController.text,
        email: emailController.text,
        cep: cepController.text,
        logradouro: logradouroController.text,
        numero: numeroController.text,
        complemento: complementoController.text,
        bairro: bairroController.text,
        cidade: cidadeController.text,
        estado: estadoController.text,
        codigoempresa: codigoempresa,
      );

      bool sucesso = false;
      if ((nroController.text == '')||(nroController.text == '0')) {
        //print('ENTROU INSERT');
       // sucesso = await EmpresaService.createEmpresa(empresa);
      } else {
        //print('ENTROU UPDATE');
        sucesso = await EmpresaService.updateEmpresa(empresa);

        _carregarEmpresas();

        final confirmar = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Confirmação'),
            content: const Text('Empresa salva com sucesso'),
            actions: [
              // TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
            ],
          ),
        );        
      }

     // if (sucesso) {
     //   Navigator.pop(context, true);
     // } else {
        // Trate o erro conforme necessário
     // }
    }

    } catch (e) {
      print('Erro de conexão: $e');
    }    

  }

  void onImprimir() async{
    if ((nroController.text != '0')&&(nroController.text != '')){

      /*###################################################*/
      final pdf = pw.Document();
      final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

      final cadEmpresa = await EmpresaService.getEmpresaById(nroController.text);

      //final logomarca = '${retirarcaracteres(enderecoFilial.cnpjcpf!)}.png';
      final imageLogo = await imageFromAssetBundle('assets/logo.png'); 
      //final imageLogo = await imageFromAssetBundle('assets/$logomarca'); // substitua pelo caminho correto do seu logo

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cadastro - $dataAtual',
                  style: pw.TextStyle(font: fontBold),//pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 4),

                pw.Divider(thickness: 1),

                pw.SizedBox(height: 20),
                
                // Linha 1
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Nome',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.nome.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Razão Social',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.razaosocial.toString()),
                          ],
                        ),
                      ),
                    ),                    

                  ],
                ),

                pw.SizedBox(height: 8),

                // Linha 2
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('CNPJ',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.cnpjcpf.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('E-mail',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.email.toString()),
                          ],
                        ),
                      ),
                    ),                    

                  ],
                ),

                pw.SizedBox(height: 4),

                // Linha 3
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Telefone(1)',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.telefone1.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Telefone(2)',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.telefone2.toString()),
                          ],
                        ),
                      ),
                    ),                    

                  ],
                ),

                pw.SizedBox(height: 8),

                // Linha 4
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Celular(1)',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.celular1.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            //pw.Text('Empresa Nº ${cadEmpresa.idempresa.toString().padLeft(5, '0')}'),
                            pw.Text('Celular(2)',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.celular2.toString()),
                          ],
                        ),
                      ),
                    ),                    

                  ],
                ),

                pw.SizedBox(height: 8),

                // Linha 5
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Home',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.home.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Rede Social',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.redessociais.toString()),
                          ],
                        ),
                      ),
                    ),                    

                  ],
                ),

                pw.SizedBox(height: 8),

                // Linha 6
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Logradouro',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.logradouro.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Nº',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.numero.toString()),
                          ],
                        ),
                      ),
                    ),                    

                  ],
                ),

                pw.SizedBox(height: 8),

                // Linha 7
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Complemento',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.complemento.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Bairro',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.bairro.toString()),
                          ],
                        ),
                      ),
                    ),                    

                  ],
                ),

                pw.SizedBox(height: 8),

                // Linha 
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    //pw.Container(width: 100, height: 100, child: pw.Image(imageLogo)),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 0), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Cidade',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.cidade.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('UF',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.estado.toString()),
                          ],
                        ),
                      ),
                    ),                    
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 3), // <-- controla quanto anda pra direita
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start, // <-- continua alinhado à esquerda
                          children: [
                            pw.Text('Cep',style: pw.TextStyle(font: fontBold, fontSize: 11, ),),
                            pw.Text(cadEmpresa.cep.toString()),
                          ],
                        ),
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
        filename: 'cadastro_empresa.pdf',
      );
    }

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


 /// ---------------------------
 /// Buttons
 /// ---------------------------
  Widget buildButtonsRow() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar) ? onImprimir : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Imprimir'),
        ),
        ElevatedButton(
          onPressed: (habilitaSalvarCancelar) ? onSalvar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
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

  Widget _buildCabecalho(){
  return Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
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
                            _buildTextField(nomeController, 'Nome', validator: true),
                            _buildTextField(razaoSocialController, 'Razão Social'),
                            buildTextField('CNPJ', cnpjCpfController, readOnly: true), 
                            _buildTextField(celular1Controller, 'Celular 1', inputFormatters: [telefoneMask]), 
                            _buildTextField(celular2Controller, 'Celular 2', inputFormatters: [telefoneMask]),
                            _buildTextField(telefone1Controller, 'Telefone 1', inputFormatters: [telefoneMask]),
                            _buildTextField(telefone2Controller, 'Telefone 2', inputFormatters: [telefoneMask]),
                            _buildTextField(redesSociaisController, 'Redes Sociais'), 
                            _buildTextField(homeController, 'Home'), 
                            _buildTextField(emailController, 'Email', validator: true),
                            _buildTextField(cepController, 'CEP', inputFormatters: [cepMask], keyboardType: TextInputType.number, onFieldSubmitted: _buscarCep), 
                            _buildTextField(logradouroController, 'Logradouro'),
                            _buildTextField(numeroController, 'Número'), 
                            _buildTextField(complementoController, 'Complemento'), 
                            _buildTextField(bairroController, 'Bairro'),
                            _buildTextField(cidadeController, 'Cidade'), 
                            _buildTextField(estadoController, 'Estado'),
                          ]),

                          const SizedBox(height: 24),

                          buildButtonsRow(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );    
  }

  /// ---------------------------
  /// Build Geral
  /// ---------------------------
  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresa'),
        backgroundColor: bgColor,// Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCabecalho(),
            const SizedBox(height: 16),
         ////   Expanded(
         ////     child: isLoading
         ////         ? const Center(child: CircularProgressIndicator())
         ////         : largura > 600
         ////             ? _buildTabelaWeb(Theme.of(context).textTheme.bodyLarge, largura, 1200, 600)
         ////             : _buildListaMobile(textStyle),
         ///   ),
          ],
        ),
      ),
    );




  /*
    return BaseLayout(
      titulo: 'Empresa',
      conteudo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
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
                            _buildTextField(nomeController, 'Nome', validator: true),
                            _buildTextField(razaoSocialController, 'Razão Social'),
                            buildTextField('CNPJ', cnpjCpfController, readOnly: true), 
                            _buildTextField(celular1Controller, 'Celular 1', inputFormatters: [telefoneMask]), 
                            _buildTextField(celular2Controller, 'Celular 2', inputFormatters: [telefoneMask]),
                            _buildTextField(telefone1Controller, 'Telefone 1', inputFormatters: [telefoneMask]),
                            _buildTextField(telefone2Controller, 'Telefone 2', inputFormatters: [telefoneMask]),
                            _buildTextField(redesSociaisController, 'Redes Sociais'), 
                            _buildTextField(homeController, 'Home'), 
                            _buildTextField(emailController, 'Email', validator: true),
                            _buildTextField(cepController, 'CEP', inputFormatters: [cepMask], keyboardType: TextInputType.number, onFieldSubmitted: _buscarCep), 
                            _buildTextField(logradouroController, 'Logradouro'),
                            _buildTextField(numeroController, 'Número'), 
                            _buildTextField(complementoController, 'Complemento'), 
                            _buildTextField(bairroController, 'Bairro'),
                            _buildTextField(cidadeController, 'Cidade'), 
                            _buildTextField(estadoController, 'Estado'),
                          ]),

                          const SizedBox(height: 24),

                          buildButtonsRow(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
    */


  }
   
   

}