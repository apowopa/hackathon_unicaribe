# UBICARIBE — Registro de Progreso del Proyecto

> Documento de contexto técnico para desarrollo continuo. Actualizar con cada sesión.

---

## 🎯 Descripción del Proyecto

**Nombre:** UBICARIBE  
**Plataforma:** Flutter (Android / iOS)  
**Cliente:** Universidad del Caribe, Cancún, México  
**Objetivo:** Aplicación móvil que funciona como guía interactiva del campus universitario, combinando un directorio offline completo con navegación en Realidad Aumentada (AR) basada en GPS.

---

## 🛠 Stack Tecnológico

| Tecnología | Rol en el Proyecto |
|---|---|
| **Flutter** | Framework principal (Dart) |
| **SQLite / sqflite** | Base de datos local offline (`ubicaribe.db`) |
| **sqflite** (pub.dev) | Plugin Flutter para SQLite |
| **ar_location_view** | Realidad Aumentada basada en coordenadas GPS |
| **Android Studio** | IDE principal + emulador Android |
| **Ubuntu 24.04 (Linux)** | Sistema operativo de desarrollo |

---

## ✅ Hitos Completados

### 1. Configuración del Entorno de Desarrollo
- Sistema operativo: **Linux Ubuntu 24.04** con KVM habilitado para emulación rápida de Android.
- Shell configurado con **Zsh** (Oh My Zsh).
- **Android Studio** instalado y configurado con emulador ARM64/x86_64.
- Depuración USB habilitada en dispositivo físico Android.
- Flutter SDK instalado y verificado con `flutter doctor` sin errores críticos.

---

### 2. Arquitectura del Proyecto
Estructura modular limpia implementada desde el inicio:

```
lib/
├── main.dart
├── database/
│   └── db_helper.dart          # Singleton DatabaseHelper
├── models/
│   ├── edificio.dart
│   ├── departamento.dart
│   ├── profesor.dart
│   └── notificacion.dart
├── screens/
│   ├── home_screen.dart        # Shell principal con BottomNavigationBar
│   ├── edificios_screen.dart   # Vista de edificios (EdificiosView)
│   ├── edificio_detalle_screen.dart
│   └── ar_camera_screen.dart
├── services/
│   └── location_service.dart
├── theme/
│   └── app_colors.dart         # Paleta de colores centralizada
└── widgets/
    ├── custom_header.dart
    ├── custom_search_bar.dart
    ├── ar_promo_banner.dart
    ├── quick_access_grid.dart
    ├── ar_building_marker.dart
    └── ar_promo_banner.dart
```

---

### 3. Paleta de Colores (`app_colors.dart`)
Tema oscuro/morado profesional centralizado en `AppColors`:
- `backgroundDark` — fondo principal
- `cardDark` — fondo de tarjetas
- `royalBlue` — acento principal
- `lightBlue` — acento secundario/íconos

---

### 4. Base de Datos Local (`DatabaseHelper`)
- Archivo `ubicaribe.db` incluido en `assets/` y copiado al directorio de documentos en el primer arranque.
- **Patrón Singleton** implementado en `db_helper.dart` para una única instancia de conexión.
- Tablas gestionadas: `edificios`, `departamentos`, `profesores`, `notificaciones`.
- Método principal: `obtenerEdificios()` → `Future<List<Edificio>>`.

---

### 5. Modelos de Datos
Cada modelo implementa el constructor `fromMap(Map<String, dynamic>)` para deserializar filas de SQLite:

| Archivo | Clase | Campos principales |
|---|---|---|
| `edificio.dart` | `Edificio` | `id`, `nombre`, `descripcion`, `latitud`, `longitud`, `imagen` |
| `departamento.dart` | `Departamento` | `id`, `nombre`, `edificioId` |
| `profesor.dart` | `Profesor` | `id`, `nombre`, `departamentoId`, `horario` |
| `notificacion.dart` | `Notificacion` | `id`, `titulo`, `cuerpo`, `fecha` |

---

### 6. Pantalla Principal (`HomeScreen`)
- `StatefulWidget` con `BottomNavigationBar` de 3 tabs: **Inicio**, **Avisos**, **Edificios**.
- Body indexado: `views[_selectedIndex]` — cada tab renderiza su propia vista.
- Callback `_onNavTap(int)` compartido entre el `BottomNavBar` y el `QuickAccessGrid`.
- Contenido del tab Inicio extraído en widget privado `_HomeContent` para mantener claridad.

**Vistas registradas:**
```dart
final List<Widget> views = [
  _HomeContent(onNavTap: _onNavTap),  // index 0 — Inicio
  Center(child: Text('Avisos próximamente')),  // index 1 — Avisos
  const EdificiosView(),               // index 2 — Edificios
];
```

---

### 7. Pantalla de Edificios (`EdificiosView`)
- `StatefulWidget` con `FutureBuilder<List<Edificio>>` conectado a `DatabaseHelper`.
- Muestra un `GridView` de 2 columnas con `_BuildingCard` por cada edificio.
- Manejo de estados: cargando → error → vacío → datos.
- Diseñada como **vista embebida** (sin Scaffold propio), con `SafeArea` + `Expanded`.

---

### 8. Grid de Acceso Rápido (`QuickAccessGrid`)
- `StatelessWidget` con parámetro opcional `onNavTap: void Function(int)?`.
- Cada ítem tiene un `tabIndex` que indica a qué tab del `BottomNav` navega:
  - **Edificios** → tabIndex `2`
  - **Avisos** → tabIndex `1`
  - **Directorio / Horarios** → tabIndex `-1` (pendiente de implementación)
- Usa `InkWell + Ink` para efecto ripple sobre el fondo del `Container`.

---

### 9. Pantalla AR (`ar_camera_screen.dart`)
- Maqueta inicial con `Stack` simulando la cámara AR.
- Widget flotante `ArBuildingMarker` simula marcadores 3D superpuestos.
- Integración real de `ar_location_view` pendiente (requiere permisos GPS y cámara).

### 10. Pantalla de Avisos (`AvisosScreen`)
- `StatefulWidget` con `FutureBuilder<List<Notificacion>>` conectado a `DatabaseHelper.obtenerNotificaciones()`.
- La notificación más reciente se muestra en `_FeaturedCard` (estilo tablón de pizarrón, fondo verde oscuro con borde dorado).
- El resto se listan en `_AvisoCard` con borde lateral de color: **morado** si no leída, **azul** si ya leída.
- Punto indicador (dot) visible en avisos no leídos. Ícono dinámico: campana activa vs check.
- Función `_timeAgo(DateTime)` convierte `created_at` de SQLite a texto relativo ("Hace 2 días", "Ayer", etc.).
- Registrado en `home_screen.dart` como `views[1]` del `BottomNavigationBar`.

---

## 🚧 Próximos Pasos

- [ ] Implementar pantalla de detalle de edificio (`edificio_detalle_screen.dart`) con mapa y lista de departamentos.
- [ ] Conectar `ar_camera_screen.dart` con `ar_location_view` usando coordenadas reales de la BD.
- [x] Implementar tab de Avisos (`notificaciones`) consumiendo la tabla `notificaciones`.
- [ ] Implementar tab de Directorio consumiendo `profesores` y `departamentos`.
- [ ] Añadir buscador funcional en `CustomSearchBar` (filtrar edificios/profesores).
- [ ] Agregar imágenes/thumbs a los edificios en la BD y mostrarlos en `_BuildingCard`.
- [ ] Pulir animaciones de transición entre tabs.
- [ ] Testing en dispositivo físico (depuración USB).

---

## 🐛 Problemas Resueltos

| Problema | Causa | Solución |
|---|---|---|
| Tab de Edificios no cargaba | `body` del Scaffold nunca cambiaba según `_selectedIndex` | Refactorizar body a `views[_selectedIndex]` con lista indexada |
| `QuickAccessGrid` no navegaba | Sin `onTap` definido en los ítems | Añadir `onNavTap` callback + `InkWell` con `tabIndex` por ítem |
| Nombre incorrecto del widget | Widget se llama `EdificiosView`, no `EdificiosScreen` | Corregido el import y la referencia en `home_screen.dart` |

---

*Última actualización: Sesión de desarrollo — Arquitectura base completada.*
