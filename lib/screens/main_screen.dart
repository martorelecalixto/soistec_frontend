import 'package:admin/pages/acomodacao_page.dart';
import 'package:admin/pages/atividade_page.dart';
import 'package:admin/pages/emissaofatura_page.dart';
import 'package:admin/pages/empresa_page.dart';
import 'package:admin/pages/entidade_page.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/pages/reemissaofatura_page.dart';
import 'package:admin/pages/tiposervico_page.dart';
import 'package:admin/pages/titulopagar_page.dart';
import 'package:admin/pages/tituloreceber_page.dart';
import 'package:admin/pages/vendabilhete_page.dart';
import 'package:admin/pages/vendaservico_page.dart';
import 'package:flutter/material.dart';
import 'package:admin/components/side_menu.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/pages/filial_page.dart';
import 'package:admin/pages/empresa_page.dart';
import 'package:admin/pages/atividade_page.dart';
import 'package:admin/pages/acomodacao_page.dart';
import 'package:admin/pages/tiposervico_page.dart';
import 'package:admin/pages/entidade_page.dart';
import 'package:admin/pages/vendabilhete_page.dart';
import 'package:admin/pages/vendaservico_page.dart';
import 'package:admin/pages/tituloreceber_page.dart';
import 'package:admin/pages/titulopagar_page.dart';
import 'package:admin/pages/emissaofatura_page.dart';
import 'package:admin/pages/reemissaofatura_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import './lib\pages\filial_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  String nome = 'Usuário';
  String email = '';

  // Lista de telas para o conteúdo
  final List<Widget> screens = [
    DashboardScreen(),
    EmpresaScreen(),
    FilialScreen(),
    AtividadeScreen(),
    AcomodacaoScreen(),
    TipoServicoScreen(),
    EntidadeScreen(),
    VendaBilheteScreen(),
    VendaHotelScreen(),
    TituloReceberScreen(),
    TituloPagarScreen(),
    EmissaoFaturaScreen(),
    ReemissaoFaturaScreen(),
    LoginScreen(),
    DashboardScreen(),
    // Adicione mais telas aqui conforme o menu
  ];

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(
        onMenuItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          Navigator.pop(context); // Fecha o menu depois de selecionar
        },
      ),
      appBar: AppBar(
        title: const Text('Sistrade'),

        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Olá, $nome',
                ////style: const TextStyle(fontSize: kFontSizeMenu),
              ),
            ),
          ),
         //// IconButton(
           ///// icon: const Icon(Icons.logout),
          /////  tooltip: 'Sair',
            /////onPressed: _logout,
          /////),
        ],

        backgroundColor: Colors.blueGrey,
      ),
      body: screens[selectedIndex],
    );
  }
}

