import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'ticket_list_gestor_screen.dart';
import 'ticket_list_unassigned_screen.dart';
import 'login_screen.dart';

class WelcomeGestorScreen extends StatelessWidget {
  const WelcomeGestorScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AuthService.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada')),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              });
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = AuthService.token ?? 'Gestor';
    final rol = AuthService.rol ?? 'GESTOR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Gestor'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Hola, $username!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              'Rol: $rol',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketListUnassignedScreen()),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Ver Tickets Sin Asignar'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketListGestorScreen()),
                );
              },
              icon: const Icon(Icons.assignment_ind),
              label: const Text('Ver Mis Tickets Asignados'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}