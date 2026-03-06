import 'package:ar_location_view/ar_location_view.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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
  List<BuildingAnnotation> get _annotations {
    final destino = widget.destinoSeleccionado;
    if (destino == null) return [];
    return _todosLosEdificios
        .where((e) => e.title == destino)
        .toList();
  }

  // -----------------------------------------------------------------------
  // Estado de inicialización: permisos + GPS listos.
  // -----------------------------------------------------------------------
  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInit();
  }

  /// Verifica permisos de cámara y ubicación, y que el GPS esté encendido.
  /// Solo cuando todo OK muestra la cámara AR.
  Future<void> _checkPermissionsAndInit() async {
    // 1. Permiso de cámara
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      _setError('Se requiere acceso a la cámara para usar la vista AR.');
      return;
    }

    // 2. Permiso de ubicación
    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      _setError('Se requiere acceso a la ubicación para mostrar los marcadores.');
      return;
    }

    // 3. Servicio de ubicación encendido
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setError(
        'El servicio de ubicación está desactivado. '
        'Enciéndelo en los ajustes de tu dispositivo.',
      );
      return;
    }

    // 4. Obtener la primera posición para confirmar que el GPS responde.
    try {
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      _setError('No se pudo obtener la ubicación GPS. Intenta de nuevo.');
      return;
    }

    // Todo en orden → mostramos la cámara AR y el diálogo de demo.
    if (!mounted) return;
    setState(() => _isReady = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDemoDialog());
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _isReady = false;
      _errorMessage = message;
    });
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

  // -----------------------------------------------------------------------
  // Pantalla de carga / error mientras se inicializa GPS + permisos.
  // -----------------------------------------------------------------------
  Widget _buildLoadingOrError() {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) ...[
                const Icon(Icons.error_outline, color: AppColors.lightBlue, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                    _checkPermissionsAndInit();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver', style: TextStyle(color: Colors.white54)),
                ),
              ] else ...[
                const CircularProgressIndicator(color: AppColors.lightBlue),
                const SizedBox(height: 20),
                const Text(
                  'Activando cámara y GPS…',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Muestra la pantalla de carga/error hasta que todo esté listo.
    if (!_isReady) return _buildLoadingOrError();

    return Scaffold(
      body: Stack(
        children: [
          // -----------------------------------------------------------------
          // Vista AR principal envuelta en SafeArea para que el radar
          // no quede clippeado detrás de la barra de sistema (bottom).
          // -----------------------------------------------------------------
          SafeArea(
            top: false,
            child: Padding(
              // Empuja el borde inferior del widget hacia arriba para que
              // el radar no quede clippeado contra el borde de la pantalla.
              padding: const EdgeInsets.only(bottom: 90),
              child: ArLocationWidget(
                annotations: _annotations,
                annotationViewBuilder: _buildAnnotationCard,
                showDebugInfoSensor: false,
                onLocationChange: (Position position) {},

                // --- Calibración de distancia ---
                maxVisibleDistance: 300,

                // --- Tamaño del radar (+10 % sobre 110 → 121) ---
                radarWidth: 121,

                // --- Posición del radar centrada en la parte inferior ---
                radarPosition: RadarPosition.bottomCenter,

                // --- Estilo del radar ---
                backgroundRadar: AppColors.cardDark,
                markerColor: AppColors.lightBlue,
              ),
            ),
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
