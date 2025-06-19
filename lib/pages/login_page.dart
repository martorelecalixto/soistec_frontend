import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:admin/components/side_menu.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/screens/main_screen.dart';
import '../../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends  State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool _senhaVisivel = false;

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
        //Navigator.pushReplacementNamed(context, onMenuItemSelected(14));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );        
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
      backgroundColor: secondaryColor,//const Color(0xFFF2F4F7), // fundo suave
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
                      // Logomarca (substituir pelo seu logo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/images/logo.png'), // caminho da logomarca
                        ),
                      ),                      
                      // Card com elevação
                      Card(
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                  labelStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,//blueGrey
                                    fontFamily: 'Poppins', // Sua fonte personalizada
                                  ),                                  
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: senhaController,
                                obscureText: !_senhaVisivel,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  labelStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,//blueGrey
                                    fontFamily: 'Poppins', // Sua fonte personalizada
                                  ),                                  
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _senhaVisivel = !_senhaVisivel;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              /*Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/esqueciSenha');
                                  },
                                  child: const Text('Esqueci a senha'),
                                ),
                              ),*/
                              if (mensagemErro.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  mensagemErro,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.blue,//Theme.of(context).primaryColorLight,
                                    elevation: 4,
                                  ),
                                  onPressed: carregando ? null : fazerLogin,
                                  child: carregando
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                          'Entrar',
                                          style: TextStyle(fontSize: 16, fontFamily: 'Poppins',color: Colors.white),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      /*Row(
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
                      ),*/
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
