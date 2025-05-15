
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistrade/layout/base_layout.dart';
import 'package:sistrade/models/vendabilhete_model.dart';
import 'package:sistrade/services/vendabilhete_service.dart';
import 'package:sistrade/services/filial_service.dart';
import 'package:sistrade/services/moeda_service.dart';
import 'package:sistrade/services/entidade_service.dart';
import 'package:sistrade/widgets/vendabilhete_form.dart';
//import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion_pdf;
//import 'package:pdf_google_fonts/pdf_google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;


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

class VendaBilhetePage extends StatefulWidget {
  const VendaBilhetePage({super.key});

  @override
  _VendaBilhetePageState createState() => _VendaBilhetePageState();
}

class _VendaBilhetePageState extends State<VendaBilhetePage> {
  List<Map<String, dynamic>> vendabilhete = [];
  List<Map<String, dynamic>> vendabilheteFiltradas = [];

  final TextEditingController _searchController = TextEditingController();
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  String? _filialSelecionada;
  String? _clienteSelecionado;
  String? _moedaSelecionada;

  List<Map<String, dynamic>> filiais = [];
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> moedas = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFiltros();
    _carregarVendaBilhete();
  }

  Future<void> _carregarFiltros() async {
      // Simulações de chamadas a endpoints
      final filiaisResponse = await FilialService.getFiliaisDropDown();
      final clientesResponse = await EntidadeService.getClientesDropDown();
      final moedasResponse = await MoedaService.getMoedasDropDown();

      setState(() {
        filiais = filiaisResponse.map((f) => {'id': f.idfilial, 'nome': f.nome}).toList();
        clientes = clientesResponse.map((c) => {'id': c.identidade, 'nome': c.nome}).toList();
        moedas = moedasResponse.map((m) => {'id': m.idmoeda, 'nome': m.nome}).toList();
      });    
  }

  Future<void> _carregarVendaBilhete({bool aplicarFiltros = false}) async {
    setState(() => isLoading = true);
    try {

      final List<VendaBilhete> resultado = await VendaBilheteService.getVendaBilhetes(
        idfilial: _filialSelecionada,
        idcliente: _clienteSelecionado,
        idmoeda: _moedaSelecionada,
        datainicial: _dataInicial,
        datafinal: _dataFinal,
      );

      final listaMapeada = resultado.map((f) => {
        'id': f.id,
        'datavenda': f.datavenda,
        'idvenda': f.idvenda,
        'entidade': f.entidade,
        'pagamento': f.pagamento,
        'valortotal': f.valortotal,
        'descontototal': f.descontototal,
        'valorentrada': f.valorentrada,
        'observacao': f.observacao,
        'solicitante': f.solicitante,
        'identidade': f.identidade,
        'empresa': f.empresa,
        'datavencimento': f.datavencimento,
        'idmoeda': f.idmoeda,
        'idvendedor': f.idvendedor,
        'idemissor': f.idemissor,
        'idformapagamento': f.idformapagamento,
        'idcentrocusto': f.idfilial, 
        'idfatura': f.idfatura,
        'idreciboreceber': f.idreciboreceber,
        'idgrupo': f.idgrupo,

      }).toList();

      setState(() {
        vendabilhete = listaMapeada;
        vendabilheteFiltradas = listaMapeada;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filtrarVendaBilhete(String valor) {
    final query = valor.toLowerCase();
    final filtradas = vendabilhete.where((item) {
      final id = item['id']?.toString().toLowerCase() ?? '';
      final entidade = item['entidade']?.toString().toLowerCase() ?? '';
      final datavendaStr = _formatarData(item['datavenda']);
      return id.contains(query) || datavendaStr.contains(query) || entidade.contains(query);
    }).toList();

    setState(() => vendabilheteFiltradas = filtradas);
  }

void _abrirFormulario({Map<String, dynamic>? vendabilhete}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 1200,
        height: 800,
        child: VendaBilheteForm(
          vendabilhete: vendabilhete != null ? VendaBilhete.fromJson(vendabilhete) : null,
        ),
      ),
    ),
  );

 if (resultado == true) _carregarVendaBilhete();
}

  void _confirmarExclusao(int idvenda) async {
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
      await VendaBilheteService.deleteVendaBilhete(idvenda);
      _carregarVendaBilhete();
    }
  }




Future<void> _imprimirPDF(List<Map<String, dynamic>> vendabilheteFiltradas, String Function(num) _formatarMoeda) async {
  final pdf = pw.Document();
  final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final roboto = pw.Font.ttf(fontData.buffer.asByteData());

  final totalGeral = vendabilheteFiltradas.fold<num>(0, (soma, item) => soma + (item['valortotal'] ?? 0));

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            pw.Center(
              child: pw.Text(
                'Relatório de Vendas',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: roboto),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                'Data de emissão: $dataAtual',
                style: pw.TextStyle(fontSize: 12, font: roboto),
              ),
            ),
            pw.SizedBox(height: 20),

            // Tabela com cabeçalho em fundo cinza
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
                4: pw.FlexColumnWidth(1.5),
              },
              children: [
                // Cabeçalho da tabela
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _celulaCabecalho('ID', roboto),
                  //  _celulaCabecalho('Data', roboto),
                    _celulaCabecalho('Entidade', roboto),
                    _celulaCabecalho('Pagamento', roboto),
                    _celulaCabecalho('Valor', roboto),
                  ],
                ),
                // Linhas de dados
                ...vendabilheteFiltradas.map((item) {
                  return pw.TableRow(
                    children: [
                      _celula('${item['id'] ?? ''}', roboto),
                   //   _celula('${item['datavenda'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(item['datavenda'])) : ''}', roboto),
                      _celula('${item['entidade'] ?? ''}', roboto),
                      _celula('${item['pagamento'] ?? ''}', roboto),
                      _celula(_formatarMoeda(item['valortotal'] ?? 0), roboto, alignRight: true),
                    ],
                  );
                }).toList(),
                // Total
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Container(padding: pw.EdgeInsets.all(8), child: pw.Text('', style: pw.TextStyle(font: roboto))),
                    pw.Container(padding: pw.EdgeInsets.all(8), child: pw.Text('', style: pw.TextStyle(font: roboto))),
                    pw.Container(
                      padding: pw.EdgeInsets.all(8),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: roboto)),
                    ),
                    pw.Container(padding: pw.EdgeInsets.all(8), child: pw.Text('', style: pw.TextStyle(font: roboto))),
                    pw.Container(
                      padding: pw.EdgeInsets.all(8),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(_formatarMoeda(totalGeral), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: roboto)),
                    ),
                  ],
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
    filename: 'relatorio_vendas.pdf',
  );
}

// Funções auxiliares para células
pw.Widget _celula(String texto, pw.Font fonte, {bool alignRight = false}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
    alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
    child: pw.Text(texto, style: pw.TextStyle(font: fonte, fontSize: 10)),
  );
}

pw.Widget _celulaCabecalho(String texto, pw.Font fonte) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(texto, style: pw.TextStyle(font: fonte, fontWeight: pw.FontWeight.bold, fontSize: 11)),
  );
}






/* POPUP
void _imprimirPDF() async {
  final pdf = pw.Document();
  final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Relatório de Vendas - $dataAtual',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Cabeçalho
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(flex: 2, child: pw.Text('Entidade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            pw.Divider(),

            // Dados
            ...vendabilheteFiltradas.map((item) {
              return pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('${item['id'] ?? ''}')),
                  pw.Expanded(flex: 2, child: pw.Text('${item['entidade'] ?? ''}')),
                  pw.Expanded(child: pw.Text('${_formatarMoeda(item['valortotal'] ?? 0)}')),
                ],
              );
            }).toList(),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
*/


/* DOWNLOAD
void _imprimirPDF() async {
  final pdf = pw.Document();
  final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Relatório de Vendas - $dataAtual',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              children: [
                pw.Expanded(child: pw.Text('ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(flex: 2, child: pw.Text('Entidade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Expanded(child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            ),
            pw.Divider(),
            ...vendabilheteFiltradas.map((item) {
              return pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('${item['id'] ?? ''}')),
                  pw.Expanded(flex: 2, child: pw.Text('${item['entidade'] ?? ''}')),
                  pw.Expanded(child: pw.Text('${_formatarMoeda(item['valortotal'] ?? 0)}')),
                ],
              );
            }).toList(),
          ],
        );
      },
    ),
  );

  // Em vez de abrir nova aba, força o download
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'relatorio_vendas.pdf',
  );
}
*/

@override
Widget build(BuildContext context) {
  final largura = MediaQuery.of(context).size.width;

  return BaseLayout(
    titulo: 'VendaBilhete',
    conteudo: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              // Filial
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _filialSelecionada,
                    hint: const Text('Filial'),
                    onChanged: (value) => setState(() => _filialSelecionada = value),
                    items: filiais.map((e) =>
                      DropdownMenuItem(value: e['id'].toString(), child: Text(e['nome']))).toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Limpar Filial',
                    onPressed: () => setState(() => _filialSelecionada = null),
                  ),
                ],
              ),

              // Cliente
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _clienteSelecionado,
                    hint: const Text('Cliente'),
                    onChanged: (value) => setState(() => _clienteSelecionado = value),
                    items: clientes.map((e) =>
                      DropdownMenuItem(value: e['id'].toString(), child: Text(e['nome']))).toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Limpar Cliente',
                    onPressed: () => setState(() => _clienteSelecionado = null),
                  ),
                ],
              ),

              // Moeda
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: _moedaSelecionada,
                    hint: const Text('Moeda'),
                    onChanged: (value) => setState(() => _moedaSelecionada = value),
                    items: moedas.map((e) =>
                      DropdownMenuItem(value: e['id'].toString(), child: Text(e['nome']))).toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Limpar Moeda',
                    onPressed: () => setState(() => _moedaSelecionada = null),
                  ),
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
                          : 'Data Inicial',
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
                          : 'Data Final',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Limpar Data Final',
                    onPressed: () => setState(() => _dataFinal = null),
                  ),
                ],
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
                    labelText: 'Buscar por cliente, nº ou data venda',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _filtrarVendaBilhete,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _carregarVendaBilhete,
                icon: const Icon(Icons.search),
                label: const Text('Consultar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _imprimirPDF(vendabilheteFiltradas, _formatarMoeda),//_imprimirPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Imprimir PDF'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => _abrirFormulario(),
                icon: const Icon(Icons.add),
                label: const Text('Nova Venda'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : largura > 600
                    ? _buildTabelaWeb(Theme.of(context).textTheme.bodyLarge, largura)
                    : _buildListaMobile(Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    ),
  );
}


Widget _buildTabelaWeb(TextStyle? textStyle, double largura) {
  if (vendabilheteFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma venda encontrada.'));
  }

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Ações', style: TextStyle(fontSize: 12))),
          DataColumn(label: Text('Nro', style: TextStyle(fontSize: 12))),
          if (largura > 800) DataColumn(label: const Text('Dt.Venda', style: TextStyle(fontSize: 12))),
          if (largura > 900) DataColumn(label: const Text('Cliente', style: TextStyle(fontSize: 12))),
          if (largura > 1000) DataColumn(label: const Text('Pagamento', style: TextStyle(fontSize: 12))),
          if (largura > 1100) DataColumn(label: const Text('Valor Total', style: TextStyle(fontSize: 12))),
        // if (largura > 1200) DataColumn(label: const Text('Telefone 1', style: TextStyle(fontSize: 12))),
        // if (largura > 1300) DataColumn(label: const Text('Telefone 2', style: TextStyle(fontSize: 12))),
        ],
        rows: vendabilheteFiltradas.asMap().entries.map((entry) {
          final index = entry.key;
          final vendabilhete = entry.value;
          final isEven = index % 2 == 0;

          return DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) =>
                  isEven ? Colors.blueGrey[100] : Colors.white,
            ),
            cells: [
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _abrirFormulario(vendabilhete: vendabilhete),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(vendabilhete['id']),
                  ),
                ],
              )),
              DataCell(Text(vendabilhete['id'].toString().padLeft(5, '0'), style: const TextStyle(fontSize: 12))),
              if (largura > 800) DataCell(Text( _formatarData(vendabilhete['datavenda'].toString()), style: const TextStyle(fontSize: 12))),
              if (largura > 900) DataCell(Text(vendabilhete['entidade'].toString(), style: const TextStyle(fontSize: 12))),
              if (largura > 1000) DataCell(Text(vendabilhete['pagamento'].toString(), style: const TextStyle(fontSize: 12))),
              if (largura > 1100) DataCell(Align( alignment: Alignment.centerRight,child: Text(_formatarMoeda(vendabilhete['valortotal']), style: const TextStyle(fontSize: 12)))),
            // if (largura > 1200) DataCell(Text(vendabilhete['datavencimento']  ?? '', style: const TextStyle(fontSize: 12))),
            // if (largura > 1300) DataCell(Text(vendabilhete['datavencimento']  ?? '', style: const TextStyle(fontSize: 12))),
            ],
          );
        }).toList(),
      ),
    ),
  );


}


Widget _buildListaMobile(TextStyle? textStyle) {
  if (vendabilheteFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma venda encontrada.'));
  }

  return ListView.builder(
    itemCount: vendabilheteFiltradas.length,
    itemBuilder: (_, index) {
      final vendabilhete = vendabilheteFiltradas[index];
      final isEven = index % 2 == 0;
      final backgroundColor = isEven ? Colors.blueGrey[100] : Colors.white;

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
                    onPressed: () => _abrirFormulario(vendabilhete: vendabilhete),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(vendabilhete['idvenda']),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Dados (à direita)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ // Text('datavenda: ${vendabilhete['datavenda']}'
                    Text(vendabilhete['id'].toString().padLeft(5, '0'), style: const TextStyle(fontSize: 12)),
                    Text(vendabilhete['entidade'].toString(), style: const TextStyle(fontSize: 12)),
                    //if ((filial['celular1'] ?? '').isNotEmpty)
                    //  Text('Celular: ${filial['celular1']}', style: const TextStyle(fontSize: 12)),
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


