import 'package:flutter/material.dart';
//import 'package:sistrade/layout/base_layout.dart';
import '../../models/tiposervico_model.dart';
import '../../services/tiposervico_service.dart';
import '../../widgets/tiposervico/tiposervico_form.dart';
import '../../constants.dart';

class TipoServicoScreen extends StatefulWidget {
  const TipoServicoScreen({super.key});

  @override
  _TipoServicoScreenState createState() => _TipoServicoScreenState();
}

class _TipoServicoScreenState extends State<TipoServicoScreen> {
  List<Map<String, dynamic>> tiposervicos = [];
  List<Map<String, dynamic>> tiposervicosFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarTipoServicos();
  }

  Future<void> _carregarTipoServicos() async {
    setState(() => isLoading = true);
    try {
      final List<TipoServico> resultado = await TipoServicoService.getTipoServicoHoteis();

      final listaMapeada = resultado.map((f) => {
            'id': f.id,
            'nome': f.nome,
          }).toList();

      setState(() {
        tiposervicos = listaMapeada;
        tiposervicosFiltradas = listaMapeada;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

 void _filtrarTipoServicos(String valor) {
  final query = valor.toLowerCase();
  final filtradas = tiposervicos.where((tiposervico) {
    final nome = tiposervico['nome']?.toLowerCase() ?? '';
    return nome.contains(query);
  }).toList();

  setState(() => tiposervicosFiltradas = filtradas);
}


 void _abrirFormulario({Map<String, dynamic>? tiposervico}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 600,
        height: 170,
        child: TipoServicoForm(
          tiposervico: tiposervico != null ? TipoServico.fromJson(tiposervico) : null,
        ),
      ),
    ),
  );

  if (resultado == true) _carregarTipoServicos();
}


  void _confirmarExclusao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta tipo serviços?'),
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
      await TipoServicoService.deleteTipoServicoHoteis(id);
      _carregarTipoServicos();
    }
  }

  Widget _buildCabecalho(){
    return             Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filtrarTipoServicos,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor de fundo azul
                    foregroundColor: Colors.white, // Cor do texto e ícone
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Tipo Serviço'),
                ),
              ],
            );

  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Tipo Serviço'),
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
                      ? _buildTabelaWeb(Theme.of(context).textTheme.bodyLarge, largura)
                      : _buildListaMobile(textStyle),
            ),
          ],
        ),
      ),
    );


/*
    return BaseLayout(
      titulo: 'TipoServico',
      conteudo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filtrarTipoServicos,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Cor de fundo azul
                    foregroundColor: Colors.white, // Cor do texto e ícone
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add),
                  label: const Text('Novo Tipo Serviço'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : largura > 600
                      ? _buildTabelaWeb(textStyle, largura)
                      : _buildListaMobile(textStyle),
            ),
          ],
        ),
      ),
    );
*/

  }

  Widget _buildTabelaWeb(TextStyle? textStyle, double largura) {
    if (tiposervicosFiltradas.isEmpty) {
      return const Center(child: Text('Nenhum tipo serviço encontrada.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blueGrey[200]),
          columns: [
            DataColumn(label: Text('Ações', style: TextStyle(fontSize: 12, fontFamily: 'Popins', color: Colors.black, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Nome', style: TextStyle(fontSize: 12, fontFamily: 'Popins', color: Colors.black, fontWeight: FontWeight.bold))),
          ],
          rows: tiposervicosFiltradas.asMap().entries.map((entry) {
            final index = entry.key;
            final tiposervico = entry.value;
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
                      onPressed: () => _abrirFormulario(tiposervico: tiposervico),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarExclusao(tiposervico['id']),
                    ),
                  ],
                )),
                DataCell(Text(tiposervico['nome'] ?? '',
                    style: const TextStyle(fontSize: 12))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }


  Widget _buildListaMobile(TextStyle? textStyle) {
    if (tiposervicosFiltradas.isEmpty) {
      return const Center(child: Text('Nenhum tipo serviço encontrada.'));
    }

    return ListView.builder(
      itemCount: tiposervicosFiltradas.length,
      itemBuilder: (_, index) {
        final tiposervico = tiposervicosFiltradas[index];
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
                      onPressed: () => _abrirFormulario(tiposervico: tiposervico),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarExclusao(tiposervico['id']),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Dados (à direita)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tiposervico['nome'] ?? '', style: const TextStyle(fontSize: 12, fontFamily: 'Popins', color: Colors.black, fontWeight: FontWeight.bold)),
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