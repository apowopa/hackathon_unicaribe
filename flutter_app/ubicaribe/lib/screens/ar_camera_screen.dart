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
  const ArCameraScreen({super.key});

  @override
  State<ArCameraScreen> createState() => _ArCameraScreenState();
}

class _ArCameraScreenState extends State<ArCameraScreen> {
  // -------------------------------------------------------------------------
  // TODO: CAMBIAR ESTAS COORDENADAS POR UNAS A 50 METROS DE TU CASA PARA PROBAR
  // Puedes obtener lat/lng con Google Maps → clic derecho → "¿Qué hay aquí?"
  // -------------------------------------------------------------------------
  static const double _testLat = 18.4655;
  static const double _testLng = -66.1057;

  /// Construye un [Position] con valores hardcodeados para el modo demo.
  /// La clase Position de geolocator no tiene constructor const, se usa factory.
  final List<BuildingAnnotation> _annotations = [
    BuildingAnnotation(
      uid: 'edificio_prueba_01',
      title: 'Edificio de Prueba',
      position: Position(
        latitude: _testLat,
        longitude: _testLng,
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
