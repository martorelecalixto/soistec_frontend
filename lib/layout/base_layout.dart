
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double kFontSizeTitle = 20;
const double kFontSizeSubtitle = 14;
const double kFontSizeMenu = 12;
const double kFontSizeFooter = 12;
const double kMenuItemSpacing = 0.0; // Ajuste este valor conforme necessário

class BaseLayout extends StatefulWidget {
  final String titulo;
  final Widget conteudo;

  const BaseLayout({super.key, required this.titulo, required this.conteudo});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  String nome = 'Usuário';
  String email = '';
  bool isSidebarExpanded = true;
  bool isMobile = false;
  String selectedPage = '';

  final Map<String, IconData> menuItems = {
    'Home': Icons.home,
    'Empresa': Icons.business,
    'Filial': Icons.account_tree,
    'Atividade': Icons.work,
    'Entidade': Icons.account_balance,
    'VendaBilhete': Icons.confirmation_number,
    'Venda Serviço': Icons.miscellaneous_services,
    'Emissão Fatura': Icons.receipt_long,
    'Reemissão Fatura': Icons.receipt,
    'Lançamento': Icons.playlist_add_check,
    'Relatórios': Icons.assessment,
    'Sair': Icons.logout,
  };

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('nome') ?? 'Usuário';
      email = prefs.getString('email') ?? '';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navegarPara(String label) {
    if (label == 'Sair') {
      _logout();
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/${label.toLowerCase().replaceAll(' ', '_')}',
      );
     // print(label.toLowerCase().replaceAll(' ', '_'));
    }
  }


Widget _buildDrawerItem(String label, IconData icon) {
  final bool selected = widget.titulo == label;
  return ListTile(
    dense: true, // Reduz a altura vertical
    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
    leading: Icon(icon, color: selected ? Colors.blue : null),
    title: isSidebarExpanded
        ? Text(
            label,
            style: const TextStyle(fontSize: kFontSizeMenu),
          )
        : null,
    tileColor: selected ? Colors.blue.shade100 : null,
    onTap: () => _navegarPara(label),
    hoverColor: Colors.blue.shade50,
  );
}


Widget _buildDrawer() {
  return Drawer(
    width: isSidebarExpanded ? 220 : 70,
    child: Container(
      color: Colors.blueGrey.shade50,
      child: ListView(
       // padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: isSidebarExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //const FlutterLogo(size: 40),
                      Image.asset('assets/logo.png', height: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Bem-vindo, $nome',
                        style: const TextStyle(fontSize: kFontSizeMenu),
                      ),
                      Text(
                        email,
                        style: const TextStyle(fontSize: kFontSizeSubtitle),
                      ),
                    ],
                  )
                : Center(child: Image.asset('../assets/logo.png', height: 40)),
          ),
          // Inserção de espaçamento entre os itens do menu
          ...menuItems.entries
              .map((item) => _buildDrawerItem(item.key, item.value))
              .expand((widget) => [
                    widget,
                    SizedBox(height: kMenuItemSpacing),
                  ]),
          isSidebarExpanded
              ? ListTile(
                  leading: const Icon(Icons.arrow_back),
                  title: const Text(
                    'Reduzir menu',
                    style: TextStyle(fontSize: kFontSizeMenu),
                  ),
                  onTap: () => setState(() => isSidebarExpanded = false),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Expandir menu',
                  onPressed: () => setState(() => isSidebarExpanded = true),
                ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titulo,
          style: const TextStyle(fontSize: kFontSizeTitle),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Olá, $nome',
                style: const TextStyle(fontSize: kFontSizeMenu),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!isMobile) _buildDrawer(),
          Expanded(
            child: Column(
              children: [
                Expanded(child: widget.conteudo),
                Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text(
                    '© 2025 Sistrade',
                    style: TextStyle(fontSize: kFontSizeFooter),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
