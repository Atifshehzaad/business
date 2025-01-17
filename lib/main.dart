import 'package:flutter/material.dart';
import 'services/db_helper.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Delete the old database
  await DBHelper.instance.deleteDatabaseFile();
  // await DBHelper.instance.deleteDatabase();
  await DBHelper.instance.printTables();
  // Initialize the app and populate the tables
  await DBHelper.instance.populateBusinesses();
  await DBHelper.instance.populateCategories(); // Populate new data
  await DBHelper.instance.printTableData('businesses'); // Verify businesses
  // await DBHelper.instance.printTableData('categories');
  // Initialize the database and seed data
  //await DBHelper.instance.seedBusinesses();
  runApp(MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // Delete the database when the app closes
    DBHelper.instance.deleteDatabaseFile();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Business Info App',
      theme: AppTheme.lightTheme, // Apply Light Theme
      darkTheme: AppTheme.darkTheme, // Apply Dark Theme
      themeMode: ThemeMode.system, // Switch based on system theme
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(loggedInUserId: 1,),
      },
    );
  }
}
