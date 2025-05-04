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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nome', resultado['user']['nome'] ?? 'Usuário');
      await prefs.setString('email', resultado['user']['email'] ?? '');
      await prefs.setString('fctoken', resultado['token'] ?? '');
      await prefs.setString('empresa', resultado['user']['empresa'] ?? '');

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 400 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Senha'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // TODO: Navegar para a tela de recuperação
                              Navigator.pushNamed(context, '/esqueciSenha');
                            },
                            child: const Text('Esqueci a senha'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (mensagemErro.isNotEmpty)
                        Text(
                          mensagemErro,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: carregando ? null : fazerLogin,
                        child: carregando
                            ? const CircularProgressIndicator()
                            : const Text('Entrar'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não tem uma conta?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/cadastro');
                            },
                            child: const Text('Criar conta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
