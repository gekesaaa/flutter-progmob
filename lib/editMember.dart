import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class EditMember extends StatefulWidget {
  const EditMember({super.key});

  @override
  State<EditMember> createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nomorIndukController = TextEditingController();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _tglLahirController = TextEditingController();
  TextEditingController _noTeleponController = TextEditingController();

  Anggota? anggota;
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  int id = 0;
  DateTime? _tglLahir;
  bool _isDetailLoaded = false;
  String? _selectedStatusAktif;
  List<String> _statusAktifOptions = ['Aktif', 'Tidak Aktif'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && !_isDetailLoaded) {
      id = args as int;
      getDetail();
      _isDetailLoaded = true;
    }
  }

  Future<void> getDetail() async {
    try {
      final _response = await _dio.get(
        '${_apiUrl}/anggota/${id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      setState(() {
        anggota = Anggota.fromJson(responseData);
        _nomorIndukController.text = anggota?.nomor_induk.toString() ?? '';
        _namaController.text = anggota?.nama.toString() ?? '';
        _alamatController.text = anggota?.alamat.toString() ?? '';
        _tglLahirController.text = anggota?.tgl_lahir.toString() ?? '';
        _noTeleponController.text = anggota?.telepon.toString() ?? '';
        _tglLahir = DateFormat("yyyy-MM-dd").parse(_tglLahirController.text);
        _selectedStatusAktif =
            anggota?.status_aktif == 1 ? 'Aktif' : 'Tidak Aktif';
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  void goEditUser() async {
    try {
      final _response = await _dio.put(
        '${_apiUrl}/anggota/${id}',
        data: {
          'nomor_induk': _nomorIndukController.text,
          'nama': _namaController.text,
          'alamat': _alamatController.text,
          'tgl_lahir': _tglLahirController.text,
          'telepon': _noTeleponController.text,
          'status_aktif': _selectedStatusAktif == 'Aktif' ? 1 : 0,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}',
          },
        ),
      );
      print(_response.data);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Colors.white,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green[600],
                ),
              ),
            ),
            child: AlertDialog(
              title: const Text("Anggota berhasil diedit",
                  style: TextStyle(color: Colors.black)),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/listMember',
                      arguments: anggota?.id,
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Oops!"),
              content: Text(e.response?.data['message'] ?? 'An error occurred'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: anggota?.id,
                    );
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> _confirmEditMember() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah data yang di edit sudah sesuai?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Ya", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.pop(context);
                goEditUser();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[600]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (_picked != null) {
      setState(() {
        _tglLahir = _picked;
        _tglLahirController.text =
            "${_picked.year}-${_picked.month}-${_picked.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Edit Anggota',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[600],
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/listMember');
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          const SizedBox(height: 10),
          Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nomorIndukController,
                      validator: (_nomorIndukController) {
                        if (_nomorIndukController == null ||
                            _nomorIndukController.isEmpty) {
                          return 'Masukkan nomor induk.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Induk',
                        hintText: 'Masukkan nomor induk',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      validator: (_namaController) {
                        if (_namaController == null ||
                            _namaController.isEmpty) {
                          return 'Masukkan nama.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        hintText: 'Masukkan nama',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatController,
                      validator: (_alamatController) {
                        if (_alamatController == null ||
                            _alamatController.isEmpty) {
                          return 'Mmasukkan alamat.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        hintText: 'Masukkan alamat',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tglLahirController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        hintText: 'Masukkan tanggal lahir',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate();
                      },
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
                      validator: (_noTeleponController) {
                        if (_noTeleponController == null ||
                            _noTeleponController.isEmpty) {
                          return 'Masukkan nomor telepon.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: 'Masukkan nomor telepon',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatusAktif,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatusAktif = newValue;
                        });
                      },
                      items: _statusAktifOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Status Aktif',
                        hintText: 'Pilih status aktif',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih status aktif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();
                                _confirmEditMember();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20)),
                            child: const Text(
                              'Edit Anggota',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]))
        ]),
      ),
    );
  }
}

class Anggota {
  final int id;
  final int nomor_induk;
  final String nama;
  final String alamat;
  final String tgl_lahir;
  final String telepon;
  final String? image_url;
  final int? status_aktif;

  Anggota({
    required this.id,
    required this.nomor_induk,
    required this.nama,
    required this.alamat,
    required this.tgl_lahir,
    required this.telepon,
    required this.image_url,
    required this.status_aktif,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    if (data != null) {
      final anggotaData = data['anggota'] as Map<String, dynamic>?;

      if (anggotaData != null) {
        return Anggota(
          id: anggotaData['id'],
          nomor_induk: anggotaData['nomor_induk'],
          nama: anggotaData['nama'],
          alamat: anggotaData['alamat'],
          tgl_lahir: anggotaData['tgl_lahir'],
          telepon: anggotaData['telepon'],
          image_url: anggotaData['image_url'],
          status_aktif: anggotaData['status_aktif'],
        );
      }
    }

    throw Exception('Failed to parse Anggota from JSON');
  }
}
