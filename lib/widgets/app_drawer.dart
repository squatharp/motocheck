import 'package:flutter/material.dart';

/// Menú lateral de la app.
class AppDrawer extends StatelessWidget {
  final VoidCallback onNuevaInspeccion;

  const AppDrawer({super.key, required this.onNuevaInspeccion});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colores.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.two_wheeler, size: 48, color: colores.onPrimary),
                Text(
                  'MotoCheck',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: colores.onPrimary),
                ),
                Text(
                  'Inspección de motos',
                  style: TextStyle(color: colores.onPrimary),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Inspecciones'),
            onTap: () => Navigator.pop(context), // ya estamos en la lista
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Nueva inspección'),
            onTap: () {
              Navigator.pop(context); // cierra el Drawer
              onNuevaInspeccion();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'MotoCheck',
                applicationVersion: '1.0.0',
                children: const [
                  Text('Bitácora de entregas y recepciones de motos '
                      'con evidencia fotográfica, dictado y GPS.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}