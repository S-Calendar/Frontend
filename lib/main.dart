import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Firebase import 추가
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/start_page.dart';
import 'pages/main_page.dart';
import 'pages/search_page.dart'; // 올바른 경로와 이름으로 수정
import '/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // dotenv 먼저 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화 추가
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCalendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // splash부터 시작
      routes: {
        '/': (context) => const StartPage(),
        '/main_page': (context) => const MainPage(),
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
