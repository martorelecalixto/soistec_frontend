import 'package:admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/filial_model.dart';
import 'package:admin/services/filial_service.dart';
import 'package:admin/widgets/filial/filial_form.dart';

class FilialScreen extends StatefulWidget {
  const FilialScreen({super.key});

  @override
  State<FilialScreen> createState() => _FilialScreenState();
}

class _FilialScreenState extends State<FilialScreen> {
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
            'id': f.idfilial,
            'nome': f.nome,
            'email': f.email,
            'cnpjcpf': f.cnpjcpf,
            'telefone1':f.telefone1,
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
      return nome.contains(query);
    }).toList();

    setState(() => filiaisFiltradas = filtradas);
  }

  void _abrirFormulario({Map<String, dynamic>? filial}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 800,
          height: 800,
          child: FilialForm(
            filial: filial != null ? Filial.fromJson(filial) : null,
          ),
        ),
      ),
    );

    if (resultado == true) _carregarFiliais();
  }

  void _confirmarExclusao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta filial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
///      await FilialService.deleteFilial(id);
      _carregarFiliais();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filiais'),
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

  }

  Widget _buildCabecalho() {
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
  }

  Widget _buildTabelaWeb(TextStyle? textStyle, double largura) {
    if (filiaisFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma filial encontrada.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Ações', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('Nome', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('E-mail', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('CNPJ', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('Telefone(1)', style: TextStyle(fontSize: 12))),
          ],
          rows: filiaisFiltradas.asMap().entries.map((entry) {
            final index = entry.key;
            final filial = entry.value;
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
                      onPressed: () => _abrirFormulario(filial: filial),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarExclusao(filial['id']),
                    ),
                  ],
                )),
                DataCell(Text(filial['nome'] ?? '',  style: const TextStyle(fontSize: 12))),
                DataCell(Text(filial['email'] ?? '',  style: const TextStyle(fontSize: 12))),
                DataCell(Text(filial['cnpjcpf'] ?? '',  style: const TextStyle(fontSize: 12))),
                DataCell(Text(filial['telefone1'] ?? '',  style: const TextStyle(fontSize: 12))),
              ],
            );
          }).toList(),
        ),
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
        final backgroundColor = isEven ?  const Color.fromARGB(255, 32, 114, 150) : const Color.fromARGB(255, 109, 153, 172);

        return Card(
          color: backgroundColor,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _abrirFormulario(filial: filial),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarExclusao(filial['id']),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(filial['nome'] ?? '',
                          style: const TextStyle(fontSize: 12)),
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













/*
import 'package:flutter/material.dart';
import 'package:admin/models/filial_model.dart';
import 'package:admin/services/filial_service.dart';

class FilialScreen extends StatefulWidget {
  const FilialScreen({super.key});

  @override
  State<FilialScreen> createState() => _FilialScreenState();
}

class _FilialScreenState extends State<FilialScreen> {
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
            'id': f.idfilial,
            'nome': f.nome,
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
      return nome.contains(query);
    }).toList();

    setState(() => filiaisFiltradas = filtradas);
  }

  void _abrirFormulario({Map<String, dynamic>? filial}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(filial == null ? 'Nova Filial' : 'Editar Filial'),
        content: const SizedBox(
          width: 500,
          height: 200,
          child: Center(child: Text('Formulário aqui')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (resultado == true) _carregarFiliais();
  }

  void _confirmarExclusao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Filial'),
        content: const Text('Deseja realmente excluir esta filial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // await FilialService.deleteFilial(id);
      _carregarFiliais();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filiais'),
        backgroundColor: Colors.indigo,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCabecalho(),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : largura > 700
                      ? _buildTabelaWeb()
                      : _buildListaMobile(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _filtrarFiliais,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _abrirFormulario(),
          icon: const Icon(Icons.add),
          label: const Text('Nova Filial'),
        ),
      ],
    );
  }

  Widget _buildTabelaWeb() {
    if (filiaisFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma filial encontrada.'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade300),
        columns: const [
          DataColumn(label: Text('Ações')),
          DataColumn(label: Text('Nome')),
        ],
        rows: filiaisFiltradas.asMap().entries.map((entry) {
          final index = entry.key;
          final filial = entry.value;
          final isEven = index % 2 == 0;

          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) =>
                  isEven ? Colors.grey.shade100 : Colors.white,
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
                    onPressed: () => _confirmarExclusao(filial['id']),
                  ),
                ],
              )),
              DataCell(Text(filial['nome'] ?? '')),
            ],
          );
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
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(filial['nome'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _abrirFormulario(filial: filial),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarExclusao(filial['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

*/








