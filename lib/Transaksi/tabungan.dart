import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class TabunganPage extends StatefulWidget {
  const TabunganPage({super.key});

  @override
  State<TabunganPage> createState() => _TabunganPageState();
}

class _TabunganPageState extends State<TabunganPage> {
  AnggotaDatas? anggotaDatas;
  List<Anggota> filteredAnggotaDatas = [];
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    getAnggota();
    _searchController.addListener(_filterAnggota);
  }

  Future<void> getAnggota() async {
    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      Map<String, dynamic> responseData = _response.data;
      print(responseData);
      setState(() {
        anggotaDatas = AnggotaDatas.fromJson(responseData);
        filteredAnggotaDatas = anggotaDatas?.anggotaDatas ?? [];
      });
      await getSaldoAnggota();
    } on DioException catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getSaldoAnggota() async {
    if (anggotaDatas != null) {
      for (var anggota in filteredAnggotaDatas) {
        try {
          final _response = await _dio.get(
            '$_apiUrl/saldo/${anggota.id}',
            options: Options(
              headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
            ),
          );
          Map<String, dynamic> responseData = _response.data;
          setState(() {
            anggota.saldo = responseData['data']['saldo'];
          });
        } on DioException catch (e) {
          print('${e.response} - ${e.response?.statusCode}');
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  void getJenisTransaksi(BuildContext context) async {
    const int multiplyDebit = 1;

    try {
      final _response = await Dio().get(
        '$_apiUrl/jenistransaksi',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );
      print(_response.data);
      if (_response.statusCode == 200) {
        final jenisTransaksi = _response.data['data']['jenistransaksi'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 68, 59, 59)
                          .withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Jenis Transaksi',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    SizedBox(height: 20.0),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: jenisTransaksi.length,
                      itemBuilder: (context, index) {
                        final transaction = jenisTransaksi[index];
                        return ListTile(
                          title: Text(
                            '${transaction['id']} - ${transaction['trx_name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            transaction['trx_multiply'] == multiplyDebit
                                ? "Debit"
                                : "Kredit",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 80)),
                        child: const Text(
                          'Oke',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
    } catch (error) {
      print('Error: $error');
    }
  }

  void _filterAnggota() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredAnggotaDatas = anggotaDatas?.anggotaDatas
              .where((anggota) =>
                  anggota.nama.toLowerCase().contains(query) ||
                  anggota.nomor_induk.toString().contains(query))
              .toList() ??
          [];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tabungan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[600],
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
        actions: [
          Row(
            children: [
              _isSearching
                  ? Container(
                      width: 200.0,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari anggota...',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    )
                  : Container(),
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _searchController.clear();
                    }
                    _isSearching = !_isSearching;
                  });
                },
              ),
            ],
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: anggotaDatas == null || filteredAnggotaDatas.isEmpty
            ? const Text("Belum Ada Anggota yang Yang Menabung")
            : ListView.builder(
                itemCount: filteredAnggotaDatas.length,
                itemBuilder: (context, index) {
                  final anggota = filteredAnggotaDatas[index];
                  return ListTile(
                    title: Text(anggota.nama),
                    subtitle: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp.',
                          ).format(anggota.saldo),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/tabunganDetail',
                              arguments: {
                                'id': anggota.id,
                                'nama': anggota.nama,
                                'saldo': anggota.saldo,
                              },
                            );
                          },
                          icon: const Icon(Icons.info_outline_rounded),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/addTabungan',
                              arguments: anggota.id,
                            );
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AnggotaDatas {
  final List<Anggota> anggotaDatas;

  AnggotaDatas({required this.anggotaDatas});

  factory AnggotaDatas.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final anggota = data?['anggotas'] as List<dynamic>?;

    return AnggotaDatas(
      anggotaDatas: anggota
              ?.map((anggotaData) =>
                  Anggota.fromJson(anggotaData as Map<String, dynamic>))
              .toList() ??
          [],
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
  final int? status_aktif;
  int saldo;

  Anggota({
    required this.id,
    required this.nomor_induk,
    required this.nama,
    required this.alamat,
    required this.tgl_lahir,
    required this.telepon,
    required this.status_aktif,
    required this.saldo,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'],
      nomor_induk: json['nomor_induk'],
      nama: json['nama'],
      alamat: json['alamat'],
      tgl_lahir: json['tgl_lahir'],
      telepon: json['telepon'],
      status_aktif: json['status_aktif'],
      saldo: 0,
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final int memberId;

  const TransactionDetailPage({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    // Implement your TransactionDetailPage here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Center(
        child: Text('Detail Transaksi untuk anggota ID: $memberId'),
      ),
    );
  }
}
