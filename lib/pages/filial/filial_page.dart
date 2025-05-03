import 'package:flutter/material.dart';
import 'package:sistrade/layout/base_layout.dart';
import 'package:sistrade/models/filial_model.dart';
import 'package:sistrade/services/filial_service.dart';
import 'package:sistrade/widgets/filial_form.dart';

class FilialPage extends StatefulWidget {
  const FilialPage({Key? key}) : super(key: key);

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
  }

  void _filtrarFiliais(String nome) {
    final filtradas = filiais.where((filial) {
      final nomeFilial = filial['nome']?.toLowerCase() ?? '';
      return nomeFilial.contains(nome.toLowerCase());
    }).toList();
    setState(() => filiaisFiltradas = filtradas);
  }

  void _abrirFormulario({Map<String, dynamic>? filial}) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
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
    final isWeb = MediaQuery.of(context).size.width > 600;

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
                      labelText: 'Buscar por nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filtrarFiliais,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _abrirFormulario(),
                  child: const Text('Nova Filial'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : isWeb
                      ? _buildTabelaWeb()
                      : _buildListaMobile(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabelaWeb() {
  if (filiaisFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma filial encontrada.'));
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: const [
        DataColumn(label: Text('Nome')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('CNPJ')),
        DataColumn(label: Text('Celular 1')),
        DataColumn(label: Text('Celular 2')),
        DataColumn(label: Text('Telefone 1')),
        DataColumn(label: Text('Telefone 2')),
        DataColumn(label: Text('Ações')),
      ],
      rows: filiaisFiltradas.map((filial) {
        return DataRow(cells: [
          DataCell(Text(filial['nome'] ?? '')),
          DataCell(Text(filial['email'] ?? '')),
          DataCell(Text(filial['cnpjcpf'] ?? '')),
          DataCell(Text(filial['celular1'] ?? '')),
          DataCell(Text(filial['celular2'] ?? '')),
          DataCell(Text(filial['telefone1'] ?? '')),
          DataCell(Text(filial['telefone2'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _abrirFormulario(filial: filial),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmarExclusao(filial['idfilial']),
              ),
            ],
          )),
        ]);
      }).toList(),
    ),
  );
}

Widget _buildListaMobile() {
  if (filiaisFiltradas.isEmpty) {
    return const Center(child: Text('Nenhuma filial encontrada.'));
  }

  return ListView.builder(
    itemCount: filiaisFiltradas.length,
    itemBuilder: (_, index) {
      final filial = filiaisFiltradas[index];
      return Card(
        child: ListTile(
          title: Text(filial['nome'] ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _abrirFormulario(filial: filial),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmarExclusao(filial['idfilial']),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
