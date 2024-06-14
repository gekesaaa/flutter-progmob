import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class AddTabungan extends StatefulWidget {
  const AddTabungan({super.key});

  @override
  State<AddTabungan> createState() => _AddTabunganState();
}

class _AddTabunganState extends State<AddTabungan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _transactionNominalController =
      TextEditingController();

  List<Map<String, dynamic>> _transactionTypes = [];
  int? id;
  int? _selectedTransactionID;

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  bool _isInitialized = false;

  Future<void> fetchJenisTransaksi() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      if (responseData['success']) {
        setState(() {
          _transactionTypes = List<Map<String, dynamic>>.from(
              responseData['data']['jenistransaksi']);
        });
      }
    } catch (e) {
      print('Error fetching transaction types: $e');
    }
  }

  Future<void> addSaving() async {
    try {
      final _response = await _dio.post(
        '$_apiUrl/tabungan',
        data: {
          'anggota_id': id,
          'trx_id': _selectedTransactionID,
          'trx_nominal': int.parse(_transactionNominalController.text)
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_storage.read('token')}'
          },
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      setState(() {
        if (responseData['success']) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text(
                    "Transaksi Berhasil di Tambahkan",
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("OK",
                          style: TextStyle(color: Colors.green)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/tabungan', (route) => false);
                      },
                    ),
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    responseData['message'],
                  ),
                  content: const Text(
                    'Wait...',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("OK",
                          style: TextStyle(color: Colors.green)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/tabungan', (route) => false);
                      },
                    ),
                  ],
                );
              });
        }
      });
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Oops!"),
              content: Text(
                e.response?.data['message'] ?? 'An error occurred',
              ),
              actions: <Widget>[
                TextButton(
                  child:
                      const Text("OK", style: TextStyle(color: Colors.green)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        id = args;
      }
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchJenisTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text(
            'Tambah Tabungan',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[600],
          leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/tabungan', (route) => false);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 32,
            ),
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
                    DropdownButtonFormField<int>(
                      value: _selectedTransactionID,
                      onChanged: (value) {
                        setState(() {
                          _selectedTransactionID = value;
                        });
                      },
                      items: _transactionTypes.map((transaction) {
                        return DropdownMenuItem<int>(
                          value: transaction['id'],
                          child: Text(
                            transaction['trx_name'],
                          ),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Pilih Jenis Transaksi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null
                          ? 'Silakan pilih jenis transaksi'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _transactionNominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Transaksi',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan nominal transaksi';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Nominal harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState?.save();
                                addSaving();
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
                              'Tambah Tabungan',
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
              )
            ],
          ),
        ));
  }
}
