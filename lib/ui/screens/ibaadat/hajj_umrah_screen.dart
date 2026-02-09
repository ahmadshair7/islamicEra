import 'package:flutter/material.dart';

class HajjUmrahScreen extends StatefulWidget {
  const HajjUmrahScreen({super.key});

  @override
  State<HajjUmrahScreen> createState() => _HajjUmrahScreenState();
}

class _HajjUmrahScreenState extends State<HajjUmrahScreen> {
  final Map<String, bool> _checklist = {
    'Ihram & Niyyah': false,
    'Tawaf (7 rounds)': false,
    'Maqam-e-Ibrahim Prayer': false,
    'Drinking Zamzam': false,
    'Sa\'ee (Safa & Marwa)': false,
    'Halq or Taqsir (Cutting hair)': false,
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hajj & Umrah Guide'),
          backgroundColor: const Color(0xFF003366),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Rituals', icon: Icon(Icons.list_alt)),
              Tab(text: 'Checklist', icon: Icon(Icons.check_circle_outline)),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
          ),
        ),
        body: TabBarView(
          children: [
            _buildRitualsTab(),
            _buildChecklistTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRitualsTab() {
    final rituals = [
      {
        'title': 'Umrah Step-by-Step',
        'steps': [
          'Wear Ihram at the Miqat.',
          'Perform Niyyah (intention) for Umrah.',
          'Perform Tawaf around the Kaaba 7 times.',
          'Pray 2 Rakats behind Maqam-e-Ibrahim.',
          'Drink Zamzam water.',
          'Perform Sa\'ee between Safa and Marwa 7 times.',
          'Men shave/shorten hair; Women cut a small portion.'
        ]
      },
      {
        'title': 'Hajj Overview',
        'steps': [
          '8th Zil-Hijjah: Enter Ihram and move to Mina.',
          '9th Zil-Hijjah: Move to Arafat (Wuquf).',
          '9th Night: Stay at Muzdalifah.',
          '10th Zil-Hijjah: Rami (Stoning) at Jamarat al-Aqaba.',
          '10th Zil-Hijjah: Qurbani (Sacrifice) and Shaving hair.',
          '10th-12th Zil-Hijjah: Tawaf-e-Ziyarat and Sa\'ee.',
          '11th-13th Zil-Hijjah: Stoning all three Jamarat.'
        ]
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rituals.length,
      itemBuilder: (context, index) {
        final section = rituals[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(section['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
            ),
            ... (section['steps'] as List<String>).map((step) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green),
                title: Text(step, style: const TextStyle(fontSize: 14)),
              ),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildChecklistTab() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Keep track of your Umrah rituals as you perform them.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _checklist.keys.map((String key) {
              return CheckboxListTile(
                title: Text(key, style: const TextStyle(fontWeight: FontWeight.w500)),
                value: _checklist[key],
                activeColor: Colors.green,
                onChanged: (bool? value) {
                  setState(() {
                    _checklist[key] = value!;
                  });
                },
              );
            }).toList(),
          ),
        ),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    int completed = _checklist.values.where((v) => v).length;
    double progress = completed / _checklist.length;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0 ? Colors.green : Colors.blue),
            minHeight: 10,
          ),
        ],
      ),
    );
  }
}
