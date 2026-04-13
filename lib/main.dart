import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/instagram_provider.dart';
import 'screens/connect_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InstagramProvider()..init(),
      child: MaterialApp(
        title: 'Instagram Clone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Consumer<InstagramProvider>(
          builder: (context, provider, _) {
            if (provider.initializing) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF3797EF)),
                ),
              );
            }
            if (provider.isConnected) {
              return const ProfileScreen();
            }
            return const ConnectScreen();
          },
        ),
      ),
    );
  }
}
