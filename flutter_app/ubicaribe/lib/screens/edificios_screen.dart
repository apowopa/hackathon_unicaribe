import 'package:flutter/material.dart';
import 'package:ubicaribe/theme/app_colors.dart'; // ¡Aquí importamos tus colores!
import 'package:ubicaribe/database/db_helper.dart';
import 'package:ubicaribe/models/edificio.dart'; // Descomenta esto para el modelo
import 'package:ubicaribe/screens/edificio_detalle_screen.dart';

class EdificiosView extends StatefulWidget {
  const EdificiosView({super.key});

  @override
  State<EdificiosView> createState() => _EdificiosViewState();
}

class _EdificiosViewState extends State<EdificiosView> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Edificio>> _futureEdificios;

  @override
  void initState() {
    super.initState();
    _futureEdificios = _dbHelper.obtenerEdificios();
  }

  @override
  Widget build(BuildContext context) {
    // Ya no usamos Scaffold ni fondo aquí, porque HomeScreen se encarga de eso.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('🏢', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Text(
                  'Edificios',
                  style: TextStyle(
                    color: AppColors.lightBlue, // Usando tu paleta oficial
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grid leyendo desde SQLite
            Expanded(
              child: FutureBuilder<List<Edificio>>(
                future: _futureEdificios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.royalBlue));
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final edificios = snapshot.data;
                  if (edificios == null || edificios.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay edificios registrados en la base de datos.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: edificios.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      return _BuildingCard(edificio: edificios[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _BuildingCard extends StatelessWidget {
  final Edificio edificio;

  const _BuildingCard({required this.edificio});

  String _obtenerLetra(String nombre) {
    if (nombre.isEmpty) return '?';
    final trimmed = nombre.trimRight();
    return trimmed[trimmed.length - 1].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EdificioDetalleScreen(edificio: edificio),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            // ¡Tus colores oficiales!
            gradient: const LinearGradient(
              colors: [Color(0xFF7037CD), Color(0xFF651F71)], // brightPurple y darkPurple
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF506EE5).withOpacity(0.3), // royalBlue
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 56,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _obtenerLetra(edificio.nombre),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  edificio.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}