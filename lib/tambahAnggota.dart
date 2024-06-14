// ignore_for_file: avoid_print, file_names, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomorIndukController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();

  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();
  final String _apiUrl = 'https://mobileapis.manpits.xyz/api/anggota';
  DateTime? _tglLahir;

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _nomorIndukController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _tglLahirController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tglLahir = picked;
        _tglLahirController.text =
            "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _addMember() async {
    try {
      final formData = FormData.fromMap({
        'nomor_induk': _nomorIndukController.text,
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'tgl_lahir': _tglLahirController.text,
        'telepon': _noTeleponController.text,
      });

      final response = await _dio.post(
        _apiUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Anggota berhasil ditambahkan!"),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    _nomorIndukController.clear();
                    _namaController.clear();
                    _alamatController.clear();
                    _tglLahirController.clear();
                    _noTeleponController.clear();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/listMember');
                  },
                ),
              ],
            );
          },
        );
      } else {
        _showErrorDialog(response.data['message'] ?? 'An error occurred');
      }
    } on DioError catch (e) {
      print('Error: ${e.response?.data} - ${e.response?.statusCode}');
      _showErrorDialog(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Oops!"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Tambah Anggota',
          // style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          //       color: Colors.green,
          //     ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _nomorIndukController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nomor induk.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Induk',
                      hintText: 'Masukkan nomor induk',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nama.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      hintText: 'Masukkan nama',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alamatController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan alamat.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      hintText: 'Masukkan alamat',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tglLahirController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Masukkan tanggal lahir',
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (_tglLahir == null) {
                        return 'Masukkan tanggal lahir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noTeleponController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nomor telepon.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: 'Masukkan nomor telepon',
                    ),
                  ),
                  const SizedBox(height: 70),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _addMember();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text(
                            'Tambah Anggota',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
