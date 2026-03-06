<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/SQLite-offline-003B57?logo=sqlite&logoColor=white" alt="SQLite">
  <img src="https://img.shields.io/badge/AR-GPS--based-FF6F00?logo=google-cardboard&logoColor=white" alt="AR">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platform">
  <img src="https://img.shields.io/badge/Status-MVP%20%2F%20Hackathon-blueviolet" alt="Status">
</p>

# 🏫 UBICARIBE

### Guía Interactiva del Campus — Universidad del Caribe

> **¿Nuevo en el campus? ¿No encuentras un edificio, un departamento o a tu profesor?**
> UBICARIBE pone toda la información del campus en tu bolsillo: un directorio completo que funciona **sin internet** y un sistema de **navegación con Realidad Aumentada** que te señala los edificios en tiempo real a través de la cámara de tu celular.

---

## 📑 Índice

- [Características Principales](#-características-principales)
- [Arquitectura y Stack Tecnológico](#-arquitectura-y-stack-tecnológico)
- [Nota Técnica: Backend y Base de Datos](#-nota-técnica-backend-y-base-de-datos)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Instrucciones de Ejecución](#-instrucciones-de-ejecución)
- [Equipo](#-equipo)

---

## ✨ Características Principales

| Feature | Descripción |
|---|---|
| **📂 Directorio Offline Completo** | Consulta edificios, departamentos, profesores y horarios sin necesidad de conexión a internet. Toda la información se almacena localmente en SQLite. |
| **🔍 Búsqueda Predictiva** | Barra de búsqueda integrada que filtra edificios y profesores en tiempo real conforme el usuario escribe, ofreciendo resultados instantáneos. |
| **📡 Navegación con Realidad Aumentada** | Apunta tu cámara al campus y visualiza marcadores flotantes sobre cada edificio gracias a AR basado en coordenadas GPS. Incluye radar y brújula para orientarte incluso cuando los edificios no están en tu campo de visión. |
| **🔔 Tablón de Avisos** | Sección de notificaciones con indicador de lectura, tarjeta destacada para avisos recientes y marcas de tiempo relativas ("Hace 2 días", "Ayer"). |
| **🏢 Detalle de Edificios** | Vista detallada por edificio con listado de departamentos y profesores asociados, consultados directamente desde la base de datos local. |
| **🎨 Tema Oscuro Profesional** | Paleta de colores oscura/morada centralizada, diseñada para ser visualmente atractiva y cómoda en exteriores. |

---

## 🏗 Arquitectura y Stack Tecnológico

```
┌──────────────────────────────────────────────────┐
│                   UBICARIBE App                  │
│                  (Flutter / Dart)                 │
├──────────────┬──────────────┬────────────────────┤
│   UI Layer   │  Data Layer  │    AR Layer        │
│  Screens &   │  SQLite DB   │  ar_location_view  │
│  Widgets     │  (sqflite)   │  + Geolocator      │
└──────────────┴──────────────┴────────────────────┘
```

| Tecnología | Versión | Rol |
|---|---|---|
| **Flutter** | 3.x (Dart ^3.11) | Framework de UI multiplataforma |
| **SQLite / sqflite** | ^2.4.2 | Base de datos local embebida — funcionamiento 100 % offline |
| **ar_location_view** | ^2.0.16 | Renderizado de marcadores AR sobre la cámara basado en coordenadas GPS |
| **geolocator** | ^13.0.4 | Obtención de la posición GPS del usuario en tiempo real |
| **permission_handler** | ^11.3.1 | Gestión de permisos de cámara y ubicación en Android/iOS |

### Patrones de Diseño

- **Singleton** en `DatabaseHelper` para una única conexión a la base de datos.
- **Modelos con `fromMap()`** para deserialización directa de filas SQLite a objetos Dart.
- **Arquitectura modular** con separación clara en `models/`, `screens/`, `widgets/`, `services/` y `database/`.

---

## 📦 Nota Técnica: Backend y Base de Datos

> **¿Por qué no hay un servidor en producción?**

El repositorio incluye una carpeta [`backend/`](backend/) que contiene la **pipeline de extracción y procesamiento de datos**:

- **Web Scraper** (`src/scrapper.py`) — Extrae el directorio oficial de la Universidad del Caribe (edificios, departamentos, profesores y horarios) utilizando `requests`, `BeautifulSoup` y `Selenium`.
- **ETL y normalización** — Los datos crudos se procesan, normalizan y almacenan en una base de datos SQLite relacional (`unicaribe.db`) con tablas `edificios`, `departamentos`, `profesores` y `notificaciones`.
- **API FastAPI** (`app.py`) — Existe un servidor REST funcional construido con FastAPI que expone los datos vía endpoints (`/edificios`, `/departamentos/{id}`, `/profesores`, etc.).

### Decisión Arquitectónica para el MVP

Para los propósitos de este **prototipo / MVP de hackathon**, se tomó la decisión deliberada de **prescindir de un servidor en vivo**. En su lugar:

1. Se ejecutó el pipeline de scraping y ETL para generar la base de datos `unicaribe.db`.
2. El archivo resultante se **empaquetó directamente en la carpeta `assets/`** de la aplicación Flutter.
3. Al primer arranque, la app copia `unicaribe.db` al almacenamiento local del dispositivo usando `sqflite`.

**Justificación:**

| Beneficio | Descripción |
|---|---|
| **100 % Offline** | La app funciona sin conexión a internet en cualquier zona del campus, incluyendo áreas sin cobertura Wi-Fi. |
| **Ultra-rápida** | Las consultas SQLite locales se ejecutan en microsegundos, sin latencia de red. |
| **Cero configuración** | Los evaluadores pueden instalar el APK y usar la app inmediatamente — sin levantar servidores, configurar URLs ni depender de infraestructura externa. |
| **Resiliente** | No hay puntos de fallo externos: sin caídas de servidor, sin timeouts, sin errores de red. |

> **Nota:** El backend queda disponible como referencia y puede reactivarse fácilmente para una versión con sincronización en línea en el futuro.

---

## 📁 Estructura del Proyecto

```
hackathon_unicaribe/
│
├── backend/                        # Pipeline de datos (scraping + API)
│   ├── app.py                      # Servidor FastAPI (referencia)
│   ├── src/
│   │   ├── scrapper.py             # Web scraper (BeautifulSoup + Selenium)
│   │   └── notificaciones.py       # Gestión de avisos
│   └── data/                       # CSVs fuente y DB generada
│
└── flutter_app/ubicaribe/          # Aplicación móvil Flutter
    ├── assets/
    │   └── unicaribe.db            # Base de datos SQLite empaquetada
    ├── lib/
    │   ├── main.dart               # Punto de entrada de la app
    │   ├── database/
    │   │   └── db_helper.dart      # Singleton DatabaseHelper (copia + consultas)
    │   ├── models/
    │   │   ├── edificio.dart       # Modelo Edificio (id, nombre, lat, lng…)
    │   │   ├── departamento.dart   # Modelo Departamento
    │   │   ├── profesor.dart       # Modelo Profesor
    │   │   └── notificacion.dart   # Modelo Notificación
    │   ├── screens/
    │   │   ├── home_screen.dart    # Shell principal con BottomNavigationBar
    │   │   ├── edificios_screen.dart
    │   │   ├── edificio_detalle_screen.dart
    │   │   ├── avisos_screen.dart  # Tablón de notificaciones
    │   │   └── ar_camera_screen.dart  # Vista de Realidad Aumentada
    │   ├── services/
    │   │   └── location_service.dart  # Servicio de geolocalización
    │   ├── theme/
    │   │   └── app_colors.dart     # Paleta de colores centralizada
    │   └── widgets/
    │       ├── custom_header.dart
    │       ├── custom_search_bar.dart
    │       ├── ar_promo_banner.dart
    │       ├── ar_building_marker.dart  # Marcador AR flotante
    │       └── quick_access_grid.dart   # Grid de acceso rápido
    └── pubspec.yaml                # Dependencias del proyecto
```

---

## 🚀 Instrucciones de Ejecución

### Requisitos Previos

- **Flutter SDK** ≥ 3.x instalado y configurado ([guía oficial](https://docs.flutter.dev/get-started/install))
- **Android Studio** con un emulador configurado o un dispositivo físico Android conectado vía USB
- Verificar el entorno con:
  ```bash
  flutter doctor
  ```

### Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/hackathon_unicaribe.git
cd hackathon_unicaribe/flutter_app/ubicaribe

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo debug
flutter run

# 4. Ejecutar en modo release (rendimiento óptimo, recomendado para evaluación)
flutter run --release
```

### Generar APK para distribución

```bash
flutter build apk --release
```

El archivo APK se generará en `build/app/outputs/flutter-apk/app-release.apk`.

### Permisos requeridos (Android)

La app solicitará automáticamente los siguientes permisos al acceder a la función AR:

- `CAMERA` — para la vista de Realidad Aumentada
- `ACCESS_FINE_LOCATION` — para la geolocalización GPS
- `ACCESS_COARSE_LOCATION` — ubicación aproximada como fallback

---

## 👥 Equipo

- Camila Cameras Ramirez - 250301086
- Ana Valeria Del Mar Valladares Camara - 250300992
- Keira Cristel Jimenez Correa - 250300982
- Manuel Alberto Apolonio Cuevas - 220300773
- Anneliese Nicolle Martínez Sánchez

---

<p align="center">
  <sub>Hecho con 💜 y Flutter — Hackathon UNICARIBE</sub>
</p>
