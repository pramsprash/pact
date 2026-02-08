import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NineMinuteApp());
}

class NineMinuteApp extends StatelessWidget {
  const NineMinuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '9Minute',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
