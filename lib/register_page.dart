import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Dio _dio = Dio();
  final String _apiUrl = 'https://mobileapis.manpits.xyz/api';

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register(BuildContext context) async {
    String name = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data Tidak Boleh Kosong'),
        ),
      );
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email harus menggunakan akhiran @gmail.com'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak sama'),
        ),
      );
      return;
    }

    try {
      final response = await _dio.post(
        '$_apiUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        print('Response:${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful. Please login.'),
          ),
        );

        Navigator.pushReplacementNamed(context, '/');
      } else {
        print('Registration failed: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Silahkan Coba Lagi'),
          ),
        );
      }
    } on DioError catch (e) {
      print('Dio error: ${e.response?.statusCode} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Silahkan Coba Lagi'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/images/logo_harvesthub.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _register(context),
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
                  'Register',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: const Text(
                          "Sign In",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}






// // KODE REGISTER BERHASIL DAN SUDAH BERISI VALIDASI EMAIL TAPI BELUM ISI KONFIRMASI PASSWORD
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';

// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final Dio _dio = Dio();
//   final String _apiUrl = 'https://mobileapis.manpits.xyz/api';

//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _isPasswordVisible = false;

//   Future<void> _register(BuildContext context) async {
//     String name = _fullNameController.text.trim();
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     if (name.isEmpty || email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Data Tidak Boleh Kosong'),
//         ),
//       );
//       return;
//     }

//     if (!email.endsWith('@gmail.com')) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Email harus menggunakan akhiran @gmail.com'),
//         ),
//       );
//       return;
//     }

//     try {
//       final response = await _dio.post(
//         '$_apiUrl/register',
//         data: {
//           'name': name,
//           'email': email,
//           'password': password,
//         },
//       );

//       if (response.statusCode == 200) {
//         print('Response:${response.data}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Registration successful. Please login.'),
//           ),
//         );

//         Navigator.pushReplacementNamed(context, '/');
//       } else {
//         print('Registration failed: ${response.statusCode}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Registration failed. Silahkan Coba Lagi'),
//           ),
//         );
//       }
//     } on DioError catch (e) {
//       print('Dio error: ${e.response?.statusCode} - ${e.message}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Registration failed. Silahkan Coba Lagi'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register'),
//         centerTitle: true,
//         backgroundColor: Colors.green[600],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               Image.asset(
//                 'assets/images/logo_harvesthub.png',
//                 height: 200,
//                 width: 200,
//               ),
//               const SizedBox(height: 20.0),
//               TextField(
//                 controller: _fullNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   prefixIcon: const Icon(Icons.person),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.8),
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   prefixIcon: const Icon(Icons.email),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.8),
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   prefixIcon: const Icon(Icons.lock),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.8),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//                 obscureText: !_isPasswordVisible,
//               ),
//               const SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: () => _register(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green[100],
//                   padding: const EdgeInsets.symmetric(vertical: 15.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   elevation: 5.0,
//                   shadowColor: Colors.black.withOpacity(0.5),
//                 ),
//                 child: const Text(
//                   'Register',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//               Column(
//                 children: [
//                   const SizedBox(height: 20.0),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         "Already have an account?",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacementNamed(context, '/');
//                         },
//                         child: const Text(
//                           "Sign In",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 16, color: Colors.purple),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
