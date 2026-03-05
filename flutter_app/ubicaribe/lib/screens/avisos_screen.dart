import 'package:flutter/material.dart';
import 'package:ubicaribe/database/db_helper.dart';
import 'package:ubicaribe/models/notificacion.dart';

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});

  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  late Future<List<Notificacion>> _futureAvisos;

  @override
  void initState() {
    super.initState();
    _futureAvisos = DatabaseHelper().obtenerNotificaciones();
  }

  String _timeAgo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inDays >= 14) return 'Hace ${(diff.inDays / 7).floor()} semanas';
    if (diff.inDays >= 7) return 'Hace 1 semana';
    if (diff.inDays >= 2) return 'Hace ${diff.inDays} días';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inHours >= 1) return 'Hace ${diff.inHours} h';
    return 'Hace un momento';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: FutureBuilder<List<Notificacion>>(
          future: _futureAvisos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7B2FBE)));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)),
              );
            }

            final avisos = snapshot.data ?? [];
            // El primero (más reciente) va al tablón destacado
            final destacado = avisos.isNotEmpty ? avisos.first : null;
            final resto = avisos.length > 1 ? avisos.sublist(1) : <Notificacion>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Row(
                    children: [
                      Text('📢', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 10),
                      Text(
                        'Avisos',
                        style: TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tablón destacado — aviso más reciente
                  if (destacado != null) ...
                    [
                      _FeaturedCard(notificacion: destacado),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B3FD9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Más información →',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                  // Lista del resto de avisos
                  if (resto.isEmpty && destacado == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('No hay avisos por el momento.',
                            style: TextStyle(color: Colors.white54)),
                      ),
                    )
                  else
                    ...resto.map((n) => _AvisoCard(
                          notificacion: n,
                          timeAgo: _timeAgo(n.createdAt),
                          accentColor: n.leida
                              ? const Color(0xFF4A90D9)
                              : const Color(0xFF7B2FBE),
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------- FEATURED CHALKBOARD CARD ----------

class _FeaturedCard extends StatelessWidget {
  final Notificacion notificacion;
  const _FeaturedCard({required this.notificacion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2D5A1B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8960C), width: 3),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D5A0).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFFF5E6A3),
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: '⚠️  '),
                  TextSpan(text: notificacion.titulo),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              notificacion.mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.75),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------- AVISO CARD ----------

class _AvisoCard extends StatelessWidget {
  final Notificacion notificacion;
  final String timeAgo;
  final Color accentColor;
  const _AvisoCard(
      {required this.notificacion,
      required this.timeAgo,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF23213A),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono: campana si no leída, check si leída
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                notificacion.leida
                    ? Icons.check_circle_outline
                    : Icons.notifications_active_outlined,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificacion.titulo,
                          style: TextStyle(
                            color: notificacion.leida
                                ? Colors.white70
                                : Colors.white,
                            fontWeight: notificacion.leida
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notificacion.leida)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notificacion.mensaje,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                        color: Color(0xFF9B6FDF),
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
