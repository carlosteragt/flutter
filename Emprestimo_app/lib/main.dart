import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'telas/tela1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(); // Carrega o .env

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const EmprestimoApp());
}

class EmprestimoApp extends StatelessWidget {
  const EmprestimoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Tela1(),
    );
  }
}
