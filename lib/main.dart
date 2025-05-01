import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/home_page.dart';

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
          ),
          home: isLoggedIn ? const HomePage() : const LoginPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/cadastro': (context) => const CadastroPage(),
            '/home': (context) => const HomePage(),
          },
        );
      },
    );
  }
}
