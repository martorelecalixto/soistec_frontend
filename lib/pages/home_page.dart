import 'package:flutter/material.dart';
import 'package:sistrade/layout/base_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //List<Map<String, dynamic>> atividades = [];
  //List<Map<String, dynamic>> atividadesFiltradas = [];
  //final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
   // _carregarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    final double largura = MediaQuery.of(context).size.width;
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return BaseLayout(
      titulo: 'Home',
      conteudo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          ],
        ),
      ),
    );
  }



}











/*
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'pages/home_page.dart';
import 'package:sistrade/pages/filial/filial_page.dart';
import 'package:sistrade/pages/atividade/atividade_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nome = 'Usuário';
  String email = '';
  String token = '';
  bool isSidebarExpanded = true;
  bool isMobile = false;
  String selectedPage = 'Home';

  final Map<String, IconData> menuItems = {
    'Home': Icons.home,
    'Empresa': Icons.business,
    'Filial': Icons.account_tree,
    'Atividade': Icons.work,
    'Entidade': Icons.account_balance,
    'Venda Bilhete': Icons.confirmation_number,
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
      token = prefs.getString('fctoken') ?? '';
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      width: isSidebarExpanded ? 220 : 70,
      child: Container(
        color: Colors.blueGrey.shade50,
        child: ListView(
          padding: const EdgeInsets.only(top: 0),
          children: [
            DrawerHeader(
              child: isSidebarExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FlutterLogo(size: 40),
                        const SizedBox(height: 8),
                        Text('Bem-vindo, $nome'),
                        Text(email, style: const TextStyle(fontSize: 12)),
                      ],
                    )
                  : const Center(child: FlutterLogo(size: 40)),
            ),
            ...menuItems.entries.map((item) {
              return _buildDrawerItem(item.key, item.value);
            }),
            if (isSidebarExpanded)
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('Reduzir menu'),
                onTap: () {
                  setState(() => isSidebarExpanded = false);
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'Expandir menu',
                onPressed: () {
                  setState(() => isSidebarExpanded = true);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String label, IconData icon) {
    final bool selected = selectedPage == label;
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : null),
      title: isSidebarExpanded ? Text(label) : null,
      tileColor: selected ? Colors.blue.shade100 : null,
      onTap: () {
        if (label == 'Sair') {
          _logout();
        } else if (label == 'Home') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (label == 'Filial') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FilialPage()),
        );
      } else if (label == 'Atividade') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AtividadePage()),
        );
      } 
      else {
          setState(() => selectedPage = label);
        }
      },
      hoverColor: Colors.blue.shade50,
    );
  }

  Widget _buildContent() {
    return Center(
      child: Text(
        'Página atual: $selectedPage',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: Text('Olá, $nome')),
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
                Expanded(child: _buildContent()),
                Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: const Text('© 2025 Sistrade'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}

*/