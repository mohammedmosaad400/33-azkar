
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'mezi/mezi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize().then((initializtionStatus) {
    initializtionStatus.adapterStatuses.forEach((key, value) {
      debugPrint('Adapter status for $key: ${value.description}');
    });
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "الاذكار",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AnimatedSplashScreen(duration: 3000,splash:
      Transform.scale(
          scale: 2.5 ,child:
          const Image(image: AssetImage('assets/mezo_robot.png'),
          ),),
          nextScreen: const MyHome(),
          backgroundColor: Colors.deepPurple,
          splashTransition:SplashTransition.rotationTransition ),

      routes: {

        'tab_mezi':(context){
          return const Mezi();
        },

      },
    );
  }
}

class MyHome extends StatelessWidget{
  const MyHome({Key? key}) : super(key: key);

  // This widget is the home of your application.
  @override
  Widget build(BuildContext context) {
    return const Directionality(textDirection: TextDirection.rtl, child: Scaffold(

          body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
              child: Mezi()
          )
      ),);

  }
}

