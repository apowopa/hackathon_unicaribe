import 'package:ar_location_view/ar_location_view.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ubicaribe/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Subclase de ArAnnotation (requerida: ArAnnotation es abstracta).
// Añadimos el campo 'title' ya que ArAnnotation no tiene nombre por defecto.
// ---------------------------------------------------------------------------
class BuildingAnnotation extends ArAnnotation {
  final String title;

  BuildingAnnotation({
    required super.uid,
    required super.position,
    required this.title,
  });
}

/// Pantalla de Realidad Aumentada basada en GPS.
///
/// Permisos requeridos:
/// - Android (AndroidManifest.xml):
///     android.permission.CAMERA
///     android.permission.ACCESS_FINE_LOCATION
///     android.permission.ACCESS_COARSE_LOCATION
/// - iOS (Info.plist):
///     NSCameraUsageDescription
///     NSLocationWhenInUseUsageDescription
class ArCameraScreen extends StatefulWidget {
  /// Lugar seleccionado desde la barra de búsqueda.
  /// Si es null no se muestra ningún marcador AR.
  final String? destinoSeleccionado;

  const ArCameraScreen({super.key, this.destinoSeleccionado});

  @override
  State<ArCameraScreen> createState() => _ArCameraScreenState();
}

class _ArCameraScreenState extends State<ArCameraScreen> {
  /// Catálogo completo de edificios del campus UNICARIBE.
  static final List<BuildingAnnotation> _todosLosEdificios = [
    BuildingAnnotation(
      uid: 'cafeteria',
      title: 'Cafetería',
      position: Position(
        latitude: 21.200972,
        longitude: -86.823000,
        timestamp: DateTime(2026),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      ),
    ),
    BuildingAnnotation(
      uid: 'servicios_escolares',
      title: 'Servicios Escolares',
      position: Position(
        latitude: 21.200750,
        longitude: -86.823194,
        timestamp: DateTime(2026),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      ),
    ),
    BuildingAnnotation(
      uid: 'edificio_b',
      title: 'Edificio B',
      position: Position(
        latitude: 21.200778,
        longitude: -86.823528,
        timestamp: DateTime(2026),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      ),
    ),
    BuildingAnnotation(
      uid: 'edificio_f',
      title: 'Edificio F',
      position: Position(
        latitude: 21.199972,
        longitude: -86.824139,
        timestamp: DateTime(2026),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      ),
    ),
    BuildingAnnotation(
      uid: 'edificio_g',
      title: 'Edificio G',
      position: Position(
        latitude: 21.200306,
        longitude: -86.824583,
        timestamp: DateTime(2026),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      ),
    ),
  ];

  /// Devuelve solo el edificio que coincida con [destinoSeleccionado].
  /// Si el destino es null la lista queda vacía y no aparece ningún marcador.
  List<BuildingAnnotation> get _annotations {
    final destino = widget.destinoSeleccionado;
    if (destino == null) return [];
    return _todosLosEdificios
        .where((e) => e.title == destino)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Muestra el aviso de demostración una vez terminado el primer frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDemoDialog());
  }

  /// Diálogo informativo que aparece al abrir la pantalla por primera vez.
  void _showDemoDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBlue, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.science_outlined, color: AppColors.lightBlue, size: 24),
            SizedBox(width: 10),
            Text(
              'Modo de Prueba',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Modo de Prueba: Esta es una demostración del MVP. '
          'Se mostrará un marcador de ejemplo flotando cerca de tu ubicación real.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // -----------------------------------------------------------------
          // Vista AR principal.
          // ar_location_view gestiona los permisos de cámara y ubicación
          // automáticamente en tiempo de ejecución.
          // -----------------------------------------------------------------
          ArLocationWidget(
            annotations: _annotations,
            annotationViewBuilder: _buildAnnotationCard,
            showDebugInfoSensor: false,
            // Callback requerido: recibe la posición actual del usuario.
            onLocationChange: (Position position) {},

            // --- Calibración de distancia ---
            // Solo muestra edificios dentro de un radio de 300 m.
            // Evita que puntos lejanos se aglomeren en el centro del radar.
            maxVisibleDistance: 300,

            // --- Tamaño del radar ---
            // Radar discreto de 110 px de diámetro.
            radarWidth: 110,

            // --- Posición del radar ---
            // Lo colocamos en la parte inferior-central para no tapar la cámara.
            radarPosition: RadarPosition.bottomCenter,

            // --- Estilo del radar ---
            backgroundRadar: AppColors.cardDark,
            markerColor: AppColors.lightBlue,
          ),

          // -----------------------------------------------------------------
          // Botón de retroceso (esquina superior izquierda).
          // -----------------------------------------------------------------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FloatingActionButton.small(
                heroTag: 'ar_back_button',
                backgroundColor: AppColors.cardDark.withValues(alpha: 0.85),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de videojuego que flota sobre cada edificio en la cámara.
  Widget _buildAnnotationCard(BuildContext context, ArAnnotation annotation) {
    // Casteamos a nuestra subclase para acceder al campo 'title'.
    final building = annotation as BuildingAnnotation;

    final String distanceLabel = annotation.distanceFromUser < 1000
        ? '${annotation.distanceFromUser.toStringAsFixed(0)} m'
        : '${(annotation.distanceFromUser / 1000).toStringAsFixed(1)} km';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre del edificio
          Text(
            building.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Distancia desde el usuario
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.near_me, color: AppColors.lightBlue, size: 12),
              const SizedBox(width: 4),
              Text(
                distanceLabel,
                style: const TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
