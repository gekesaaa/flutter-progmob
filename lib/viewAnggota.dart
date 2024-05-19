import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ViewMembersPage extends StatefulWidget {
  const ViewMembersPage({Key? key}) : super(key: key);

  @override
  _ViewMembersPageState createState() => _ViewMembersPageState();
}

class Member {
  final String nomorInduk;
  final String nama;
  final String alamat;
  final String tglLahir;
  final String telepon;

  Member({
    required this.nomorInduk,
    required this.nama,
    required this.alamat,
    required this.tglLahir,
    required this.telepon,
  });
}

class _ViewMembersPageState extends State<ViewMembersPage> {
  final List<Member> members = [];
  final Dio dio = Dio();
  final String apiUrl = 'https://mobileapis.manpits.xyz/api/anggota';

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      final response = await dio.get(apiUrl);
      final data = response.data['data'] as List<dynamic>;
      final List<Member> fetchedMembers = data.map((memberData) {
        return Member(
          nomorInduk: memberData['nomor_induk'],
          nama: memberData['nama'],
          alamat: memberData['alamat'],
          tglLahir: memberData['tgl_lahir'],
          telepon: memberData['telepon'],
        );
      }).toList();
      setState(() {
        members.addAll(fetchedMembers);
      });
    } catch (e) {
      print('Error fetching members: $e');
      // Handle error fetching members
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Members'),
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(members[index].nama),
            subtitle: Text('Nomor Induk: ${members[index].nomorInduk}'),
            onTap: () {
              // Tambahkan logika untuk menampilkan detail anggota
              // Misalnya, buka halaman detail anggota atau tampilkan dialog dengan informasi anggota
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Detail Anggota'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Nama: ${members[index].nama}'),
                        Text('Alamat: ${members[index].alamat}'),
                        Text('Tanggal Lahir: ${members[index].tglLahir}'),
                        Text('Telepon: ${members[index].telepon}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Tutup'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
