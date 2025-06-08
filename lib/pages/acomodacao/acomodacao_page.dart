import 'package:flutter/material.dart';
import 'package:sistrade/layout/base_layout.dart';
import 'package:sistrade/models/acomodacao_model.dart';
import 'package:sistrade/services/acomodacao_service.dart';
import 'package:sistrade/widgets/acomodacao_form.dart';

class AcomodacaoPage extends StatefulWidget {
  const AcomodacaoPage({super.key});

  @override
  _AcomodacaoPageState createState() => _AcomodacaoPageState();
}

class _AcomodacaoPageState extends State<AcomodacaoPage> {
  List<Map<String, dynamic>> acomodacoes = [];
  List<Map<String, dynamic>> acomodacoesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAcomodacoes();
  }

  Future<void> _carregarAcomodacoes() async {
    setState(() => isLoading = true);
    try {
      final List<Acomodacao> resultado = await AcomodacaoService.getAcomodacoes();

      final listaMapeada = resultado.map((f) => {
            'id': f.id,
            'nome': f.nome,
          }).toList();

      setState(() {
        acomodacoes = listaMapeada;
        acomodacoesFiltradas = listaMapeada;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

 void _filtrarAcomodacao(String valor) {
  final query = valor.toLowerCase();
  final filtradas = acomodacoes.where((acomodacao) {
    final nome = acomodacao['nome']?.toLowerCase() ?? '';
    return nome.contains(query);
  }).toList();

  setState(() => acomodacoesFiltradas = filtradas);
}


 void _abrirFormulario({Map<String, dynamic>? acomodacao}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 600,
        height: 170,
        child: AcomodacaoForm(
          acomodacao: acomodacao != null ? Acomodacao.fromJson(acomodacao) : null,
        ),
      ),
    ),
  );

  if (resultado == true) _carregarAcomodacoes();
}


  void _confirmarExclusao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta acomodação?'),
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
      await AcomodacaoService.deleteAcomodacao(id);
      _carregarAcomodacoes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return BaseLayout(
      titulo: 'Acomodacao',
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
                    onChanged: _filtrarAcomodacao,
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
                  label: const Text('Nova Acomodacao'),
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
  if (acomodacoesFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma acomodacao encontrada.'));
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
        rows: acomodacoesFiltradas.asMap().entries.map((entry) {
          final index = entry.key;
          final acomodacao = entry.value;
          final isEven = index % 2 == 0;

          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) =>
                  isEven ? Colors.blueGrey[100] : Colors.white,
            ),
            cells: [
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _abrirFormulario(acomodacao: acomodacao),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(acomodacao['id']),
                  ),
                ],
              )),
              DataCell(Text(acomodacao['nome'] ?? '',
                  style: const TextStyle(fontSize: 12))),
            ],
          );
        }).toList(),
      ),
    ),
  );
}


Widget _buildListaMobile(TextStyle? textStyle) {
  if (acomodacoesFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma acomodacao encontrada.'));
  }

  return ListView.builder(
    itemCount: acomodacoesFiltradas.length,
    itemBuilder: (_, index) {
      final acomodacao = acomodacoesFiltradas[index];
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
                    onPressed: () => _abrirFormulario(acomodacao: acomodacao),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(acomodacao['id']),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Dados (à direita)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(acomodacao['nome'] ?? '', style: const TextStyle(fontSize: 12)),
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