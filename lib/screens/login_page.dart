import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crud_rutas360/widgets/desktop_only_message.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Color mainColor = const Color(0xFF4D67AE);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool isMobilePlatform =
        defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
    final bool isSmallWidth = media.size.width < 720;

    if (isMobilePlatform || isSmallWidth) {
      return const DesktopOnlyMessage();
    }

    return Scaffold(
      backgroundColor: mainColor,
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
          margin: const EdgeInsets.symmetric(vertical: 80),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: mainColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Rutas 360°',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Iniciar sesión en el panel administrativo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // Campos de texto
              _buildTextField(
                controller: emailController,
                label: 'Correo electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                label: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Botón principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    fnlogin(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: mainColor.withValues(alpha: 0.3),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================= Helper de campos ===========================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: mainColor),
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: mainColor, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }

  // ======================= Lógica de login ===========================
  void fnlogin(String email, String password) async {
    final ctx = context;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!ctx.mounted) return;
      ctx.go('/home');
    } on FirebaseAuthException catch (e) {
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Error al iniciar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
