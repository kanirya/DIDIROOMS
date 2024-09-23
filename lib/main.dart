
import 'package:didirooms2/view/screens/login/splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../view_models/provider/provider.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.locationWhenInUse.isDenied.then((value){
    if(value){
      Permission.locationWhenInUse.request();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellowAccent),
          useMaterial3: true,


        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
