import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _entrar(BuildContext context) async {
    try {
      await AuthService().entrarComGoogle();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível entrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_fix_high, size: 72, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                'ESCOLA JUJUTSU',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acesso restrito para feiticeiros',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _entrar(context),
                icon: const Icon(Icons.login),
                label: const Text('ENTRAR COM GOOGLE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
