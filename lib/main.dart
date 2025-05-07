import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/login_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/home_page.dart';
import 'pages/atividade/atividade_page.dart';
import 'pages/filial/filial_page.dart';

void main() {
  runApp(const SistradeApp());
}

class SistradeApp extends StatelessWidget {
  const SistradeApp({super.key});

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fctoken');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final bool isLoggedIn = snapshot.data ?? false;

        return MaterialApp(
          title: 'Sistrade',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

            // AQUI DEFINE A FONTE E TAMANHOS GLOBAIS
            textTheme: GoogleFonts.robotoTextTheme(
              const TextTheme(
                displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                displayMedium: TextStyle(fontSize: 28.0),
                displaySmall: TextStyle(fontSize: 24.0),
                headlineMedium: TextStyle(fontSize: 20.0),
                headlineSmall: TextStyle(fontSize: 18.0),
                titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                bodyLarge: TextStyle(fontSize: 16.0),
                bodyMedium: TextStyle(fontSize: 14.0),
                labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
              ),
            ),

          ),
          home: isLoggedIn ? const HomePage() : const LoginPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/cadastro': (context) => const CadastroPage(),
            '/home': (context) => const HomePage(),
            '/atividade': (context) => const AtividadePage(),
            '/filial': (context) => const FilialPage(),
          },
        );
      },
    );
  }
}
