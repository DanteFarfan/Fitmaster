import 'package:flutter/material.dart';
import 'package:myapp/view/home_screen.dart';
import 'package:myapp/view/login_screen.dart';
import 'package:myapp/view/usuario_screen.dart';
import 'package:myapp/model/usuario.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: unused_import
import 'package:myapp/database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await DBHelper.borrarBaseDeDatos();

  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMaster',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/usuario') {
          final args = settings.arguments;
          if (args is Usuario) {
            return MaterialPageRoute(
              builder: (context) => UsuarioScreen(usuario: args),
            );
          } else {
            // Argumento no válido o no enviado
            return MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(
                      child: Text('Error: No se proporcionó un usuario válido'),
                    ),
                  ),
            );
          }
        }

        // Ruta no reconocida
        return MaterialPageRoute(
          builder:
              (context) => const Scaffold(
                body: Center(child: Text('Ruta no encontrada')),
              ),
        );
      },
    );
  }
}
