import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edificio A',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B2FBE)),
        useMaterial3: true,
      ),
      home: const EdificioDetalleScreen(),
    );
  }
}

// ---------- DATA MODELS ----------

class DirectoryPerson {
  final String name;
  final String department;
  final String email;
  final String ext;
  final String floor;
  final String initials;

  const DirectoryPerson({
    required this.name,
    required this.department,
    required this.email,
    required this.ext,
    required this.floor,
    required this.initials,
  });
}

// ---------- SCREEN ----------

class EdificioDetalleScreen extends StatefulWidget {
  const EdificioDetalleScreen({super.key});

  @override
  State<EdificioDetalleScreen> createState() => _EdificioDetalleScreenState();
}

class _EdificioDetalleScreenState extends State<EdificioDetalleScreen> {
  int _selectedFloor = 0;

  final List<String> _floors = [
    'Todos',
    'Planta baja',
    'Primer nivel',
    'Segundo nivel',
  ];

  final List<DirectoryPerson> _allPeople = const [
    DirectoryPerson(
      name: 'Acuña González Elvira',
      department: 'Idiomas',
      email: 'eacuna@ucaribe.edu.mx',
      ext: 'Ext. 1001',
      floor: 'Planta baja',
      initials: 'A',
    ),
    DirectoryPerson(
      name: 'Avellaneda Del Río María Florencia',
      department: 'Idiomas',
      email: 'mavellaneda@ucaribe.edu.mx',
      ext: 'Ext. 1002',
      floor: 'Planta baja',
      initials: 'A',
    ),
    DirectoryPerson(
      name: 'Castillo Hernández Roberto',
      department: 'Desarrollo Estudiantil',
      email: 'rcastillo@ucaribe.edu.mx',
      ext: 'Ext. 1005',
      floor: 'Primer nivel',
      initials: 'C',
    ),
    DirectoryPerson(
      name: 'González Pérez Laura',
      department: 'Idiomas',
      email: 'lgonzalez@ucaribe.edu.mx',
      ext: 'Ext. 1008',
      floor: 'Planta baja',
      initials: 'G',
    ),
    DirectoryPerson(
      name: 'Martínez López Héctor',
      department: 'Desarrollo Estudiantil',
      email: 'hmartinez@ucaribe.edu.mx',
      ext: 'Ext. 1012',
      floor: 'Segundo nivel',
      initials: 'M',
    ),
    DirectoryPerson(
      name: 'Rodríguez Sánchez Ana',
      department: 'Idiomas',
      email: 'arodriguez@ucaribe.edu.mx',
      ext: 'Ext. 1015',
      floor: 'Primer nivel',
      initials: 'R',
    ),
  ];

  List<DirectoryPerson> get _filteredPeople {
    if (_selectedFloor == 0) return _allPeople;
    final selected = _floors[_selectedFloor];
    return _allPeople.where((p) => p.floor == selected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back,
                              color: Colors.white70, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Volver',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    const Text(
                      'Edificio A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1A4E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF7B2FBE), width: 1),
                      ),
                      child: const Text(
                        'Idiomas • Desarrollo Estudiantil',
                        style: TextStyle(
                          color: Color(0xFF9B6FDF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Floor plan card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF23213A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF3A2A5A), width: 1),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Plano del edificio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.location_on_outlined,
                                  color: Colors.white54, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Map placeholder
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1830),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  'A',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.12),
                                    fontSize: 90,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF7B2FBE),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      icon: const Icon(Icons.view_in_ar,
                                          size: 16),
                                      label: const Text(
                                        'Ver en AR',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Floor filter tabs
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _floors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = _selectedFloor == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFloor = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF7B2FBE)
                                    : const Color(0xFF23213A),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF7B2FBE)
                                      : const Color(0xFF3A2A5A),
                                ),
                              ),
                              child: Text(
                                _floors[index],
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Directory header
                    Row(
                      children: const [
                        Icon(Icons.people_outline,
                            color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Directorio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Directory list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final person = _filteredPeople[index];
                  return _PersonCard(person: person);
                },
                childCount: _filteredPeople.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ---------- PERSON CARD ----------

class _PersonCard extends StatelessWidget {
  final DirectoryPerson person;
  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF23213A),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFF2E2A4A), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF5B2A9E),
            child: Text(
              person.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  person.department,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        color: Color(0xFF9B6FDF), size: 13),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        person.email,
                        style: const TextStyle(
                          color: Color(0xFF9B6FDF),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Chip(label: person.ext),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_outlined,
                        color: Colors.white54, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      person.floor,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1A6E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB080FF),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
