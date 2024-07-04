import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class TabunganDetail extends StatefulWidget {
  const TabunganDetail({super.key});

  @override
  State<TabunganDetail> createState() => _TabunganDetailState();
}

class _TabunganDetailState extends State<TabunganDetail> {
  late final int id;
  late final String nama;
  late final int saldo;

  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  List<Map<String, dynamic>> _transactions = [];
  Map<int, String> _transactionTypes = {};
  bool _isInitialized = false;

  Future<void> getDetails() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/tabungan/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      if (responseData['success']) {
        setState(() {
          _transactions =
              List<Map<String, dynamic>>.from(responseData['data']['tabungan']);
        });
      }
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Oops!"),
              content: Text(e.response?.data['message'] ?? 'An error occurred'),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> getJenisTransaksi() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      if (responseData['success']) {
        setState(() {
          _transactionTypes = {
            for (var item in responseData['data']['jenistransaksi'])
              item['id']: item['trx_name']
          };
        });
      }
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && ModalRoute.of(context)?.settings.arguments != null) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      id = arguments['id'] as int;
      nama = arguments['nama'];
      saldo = arguments['saldo'];
      getDetails();
      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    getJenisTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text(
              'Detail Tabungan',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
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
        actions: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(26, 94, 86, 149),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                nama,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Tabungan: ' +
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.')
                        .format(saldo),
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _transactions.isEmpty
                    ? const Center(
                        child: Text('Tidak Ada Tabungan :) \nAyo Nabung!!',
                            textAlign: TextAlign.center),
                      )
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          final transactionType =
                              _transactionTypes[transaction['trx_id']] ??
                                  'Unknown';
                          return ListTile(
                            title: Text(NumberFormat.currency(
                                    locale: 'id_ID', symbol: 'Rp.')
                                .format(transaction['trx_nominal'])),
                            trailing: Text(transactionType),
                            subtitle: Text(DateFormat('dd MMMM yyyy – kk:mm')
                                .format(DateTime.parse(
                                    transaction['trx_tanggal']))),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
