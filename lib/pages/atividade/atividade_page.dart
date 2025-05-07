import 'package:flutter/material.dart';
import 'package:sistrade/layout/base_layout.dart';
import 'package:sistrade/models/atividade_model.dart';
import 'package:sistrade/services/atividade_service.dart';
import 'package:sistrade/widgets/atividade_form.dart';

class AtividadePage extends StatefulWidget {
  const AtividadePage({super.key});

  @override
  _AtividadePageState createState() => _AtividadePageState();
}

class _AtividadePageState extends State<AtividadePage> {
  List<Map<String, dynamic>> atividades = [];
  List<Map<String, dynamic>> atividadesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAtividades();
  }

  Future<void> _carregarAtividades() async {
    setState(() => isLoading = true);
    try {
      final List<Atividade> resultado = await AtividadeService.getAtividades();

      final listaMapeada = resultado.map((f) => {
            'id': f.id,
            'nome': f.nome,
          }).toList();

      setState(() {
        atividades = listaMapeada;
        atividadesFiltradas = listaMapeada;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

 void _filtrarAtividades(String valor) {
  final query = valor.toLowerCase();
  final filtradas = atividades.where((atividade) {
    final nome = atividade['nome']?.toLowerCase() ?? '';
    return nome.contains(query);
  }).toList();

  setState(() => atividadesFiltradas = filtradas);
}


void _abrirFormulario({Map<String, dynamic>? atividade}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 600,
        height: 170,
        child: AtividadeForm(
          atividade: atividade != null ? Atividade.fromJson(atividade) : null,
        ),
      ),
    ),
  );

  if (resultado == true) _carregarAtividades();
}


/*
 void _abrirFormulario({Map<String, dynamic>? atividade}) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: AtividadeForm(
          atividade: atividade != null ? Atividade.fromJson(atividade) : null,
        ),
      ),
    );
    if (resultado == true) _carregarAtividades();
  }
*/


  void _confirmarExclusao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta atividade?'),
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
      await AtividadeService.deleteAtividade(id);
      _carregarAtividades();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return BaseLayout(
      titulo: 'Atividade',
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
                    onChanged: _filtrarAtividades,
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
                  label: const Text('Nova Atvidade'),
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
  }

Widget _buildTabelaWeb(TextStyle? textStyle, double largura) {
  if (atividadesFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma atividade encontrada.'));
  }

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Ações', style: TextStyle(fontSize: 12))),
          DataColumn(label: Text('Nome', style: TextStyle(fontSize: 12))),
        ],
        rows: atividadesFiltradas.asMap().entries.map((entry) {
          final index = entry.key;
          final atividade = entry.value;
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
                    onPressed: () => _abrirFormulario(atividade: atividade),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(atividade['id']),
                  ),
                ],
              )),
              DataCell(Text(atividade['nome'] ?? '',
                  style: const TextStyle(fontSize: 12))),
            ],
          );
        }).toList(),
      ),
    ),
  );
}



/*
Widget _buildTabelaWeb(TextStyle? textStyle, double largura) {
  if (atividadesFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma atividade encontrada.'));
  }

  return Expanded(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Ações', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('Nome', style: TextStyle(fontSize: 12))),
          ],
          rows: atividadesFiltradas.asMap().entries.map((entry) {
            final index = entry.key;
            final atividade = entry.value;
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
                      onPressed: () => _abrirFormulario(atividade: atividade),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarExclusao(atividade['id']),
                    ),
                  ],
                )),
                DataCell(Text(atividade['nome'] ?? '',
                    style: const TextStyle(fontSize: 12))),
              ],
            );
          }).toList(),
        ),
      ),
    ),
  );
}
*/


Widget _buildListaMobile(TextStyle? textStyle) {
  if (atividadesFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma atividade encontrada.'));
  }

  return ListView.builder(
    itemCount: atividadesFiltradas.length,
    itemBuilder: (_, index) {
      final atividade = atividadesFiltradas[index];
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
                    onPressed: () => _abrirFormulario(atividade: atividade),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(atividade['id']),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Dados (à direita)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(atividade['nome'] ?? '', style: const TextStyle(fontSize: 12)),
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