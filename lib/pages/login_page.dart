import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ajuste o caminho se necessário
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  String mensagemErro = '';
  bool carregando = false;

  void fazerLogin() async {
    setState(() {
      carregando = true;
      mensagemErro = '';
    });

    final resultado = await AuthService.login(
      emailController.text,
      senhaController.text,
    );

    setState(() {
      carregando = false;
    });

    if (resultado['success']) {
      // Salva as informações do usuário no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nome', resultado['user']['nome'] ?? 'Usuário');
      await prefs.setString('email', resultado['user']['email'] ?? '');
      await prefs.setString('fctoken', resultado['token'] ?? '');

      // Redireciona para a Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() {
        mensagemErro = resultado['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            if (mensagemErro.isNotEmpty)
              Text(mensagemErro, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: carregando ? null : fazerLogin,
              child: carregando
                  ? const CircularProgressIndicator()
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
