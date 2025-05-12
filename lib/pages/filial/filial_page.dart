import 'package:flutter/material.dart';
import 'package:sistrade/layout/base_layout.dart';
import 'package:sistrade/models/filial_model.dart';
import 'package:sistrade/services/filial_service.dart';
import 'package:sistrade/widgets/filial_form.dart';

class FilialPage extends StatefulWidget {
  const FilialPage({super.key});

  @override
  _FilialPageState createState() => _FilialPageState();
}

class _FilialPageState extends State<FilialPage> {
  List<Map<String, dynamic>> filiais = [];
  List<Map<String, dynamic>> filiaisFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFiliais();
  }

  Future<void> _carregarFiliais() async {
    setState(() => isLoading = true);
    try {
      final List<Filial> resultado = await FilialService.getFiliais();

      final listaMapeada = resultado.map((f) => {
            'idfilial': f.idfilial,
            'nome': f.nome,
            'email': f.email,
            'cnpjcpf': f.cnpjcpf,
            'celular1': f.celular1,
            'celular2': f.celular2,
            'telefone1': f.telefone1,
            'telefone2': f.telefone2,
          }).toList();

      setState(() {
        filiais = listaMapeada;
        filiaisFiltradas = listaMapeada;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

void _filtrarFiliais(String valor) {
  final query = valor.toLowerCase();
  final filtradas = filiais.where((filial) {
    final nome = filial['nome']?.toLowerCase() ?? '';
    final email = filial['email']?.toLowerCase() ?? '';
    final cnpj = filial['cnpjcpf']?.toLowerCase() ?? '';
    return nome.contains(query) || email.contains(query) || cnpj.contains(query);
  }).toList();

  setState(() => filiaisFiltradas = filtradas);
}


  void _abrirFormulario({Map<String, dynamic>? filial}) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: FilialForm(
          filial: filial != null ? Filial.fromJson(filial) : null,
        ),
      ),
    );
    if (resultado == true) _carregarFiliais();
  }



  void _confirmarExclusao(int idfilial) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta filial?'),
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
      await FilialService.deleteFilial(idfilial);
      _carregarFiliais();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return BaseLayout(
      titulo: 'Filial',
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
                      labelText: 'Buscar por nome, e-mail ou CNPJ',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filtrarFiliais,
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
                  label: const Text('Nova Filial'),
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
  if (filiaisFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma filial encontrada.'));
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: [
        DataColumn(label: const Text('Ações', style: TextStyle(fontSize: 12))),
        DataColumn(label: const Text('Nome', style: TextStyle(fontSize: 12))),
        if (largura > 800) DataColumn(label: const Text('Email', style: TextStyle(fontSize: 12))),
        if (largura > 900) DataColumn(label: const Text('CNPJ', style: TextStyle(fontSize: 12))),
        if (largura > 1000) DataColumn(label: const Text('Celular 1', style: TextStyle(fontSize: 12))),
        if (largura > 1100) DataColumn(label: const Text('Celular 2', style: TextStyle(fontSize: 12))),
        if (largura > 1200) DataColumn(label: const Text('Telefone 1', style: TextStyle(fontSize: 12))),
        if (largura > 1300) DataColumn(label: const Text('Telefone 2', style: TextStyle(fontSize: 12))),
      ],
      rows: filiaisFiltradas.asMap().entries.map((entry) {
        final index = entry.key;
        final filial = entry.value;
        final isEven = index % 2 == 0;

        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return isEven ? Colors.blueGrey[100] : Colors.white;
            },
          ),
          cells: [
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _abrirFormulario(filial: filial),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarExclusao(filial['idfilial']),
                ),
              ],
            )),
            DataCell(Text(filial['nome'] ?? '', style: const TextStyle(fontSize: 12))),
            if (largura > 800) DataCell(Text(filial['email'] ?? '', style: const TextStyle(fontSize: 12))),
            if (largura > 900) DataCell(Text(filial['cnpjcpf'] ?? '', style: const TextStyle(fontSize: 12))),
            if (largura > 1000) DataCell(Text(filial['celular1'] ?? '', style: const TextStyle(fontSize: 12))),
            if (largura > 1100) DataCell(Text(filial['celular2'] ?? '', style: const TextStyle(fontSize: 12))),
            if (largura > 1200) DataCell(Text(filial['telefone1'] ?? '', style: const TextStyle(fontSize: 12))),
            if (largura > 1300) DataCell(Text(filial['telefone2'] ?? '', style: const TextStyle(fontSize: 12))),
          ],
        );
      }).toList(),
    ),
  );
}


Widget _buildListaMobile(TextStyle? textStyle) {
  if (filiaisFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma filial encontrada.'));
  }

  return ListView.builder(
    itemCount: filiaisFiltradas.length,
    itemBuilder: (_, index) {
      final filial = filiaisFiltradas[index];
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
                    onPressed: () => _abrirFormulario(filial: filial),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarExclusao(filial['idfilial']),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Dados (à direita)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(filial['nome'] ?? '', style: const TextStyle(fontSize: 12)),
                    if ((filial['email'] ?? '').isNotEmpty)
                      Text('Email: ${filial['email']}', style: const TextStyle(fontSize: 12)),
                    if ((filial['cnpjcpf'] ?? '').isNotEmpty)
                      Text('CNPJ: ${filial['cnpjcpf']}', style: const TextStyle(fontSize: 12)),
                    if ((filial['celular1'] ?? '').isNotEmpty)
                      Text('Celular: ${filial['celular1']}', style: const TextStyle(fontSize: 12)),
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