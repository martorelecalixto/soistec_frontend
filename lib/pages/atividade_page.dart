import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
//import 'package:sistrade/layout/base_layout.dart';
import '../../models/atividade_model.dart';
import '../../services/atividade_service.dart';
import '../../widgets/atividade/atividade_form.dart';

class AtividadeScreen extends StatefulWidget {
  const AtividadeScreen({super.key});

  @override
  _AtividadeScreenState createState() => _AtividadeScreenState();
}

class _AtividadeScreenState extends State<AtividadeScreen> {
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

  Widget _buildCabecalho(){
     return  Row(
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
            );

  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aividades'),
        backgroundColor:  bgColor,
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
                      ? _buildTabelaWeb(textStyle, largura)
                      : _buildListaMobile(textStyle),
            ),
          ],
        ),
      ),
    );


/*
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
    */
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
          headingRowColor: WidgetStateProperty.all(Colors.blueGrey[200]),
          columns: [
            DataColumn(label: Text('Ações', style: TextStyle(fontSize: 12, fontFamily: 'Popins', color: Colors.black, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Nome', style: TextStyle(fontSize: 12, fontFamily: 'Popins', color: Colors.black, fontWeight: FontWeight.bold))),
          ],
          rows: atividadesFiltradas.asMap().entries.map((entry) {
            final index = entry.key;
            final atividade = entry.value;
            final isEven = index % 2 == 0;

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) =>
                    isEven ?  const Color.fromARGB(255, 32, 114, 150) : const Color.fromARGB(255, 109, 153, 172),
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

  Widget _buildListaMobile(TextStyle? textStyle) {
    if (atividadesFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma atividade encontrada.'));
    }

    return ListView.builder(
      itemCount: atividadesFiltradas.length,
      itemBuilder: (_, index) {
        final atividade = atividadesFiltradas[index];
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
                      Text(atividade['nome'] ?? '', style: const TextStyle(fontSize: 12, fontFamily: 'Popins', color: Colors.black, fontWeight: FontWeight.bold)),
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