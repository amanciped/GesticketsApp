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
      builder: (ctx) =>
          AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              '¿Estás segur@ de que deseas cerrar sesión?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                    'Cancelar', style: TextStyle(color: Colors.orange)),
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
                child: const Text(
                    'Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
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
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 4,
        title: const Text(
            'Panel del Gestor', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/what-is-it-incident-management.png',
                height: 180,
              ),
              const SizedBox(height: 20),
              Text(
                '¡Saludos! \n $username',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Rol: $rol',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildStyledButton(
                context,
                icon: Icons.search,
                label: 'Ver Tickets Sin Asignar',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TicketListUnassignedScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildStyledButton(
                context,
                icon: Icons.assignment_ind,
                label: 'Ver Mis Tickets Asignados',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TicketListGestorScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton(BuildContext context,
      {required String label, required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: naranja,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}