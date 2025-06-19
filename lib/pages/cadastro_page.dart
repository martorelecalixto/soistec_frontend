import 'package:flutter/material.dart';
import 'package:admin/services/auth_service.dart'; // Importando o AuthService

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _cadastrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final nome = _nomeController.text;
      final email = _emailController.text;
      final senha = _senhaController.text;

      final result = await AuthService.cadastrarUsuario(nome, email, senha);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Erro ao cadastrar usuário.')),
      );

      if (result['success'] == true) {
        // Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Usuário')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400, // Limita a largura em telas grandes
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(labelText: 'Nome'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'E-mail'),
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'Por favor, insira um e-mail válido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Senha'),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 8) {
                            return 'A senha deve ter no mínimo 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Confirmar Senha'),
                        validator: (value) {
                          if (value != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _cadastrarUsuario,
                              child: Text('Cadastrar'),
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