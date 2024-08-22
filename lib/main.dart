import 'package:ai_chatbot/screens/home_screen.dart';
import 'package:ai_chatbot/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      const ProviderScope(child: MyApp())
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ai Chatbot',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        // builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.data == null){
            return const LoginScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}
