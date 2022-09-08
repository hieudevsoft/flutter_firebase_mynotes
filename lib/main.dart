import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mynotes/ui/home_page_view/home_page_view.dart';
import 'package:mynotes/ui/login_view/login_view.dart';
import 'package:mynotes/ui/notes_view/notes_view.dart';
import 'package:mynotes/ui/register_view/register_view.dart';
import 'package:mynotes/ui/verify_email_view/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(const MyApp());
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top]);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: getRoutes());
  }
}

Map<String, Widget Function(BuildContext)> getRoutes() {
  return {
    '/login': (context) => const LoginView(),
    '/register': (context) => const RegisterView(),
    '/notes': (context) => const NotesView(),
    '/verifyEmail': (context) => const VerifyEmailView(),
  };
}
