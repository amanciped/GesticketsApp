import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'welcome_screen_user.dart';
import 'register_screen.dart';
import 'welcome_screen_gestor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await AuthService.login(
      _userController.text,
      _passController.text,
    );

    setState(() => _isLoading = false);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticación exitosa')),
      );
      await Future.delayed(const Duration(seconds: 1));

      // 🔀 Navegar según rol
      if (AuthService.rol == 'GESTOR') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeGestorScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) =>
                value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _passController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: const Text('Ingresar'),
              ),
              const SizedBox(height: 40),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}