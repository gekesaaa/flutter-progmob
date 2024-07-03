import 'package:coba_login/main.dart';
import 'package:flutter/material.dart';
import 'tambahAnggota.dart';

// email : sebong17@gmail.com
// pass : sebong17

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TABUNGAN SEJAHTERA',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[600],
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profil');
            },
            child: CircleAvatar(
              radius: 20.0,
              child: Image.asset('assets/images/profile.png'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Detail Anggota
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Anggota'),
                        const SizedBox(height: 16.0),
                        const Text(
                            'Berisi list dari anggota yang ikut dalam Tabungan Sejahtera'),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/listMember');
                          },
                          child: const Text('Cek Anggota'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Kartu List Seluruh Tabungan Anggota
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tabungan Anggota'),
                        const SizedBox(height: 16.0),
                        const Text(
                            'Berisi menganai detail Tabungan dari Anggota'),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/tabungan');
                          },
                          child: const Text('Cek Tabungan'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Kartu Untuk mengatur Bunga
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bunga'),
                        const SizedBox(height: 16.0),
                        const Text(
                            'Tempat mengatur Bunga yang digunakan untuk transaksi'),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/bunga');
                          },
                          child: const Text('Atur Bunga'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddMemberPage()));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 60.0, // Adjust the height as needed
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.green,
          selectedItemColor: Colors.green,
          selectedLabelStyle: const TextStyle(color: Colors.green),
          unselectedLabelStyle: const TextStyle(color: Colors.green),
          onTap: (value) {
            if (value == 0) {
              // Home
              print('Home');
            } else if (value == 1) {
              // Logout
              _showLogoutDialog(context); // Show the logout dialog
            }
          },
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home_outlined),
            ),
            BottomNavigationBarItem(
              label: 'Logout',
              icon: Icon(Icons.logout_outlined),
            )
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingin Keluar?'),
          content: const Text('Kamu yakin ingin Keluar?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Iya', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                MainApp().goLogout(context);

                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        );
      },
    );
  }
}
