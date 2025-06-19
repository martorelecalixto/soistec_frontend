import 'package:flutter/material.dart';
//import 'package:sistrade/layout/base_layout.dart';
import '../../models/entidade_model.dart';
import '../../services/entidade_service.dart';
import '../../widgets/entidade/entidade_form.dart';
import '../../services/atividade_service.dart';
import '../../services/filial_service.dart';


import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion_pdf;
import 'package:flutter/services.dart' show rootBundle;

import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

import '../../constants.dart';

class EntidadeScreen extends StatefulWidget {
  const EntidadeScreen({super.key});

  @override
  _EntidadeScreenState createState() => _EntidadeScreenState();
}

class _EntidadeScreenState extends State<EntidadeScreen> {
  List<Map<String, dynamic>> entidades = [];
  List<Map<String, dynamic>> entidadesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

  DateTime? _dataInicial;
  DateTime? _dataFinal;
  String? _nome;
  String? _atividadeSelecionada;

  List<Map<String, dynamic>> filiais = [];
  List<Map<String, dynamic>> atividades = [];

  bool isLoading = true;

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarFiltros();
    _carregarEntidades();
  }

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

  Future<void> _carregarFiltros() async {
      // Simulações de chamadas a endpoints
      final filiaisResponse = await FilialService.getFiliaisDropDown();

      setState(() {
        filiais = filiaisResponse.map((f) => {'id': f.idfilial, 'nome': f.nome}).toList();
      });    
  }

  Future<void> _carregarEntidades() async {
    setState(() => isLoading = true);
    try {
      // Verifica se todos os filtros estão vazios/nulos
      final bool filtrosVazios = _nome == '' &&
                                _dataInicial == null &&
                                _dataFinal == null;

      // Define datainicial padrão se necessário
  //    final DateTime? dataInicialConsulta = filtrosVazios
  //        ? DateTime.now().subtract(const Duration(days: 7))
  //        : _dataInicial;

      final List<Entidade> resultado = await EntidadeService.getEntidades(
        nome: _nome,
        datainicial: _dataInicial,
        datafinal: _dataFinal,
      );

      //final List<Entidade> resultado = await EntidadeService.getEntidades();

      final listaMapeada = resultado.map((f) => {
            'identidade': f.identidade,
            'nome': f.nome,
            'email': f.email,
            'datanascimento': f.datanascimento,
            'datacadastro': f.datacadastro,
            'cnpjcpf': f.cnpjcpf,
            'celular1': f.celular1,
            'celular2': f.celular2,
            'telefone1': f.telefone1,
            'telefone2': f.telefone2,
            'ativo': f.ativo,
            'cli': f.cli,
            'cia': f.cia,
            'for': f.for_,
            'vend': f.vend,
            'emis': f.emis,
            'mot': f.mot,
            'gui': f.gui,
            'ope': f.ope,
            'hot': f.hot,
            'sigla': f.sigla,
            'cartao_sigla_1': f.cartaosigla1,
            'cartao_numero_1': f.cartaonumero1,
            'cartao_mesvencimento_1': f.cartaomesvencimento1,
            'carta_anovencimento_1': f.cartaoanovencimento1,
            'cartao_diafechamento_1': f.cartaodiafechamento1,
            'cartao_titular_1': f.cartaotitular1,
            'cartao_sigla_2': f.cartaosigla2,
            'cartao_numero_2': f.cartaonumero2,
            'cartao_mesvencimento_2': f.cartaomesvencimento2,
            'carta_anovencimento_2': f.cartaoanovencimento2,
            'cartao_diafechamento_2': f.cartaodiafechamento2,
            'cartao_titular_2': f.cartaotitular2,
            'chave': f.chave,
            'atividadeid': f.atividadeid,
            'empresa': f.empresa,
            'seg': f.seg,
            'ter': f.ter,
            'loc': f.loc,
            'pes': f.pes,
            'documento': f.documento,
            'tipodocumento': f.tipodocumento,
          }).toList();

      setState(() {
        entidades = listaMapeada;
        entidadesFiltradas = listaMapeada;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filtrarEntidades(String valor) {
    final query = valor.toLowerCase();

    final filtradas = entidades.where((item) {
      final nome = item['nome']?.toLowerCase() ?? '';
      final email = item['email']?.toLowerCase() ?? '';
      final cnpj = item['cnpjcpf']?.toLowerCase() ?? '';
      final nascimentoStr = _formatarData(item['datanascimento']);
      final celular1 = item['celular1']?.toLowerCase() ?? '';
      final celular2 = item['celular2']?.toLowerCase() ?? '';
      final telefone1 = item['telefone1']?.toLowerCase() ?? '';
      final telefone2 = item['telefone2']?.toLowerCase() ?? '';
      return nome.contains(query) || email.contains(query) || cnpj.contains(query) ||
      nascimentoStr.contains(query) || celular1.contains(query) || celular2.contains(query) ||
      telefone1.contains(query) || telefone2.contains(query);
    }).toList();

    setState(() => entidadesFiltradas = filtradas);
  }

  void _abrirFormularioEntidade({Map<String, dynamic>? entidade}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 1200,
          height: 650,
          child: EntidadeForm(
            entidade: entidade != null ? Entidade.fromJson(entidade) : null,
          ),
        ),
      ),
    );

    _carregarEntidades();

    //if (resultado == true) _carregarVendaBilhete();
  }

  void _confirmarExclusao(int identidade) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta entidade?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar == true) {
      await EntidadeService.deleteEntidade(identidade);
      _carregarEntidades();
    }
  }
 
  /* DOWNLOAD*/
  void _imprimirPDF() async {
    final pdf = pw.Document();
    final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Relatório de Entidades - $dataAtual',
                style: pw.TextStyle(font: fontBold),//pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Nome', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(child: pw.Text('E-mail', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(child: pw.Text('CNPJ/CPF', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(child: pw.Text('Nascimento', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(child: pw.Text('Telefone(1)', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(child: pw.Text('Celular(1)', style: pw.TextStyle(font: fontBold))),
                ],
              ),
              pw.Divider(),
              ...entidadesFiltradas.map((item) {
                return pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(item['nome'].toString())),
                    pw.Expanded(child: pw.Text(item['email'].toString())),
                    pw.Expanded(child: pw.Text(item['cnpjcpf'].toString())),
                    pw.Expanded(child: pw.Text(_formatarData(item['datanascimento'] ?? ''))),
                    pw.Expanded(child: pw.Text(item['telefone1'].toString())),
                    pw.Expanded(child: pw.Text(item['celular1'].toString())),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );

    // Em vez de abrir nova aba, força o download
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'relatorio_entidades.pdf',
    );
  }

  Widget _buildCabecalho() {
          return  Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [

                // Nome
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 300, // largura do campo de texto
                      child: TextField(
                        //controller: _filtroTextoController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          isDense: true,
                        ),
                        onChanged: (value) {
                          // lógica do filtro opcional
                          if (value != '') {
                            setState(() => _nome = value);
                          } else {
                            setState(() => _nome = '');
                          }
                        },
                      ),
                    ),
                    //const SizedBox(width: 12),
                  ],
                ),


                // Data Inicial
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (data != null) setState(() => _dataInicial = data);
                      },
                      child: Text(
                        _dataInicial != null
                            ? 'Início: ${DateFormat('dd/MM/yyyy').format(_dataInicial!)}'
                            : 'Data Nascimento',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpar Data Inicial',
                      onPressed: () => setState(() => _dataInicial = null),
                    ),
                  ],
                ),

                // Data Final
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (data != null) setState(() => _dataFinal = data);
                      },
                      child: Text(
                        _dataFinal != null
                            ? 'Final: ${DateFormat('dd/MM/yyyy').format(_dataFinal!)}'
                            : 'Data Nascimento',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpar Data Final',
                      onPressed: () => setState(() => _dataFinal = null),
                    ),
                  ],
                ),
             
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar por nome, cnpj/cpf, email, telefone, celular, data nasc.',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: _filtrarEntidades,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _carregarEntidades,
                      icon: const Icon(Icons.search),
                      label: const Text('Consultar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _imprimirPDF(), //_imprimirPDF(vendabilheteFiltradas, _formatarMoeda),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Imprimir PDF'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () => _abrirFormularioEntidade(),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Entidade'),
                    ),
                  ],
                ),

              ],
            );

    /*
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar por nome',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filtrarFiliais,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => _abrirFormulario(),
          icon: const Icon(Icons.add),
          label: const Text('Nova Filial'),
        ),
      ],
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entidades'),
        backgroundColor: bgColor,// Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCabecalho(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : largura > 600
                      ? _buildTabelaWeb(Theme.of(context).textTheme.bodyLarge, largura, 1200, 600)
                      : _buildListaMobile(textStyle),
            ),
          ],
        ),
      ),
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


  Widget _buildTabelaWeb(TextStyle? textStyle, double largura, double width, double height) {
    if (entidadesFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma entidade encontrada.'));
    }

    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              notificationPredicate: (notification) => notification.depth == 1,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: width),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.blueGrey[200]),
                    headingRowHeight: 40,
                    dataRowHeight: 40,
                    columnSpacing: 20,
                    columns: [
                      _buildColumn('Ações', 100),
                      //_buildColumn('Nro', 40),
                      if (largura > 800) _buildColumn('Nome', 100),
                      if (largura > 900) _buildColumn('E-mail', 200),
                      if (largura > 1000) _buildColumn('CNPJ/CPF', 150),
                      if (largura > 1100) _buildColumn('Nascimento', 120),
                      if (largura > 1200) _buildColumn('Telefone(1)', 120),
                      if (largura > 1300) _buildColumn('Celular(1)', 120),
                    ],
                    rows: entidadesFiltradas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final entidade = entry.value;
                      final isEven = index % 2 == 0;

                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) =>
                              isEven ? const Color.fromARGB(255, 32, 114, 150) : const Color.fromARGB(255, 109, 153, 172),// Colors.grey.shade200 : Colors.white,
                        ),
                        cells: [
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _abrirFormularioEntidade(entidade: entidade),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmarExclusao(entidade['id']),
                              ),
                            ],
                          )),
                          if (largura > 800)
                            DataCell(SizedBox(
                              width: 150,
                              child: Text(
                                //_formatarData(entidade['datavenda'].toString()),
                                entidade['nome'].toString(),
                                style: const TextStyle(fontSize: 11),
                              ),
                            )),
                          if (largura > 900)
                            DataCell(SizedBox(
                              width: 150,
                              child: Text(
                                entidade['email'].toString(),
                                style: const TextStyle(fontSize: 1),
                              ),
                            )),
                          if (largura > 1000)
                            DataCell(SizedBox(
                              width: 80,
                              child: Text(
                                entidade['cnpjcpf'].toString() ?? '',
                                style: const TextStyle(fontSize: 11),
                              ),
                            )),
                          if (largura > 1100)
                            DataCell(SizedBox(
                              width: 80,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                 _formatarData(entidade['datanascimento'].toString()),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            )),
                          if (largura > 1200)
                            DataCell(SizedBox(
                              width: 80,
                              child: Text(
                                entidade['telefone1'].toString(),
                                style: const TextStyle(fontSize: 11),
                              ),
                            )),
                          if (largura > 1300)
                            DataCell(SizedBox(
                              width: 80,
                              child: Text(
                                entidade['celular1'].toString() ?? '',
                                style: const TextStyle(fontSize: 11),
                              ),
                            )),

                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  DataColumn _buildColumn(String label, double width) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          //style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          style: const TextStyle(fontSize: 12, fontFamily: 'Popins', color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  } 


  Widget _buildListaMobile(TextStyle? textStyle) {
    if (entidadesFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma entidade encontrada.'));
    }

    return ListView.builder(
      itemCount: entidadesFiltradas.length,
      itemBuilder: (_, index) {
        final entidade = entidadesFiltradas[index];
        final isEven = index % 2 == 0;
        final backgroundColor = isEven ? const Color.fromARGB(255, 32, 114, 150) : const Color.fromARGB(255, 109, 153, 172);

        return Card(
          color: backgroundColor,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna de botões (à esquerda)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () =>  _abrirFormularioEntidade(entidade: entidade),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarExclusao(entidade['identidade']),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Dados (à direita)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entidade['nome'] ?? '', style: const TextStyle(fontSize: 12)),
                      if ((entidade['email'] ?? '').isNotEmpty)
                        Text('Email: ${entidade['email']}', style: const TextStyle(fontSize: 12)),
                      if ((entidade['cnpjcpf'] ?? '').isNotEmpty)
                        Text('CNPJ: ${entidade['cnpjcpf']}', style: const TextStyle(fontSize: 12)),
                      if ((entidade['celular1'] ?? '').isNotEmpty)
                        Text('Celular: ${entidade['celular1']}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}