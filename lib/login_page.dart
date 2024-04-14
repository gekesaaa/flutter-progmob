import 'package:coba_login/register_page.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // Import DashboardPage

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: Column(
        children: <Widget>[
          Image.asset(
            'assets/images/logo_harvesthub.png',
            height: 200,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke DashboardPage setelah login berhasil
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5.0,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Column(
                  children: [
                    // Widget lainnya
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an Account?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterPage()));
                          },
                          child: const Text(
                            "Sign Up",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 16, color: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
