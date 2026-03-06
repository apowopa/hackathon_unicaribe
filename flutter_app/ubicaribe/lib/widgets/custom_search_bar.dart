import 'package:flutter/material.dart';
import 'package:ubicaribe/screens/ar_camera_screen.dart';
import 'package:ubicaribe/theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  /// Opciones disponibles para el autocompletado.
  static const List<String> _opciones = [
    'Cafetería',
    'Servicios Escolares',
    'Edificio B',
    'Edificio F',
    'Edificio G',
  ];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // Filtra las opciones según lo que escribe el usuario.
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable<String>.empty();
        return _opciones.where(
          (o) => o.toLowerCase().contains(value.text.toLowerCase()),
        );
      },
      // Al seleccionar: muestra un SnackBar y navega a la pantalla AR
      // pasando el destino elegido para filtrar el marcador correcto.
      onSelected: (String seleccion) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Navegando hacia: $seleccion',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.cardDark,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ArCameraScreen(destinoSeleccionado: seleccion),
          ),
        );
      },
      // Menú desplegable con estilo oscuro.
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: AppColors.cardDark,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            elevation: 6,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.lightBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            option,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      // Campo de texto con el mismo estilo visual que el diseño original.
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (_) => onSubmit(),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Buscar persona, edificio o departamento...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
      },
    );
  }
}
