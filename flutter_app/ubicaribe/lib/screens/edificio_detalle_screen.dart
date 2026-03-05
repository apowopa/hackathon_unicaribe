import 'package:flutter/material.dart';
import 'package:ubicaribe/database/db_helper.dart';
import 'package:ubicaribe/models/edificio.dart';
import 'package:ubicaribe/models/departamento.dart';
import 'package:ubicaribe/models/profesor.dart';

// ---------- SCREEN ----------

class EdificioDetalleScreen extends StatefulWidget {
  final Edificio edificio;
  const EdificioDetalleScreen({super.key, required this.edificio});

  @override
  State<EdificioDetalleScreen> createState() => _EdificioDetalleScreenState();
}

class _EdificioDetalleScreenState extends State<EdificioDetalleScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  late Future<_DetalleData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _cargarDatos();
  }

  Future<_DetalleData> _cargarDatos() async {
    final deps = await _db.obtenerDepartamentosPorEdificio(widget.edificio.id);
    // Carga profesores de cada departamento en paralelo
    final futures = deps.map((d) => _db.obtenerProfesoresPorDepartamento(d.id));
    final porDep = await Future.wait(futures);
    // Mapa depId → lista de profesores
    final Map<int, List<Profesor>> profsPorDep = {
      for (var i = 0; i < deps.length; i++) deps[i].id: porDep[i],
    };
    return _DetalleData(departamentos: deps, profsPorDep: profsPorDep);
  }

  // pisos únicos extraídos de los departamentos
  List<String> _buildFloors(List<Departamento> deps) {
    final pisos = deps.map((d) => d.piso).where((p) => p.isNotEmpty).toSet().toList();
    pisos.sort();
    return ['Todos', ...pisos];
  }

  int _selectedFloor = 0;
  List<String> _floors = ['Todos'];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DetalleData>(
      future: _futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1A2E),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF7B2FBE))),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            body: Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)),
            ),
          );
        }

        final data = snapshot.data!;
        _floors = _buildFloors(data.departamentos);

        // Departamentos filtrados por piso
        final depsFiltrados = _selectedFloor == 0
            ? data.departamentos
            : data.departamentos
                .where((d) => d.piso == _floors[_selectedFloor])
                .toList();

        // Tag: primeros 3 departamentos + contador si hay más
        String tagText;
        if (data.departamentos.isEmpty) {
          tagText = widget.edificio.nombre;
        } else {
          final primeros = data.departamentos.take(3).map((d) => d.nombre).join(' • ');
          final extra = data.departamentos.length > 3
              ? ' +${data.departamentos.length - 3} más'
              : '';
          tagText = primeros + extra;
        }

        // Letra del edificio para el placeholder
        final letra = widget.edificio.nombre.trimRight();
        final letraDisplay = letra.isEmpty ? '?' : letra[letra.length - 1].toUpperCase();

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
                              Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                              SizedBox(width: 4),
                              Text('Volver',
                                  style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          widget.edificio.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tag con departamentos reales
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A1A4E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF7B2FBE), width: 1),
                          ),
                          child: Text(
                            tagText,
                            style: const TextStyle(
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
                            border: Border.all(color: const Color(0xFF3A2A5A), width: 1),
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
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Icon(Icons.location_on_outlined,
                                      color: Colors.white54, size: 20),
                                ],
                              ),
                              const SizedBox(height: 12),
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
                                      letraDisplay,
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
                                            backgroundColor: const Color(0xFF7B2FBE),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                          ),
                                          icon: const Icon(Icons.view_in_ar, size: 16),
                                          label: const Text('Ver en AR',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
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
                                onTap: () => setState(() => _selectedFloor = index),
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
                                      color:
                                          selected ? Colors.white : Colors.white54,
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
                          children: [
                            const Icon(Icons.apartment,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Departamentos',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              '${depsFiltrados.length} encontrados',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // Lista de departamentos con profesores anidados
                depsFiltrados.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Text(
                            'No hay departamentos en este piso.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final dep = depsFiltrados[index];
                            final profs = data.profsPorDep[dep.id] ?? [];
                            return _DepartamentoCard(
                              departamento: dep,
                              profesores: profs,
                            );
                          },
                          childCount: depsFiltrados.length,
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------- DATA CONTAINER ----------

class _DetalleData {
  final List<Departamento> departamentos;
  final Map<int, List<Profesor>> profsPorDep;
  const _DetalleData({required this.departamentos, required this.profsPorDep});
}

// ---------- DEPARTAMENTO CARD (expansible con profesores) ----------

class _DepartamentoCard extends StatefulWidget {
  final Departamento departamento;
  final List<Profesor> profesores;
  const _DepartamentoCard(
      {required this.departamento, required this.profesores});

  @override
  State<_DepartamentoCard> createState() => _DepartamentoCardState();
}

class _DepartamentoCardState extends State<_DepartamentoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dep = widget.departamento;
    final profs = widget.profesores;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF23213A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2A4A), width: 1),
      ),
      child: Column(
        children: [
          // Cabecera del departamento
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: profs.isEmpty
                ? null
                : () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Ícono de piso
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1A6E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dep.piso.isEmpty ? '?' : dep.piso,
                      style: const TextStyle(
                          color: Color(0xFFB080FF),
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dep.nombre,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(height: 3),
                        Text(
                          profs.isEmpty
                              ? 'Sin personal registrado'
                              : '${profs.length} persona${profs.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (profs.isNotEmpty)
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white38,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          // Lista expandible de profesores
          if (_expanded && profs.isNotEmpty)
            Column(
              children: [
                const Divider(color: Color(0xFF2E2A4A), height: 1),
                ...profs.map((p) => _ProfesorTile(profesor: p)),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------- PROFESOR TILE (dentro del departamento) ----------

class _ProfesorTile extends StatelessWidget {
  final Profesor profesor;
  const _ProfesorTile({required this.profesor});

  @override
  Widget build(BuildContext context) {
    final inicial =
        profesor.nombre.isNotEmpty ? profesor.nombre[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF5B2A9E),
            child: Text(inicial,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profesor.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
                if (profesor.puesto.isNotEmpty)
                  Text(profesor.puesto,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                if (profesor.correo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined,
                            color: Color(0xFF9B6FDF), size: 12),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(profesor.correo,
                              style: const TextStyle(
                                  color: Color(0xFF9B6FDF), fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                if (profesor.extension.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _Chip(label: 'Ext. ${profesor.extension}'),
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
