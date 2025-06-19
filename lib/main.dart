import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:admin/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SistradeApp());
}

class SistradeApp extends StatelessWidget {
  const SistradeApp({super.key});

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fctoken');
    return token != null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            //home: SplashScreen(),
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final bool isLoggedIn = snapshot.data ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sistrade',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: bgColor,
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                .apply(bodyColor: Colors.white),
            canvasColor: secondaryColor,
          ),
          home: isLoggedIn ? const MainScreen() : LoginScreen(),
          /*home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => MenuAppController(),
              ),
            ],
            child: MainScreen(),
          ),*/
        );
 
      },
    );

  }

}
