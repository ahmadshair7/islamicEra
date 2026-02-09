import 'package:flutter/material.dart';

class QaidaScreen extends StatelessWidget {
  const QaidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> alphabet = [
      {'letter': 'ا', 'trans': 'Alif'},
      {'letter': 'ب', 'trans': 'Ba'},
      {'letter': 'ت', 'trans': 'Ta'},
      {'letter': 'ث', 'trans': 'Tha'},
      {'letter': 'ج', 'trans': 'Jeem'},
      {'letter': 'ح', 'trans': 'Ha'},
      {'letter': 'خ', 'trans': 'Kha'},
      {'letter': 'د', 'trans': 'Dal'},
      {'letter': 'ذ', 'trans': 'Thal'},
      {'letter': 'ر', 'trans': 'Ra'},
      {'letter': 'ز', 'trans': 'Za'},
      {'letter': 'س', 'trans': 'Seen'},
      {'letter': 'ش', 'trans': 'Sheen'},
      {'letter': 'ص', 'trans': 'Sad'},
      {'letter': 'ض', 'trans': 'Dad'},
      {'letter': 'ط', 'trans': 'Ta'},
      {'letter': 'ظ', 'trans': 'Za'},
      {'letter': 'ع', 'trans': 'Ain'},
      {'letter': 'غ', 'trans': 'Ghain'},
      {'letter': 'ف', 'trans': 'Fa'},
      {'letter': 'ق', 'trans': 'Qaf'},
      {'letter': 'ك', 'trans': 'Kaf'},
      {'letter': 'ل', 'trans': 'Lam'},
      {'letter': 'م', 'trans': 'Meem'},
      {'letter': 'ن', 'trans': 'Noon'},
      {'letter': 'و', 'trans': 'Waw'},
      {'letter': 'ه', 'trans': 'Ha'},
      {'letter': 'ي', 'trans': 'Ya'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Noorani Qaida'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF003366),
            child: const Center(
              child: Text(
                'Learn Arabic Alphabet',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: alphabet.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        alphabet[index]['letter']!,
                        style: const TextStyle(fontSize: 40, fontFamily: 'Amiri', fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alphabet[index]['trans']!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
