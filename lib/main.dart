import 'package:flutter/material.dart';
import 'package:lorem_ipsum/auth/signup.dart';
import 'package:lorem_ipsum/const.dart';
import 'package:lorem_ipsum/screens/activity_screen.dart';
import 'package:lorem_ipsum/screens/home_screen.dart';
import 'package:lorem_ipsum/screens/splash_screen.dart';
import 'package:lorem_ipsum/screens/user_goals/info.dart';
import 'package:lorem_ipsum/screens/welcome.dart';
import 'package:lorem_ipsum/auth/signin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://gjtmqsjvorvrbbtqqidi.supabase.co';
const supabaseKey = SUPABASE_KEY;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calorie App',
      theme: ThemeData.dark(),
      home: const WelcomeScreen(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        SignInScreen.id: (context) => const SignInScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
        BMIScreen.id: (context) => const BMIScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        ActivityScreen.id: (context) => const ActivityScreen(),
      },
    );
  }
}
