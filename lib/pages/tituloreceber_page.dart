
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:sistrade/layout/base_layout.dart';
import '../../models/vendabilhete_model.dart';
import '../../services/vendabilhete_service.dart';
import '../../services/filial_service.dart';
import '../../services/moeda_service.dart';
import '../../services/entidade_service.dart';
import '../../widgets/vendabilhete/vendabilhete_form.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import '../../constants.dart';


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

class TituloReceberScreen extends StatefulWidget {
  const TituloReceberScreen({
    super.key,
    });

  @override
  _TituloReceberScreenState createState() => _TituloReceberScreenState();
}

class _TituloReceberScreenState extends State<TituloReceberScreen> {
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
      // Verifica se todos os filtros estão vazios/nulos
      final bool filtrosVazios = _filialSelecionada == null &&
                                _clienteSelecionado == null &&
                                _moedaSelecionada == null &&
                                _dataInicial == null &&
                                _dataFinal == null;

      // Define datainicial padrão se necessário
      final DateTime? dataInicialConsulta = filtrosVazios
          ? DateTime.now().subtract(const Duration(days: 7))
          : _dataInicial;

      final List<VendaBilhete> resultado = await VendaBilheteService.getVendaBilhetes(
        idfilial: _filialSelecionada,
        idcliente: _clienteSelecionado,
        idmoeda: _moedaSelecionada,
        datainicial: dataInicialConsulta,
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
        'idcentrocusto': f.idcentrocusto, 
        'idfatura': f.idfatura,
        'idreciboreceber': f.idreciboreceber,
        'idgrupo': f.idgrupo,
        'idfilial': f.idfilial,
        'vendedor': f.vendedor,
        'emissor': f.emissor,
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


  void _abrirFormularioRequisicaoBilhete({Map<String, dynamic>? vendabilhete}) async {
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

    _carregarVendaBilhete();

    //if (resultado == true) _carregarVendaBilhete();
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
        try {
          await VendaBilheteService.deleteVendaBilhete(idvenda);
          mostrarMensagem(context, 'Venda excluída com sucesso!', titulo: 'Sucesso');
          _carregarVendaBilhete();
        } catch (e) {
          if (e is ApiException) {
            mostrarMensagem(context, e.message, titulo: 'Erro');
          } else {
            mostrarMensagem(context, 'Erro inesperado: $e', titulo: 'Erro');
          }
        }

      //await VendaBilheteService.deleteVendaBilhete(idvenda);
      //_carregarVendaBilhete();
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
                'Relatório de Venda Bilhete - $dataAtual',
                style: pw.TextStyle(font: fontBold),//pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  //pw.Expanded(child: pw.Text('Nro', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  //pw.Expanded(child: pw.Text('Dt.Venda', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                 // pw.Expanded(flex: 2, child: pw.Text('Cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                 // pw.Expanded(child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(child: pw.Text('Nro', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(child: pw.Text('Dt.Venda', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(flex: 2, child: pw.Text('Cliente', style: pw.TextStyle(font: fontBold))),
                  pw.Expanded(child: pw.Text('Valor', style: pw.TextStyle(font: fontBold))),
                ],
              ),
              pw.Divider(),
              ...vendabilheteFiltradas.map((item) {
                return pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(item['id'].toString().padLeft(5, '0') ?? '')),
                    pw.Expanded(child: pw.Text(_formatarData(item['datavenda'] ?? ''))),
                    pw.Expanded(flex: 2, child: pw.Text('${item['entidade'] ?? ''}')),
                    pw.Expanded(child: pw.Text(_formatarMoeda(item['valortotal'] ?? 0))),
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
      filename: 'relatorio_venda_bilhete.pdf',
    );
  }

  Widget _buildCabecalho(){
     return Wrap(
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
                      onPressed: () => _imprimirPDF(), //_imprimirPDF(vendabilheteFiltradas, _formatarMoeda),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Imprimir PDF'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () => _abrirFormularioRequisicaoBilhete(),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Venda'),
                    ),
                  ],
                ),

              ],
            );
 
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Titulos Receber'),
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
                      : _buildListaMobile(Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );



/*
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
                  onPressed: () => _imprimirPDF(), //_imprimirPDF(vendabilheteFiltradas, _formatarMoeda),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Imprimir PDF'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => _abrirFormularioRequisicaoBilhete(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Venda'),
                ),
              ],
            ),
            const SizedBox(height: 16,),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : largura > 600
                      ? _buildTabelaWeb(Theme.of(context).textTheme.bodyLarge, largura, 1200, 600)
                      : _buildListaMobile(Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
*/

  }
  

  Widget _buildTabelaWeb(TextStyle? textStyle, double largura, double width, double height) {
    if (vendabilheteFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma venda encontrada.'));
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
                      _buildColumn('Nro', 40),
                      if (largura > 800) _buildColumn('Dt.Venda', 100),
                      if (largura > 900) _buildColumn('Cliente', 200),
                      if (largura > 1000) _buildColumn('Pagamento', 150),
                      if (largura > 1100) _buildColumn('Valor Total', 120),
                    ],
                    rows: vendabilheteFiltradas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final vendabilhete = entry.value;
                      final isEven = index % 2 == 0;

                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) =>
                              isEven ? const Color.fromARGB(255, 32, 114, 150) : const Color.fromARGB(255, 109, 153, 172),
                        ),
                        cells: [
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _abrirFormularioRequisicaoBilhete(vendabilhete: vendabilhete),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmarExclusao(vendabilhete['id']),
                              ),
                            ],
                          )),
                          DataCell(SizedBox(
                            width: 80,
                            child: Text(
                              vendabilhete['id'].toString().padLeft(5, '0'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          )),
                          if (largura > 800)
                            DataCell(SizedBox(
                              width: 100,
                              child: Text(
                                _formatarData(vendabilhete['datavenda'].toString()),
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
                          if (largura > 900)
                            DataCell(SizedBox(
                              width: 200,
                              child: Text(
                                vendabilhete['entidade'].toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
                          if (largura > 1000)
                            DataCell(SizedBox(
                              width: 150,
                              child: Text(
                                vendabilhete['pagamento'].toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
                          if (largura > 1100)
                            DataCell(SizedBox(
                              width: 120,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _formatarMoeda(vendabilhete['valortotal']),
                                  style: const TextStyle(fontSize: 12),
                                ),
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
    if (vendabilheteFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma venda encontrada.'));
    }

    return ListView.builder(
      itemCount: vendabilheteFiltradas.length,
      itemBuilder: (_, index) {
        final vendabilhete = vendabilheteFiltradas[index];
        final isEven = index % 2 == 0;
        final backgroundColor = isEven ?  const Color.fromARGB(255, 32, 114, 150) : const Color.fromARGB(255, 109, 153, 172);

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
                      onPressed: () => _abrirFormularioRequisicaoBilhete(vendabilhete: vendabilhete),
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


