import 'package:flutter/material.dart';
import 'package:lorem_ipsum/auth/signin.dart';
import 'package:lorem_ipsum/main.dart';
import 'package:lorem_ipsum/screens/home_screen.dart';
import 'package:lorem_ipsum/screens/user_goals/info.dart';
import 'package:lorem_ipsum/screens/welcome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String id = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;
    if (session != null) {
      final response = await supabase
          .from('user_profile')
          .select('profile_completed')
          .eq('user_id', user!.id);
      print(response);

      if (response.isEmpty || response[0]['profile_completed'] == false) {
        print('----');
        Navigator.pushNamed(
          context,
          BMIScreen.id,
        );
      } else {
        Navigator.pushNamed(
          context,
          HomeScreen.id,
        );
      }
      // Navigator.pushReplacementNamed(context, MainScreen.id);
    } else {
      Navigator.pushReplacementNamed(context, WelcomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
