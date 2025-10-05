import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4D67AE),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          width: 500,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  fnlogin(emailController.text.trim(), passwordController.text.trim());
                    
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D67AE),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                ),
                child: const Text('Iniciar Sesión', style:TextStyle(color: Colors.white) ),
              ),
              ElevatedButton(
                onPressed: () {
                  fnlogin("test@test.cl", "12345678");
                    
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D67AE),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                ),
                child: const Text('login', style:TextStyle(color: Colors.white) ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void fnlogin(String email, String password) async {
  final ctx = context; // 

  try {
     FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    if (!ctx.mounted) return; 
    ctx.go('/home'); 

  } on FirebaseAuthException catch (e) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Error al iniciar sesión')),
    );
  }
}


}