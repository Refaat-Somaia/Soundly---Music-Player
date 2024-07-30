import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:soundly/screens/mainScreen.dart';
import '../global.dart';
import '../alertsAndVars.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    getSettings();
    askForPremissions();
    super.initState();


  }


   askForPremissions() async {


    var status = await Permission.storage.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
      ].request();
          Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => Sizer(builder: (context, orientation, screenType) {
                return MainPage();
              })));
    });
    }
    else{
          Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => Sizer(builder: (context, orientation, screenType) {
                return MainPage();
              })));
    });
    }
  }

  void getSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool('darkMode') != null) {
      if (pref.getBool('darkMode') == false) {
        setState(() {
          bodyColor = const Color(0xFFE7E7E7);
          secondColor = const Color(0xFFE1E1E1);
          fontColor = const Color(0xFF2D2D2D);
        });
      }
    }
    if (pref.getString('theme') != null) {
      setState(() {
        mainColor = themes[pref.getString("theme").toString()]!;
      });
    }

  if(pref.getBool('playAnimations')!=null){
    setState(() {
      playAnimations=pref.getBool('playAnimations')!;
    });

  }
 else {
  playAnimations=true;
 } 



if(pref.getBool('shadowsOn')!=null){
    setState(() {
      shadowsOn=pref.getBool('shadowsOn')!;
    });

  }
 else {
  shadowsOn=true;
 } 

 if(pref.getBool('autoPlayNext')!=null){
    setState(() {
      playAnimations=pref.getBool('autoPlayNext')!;
    });

  }
 else {
  playAnimations=true;
 } 

  
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        color: bodyColor,
        child: Center(
          child: Stack(children: [
            Animate(
                    child: Center(
                        child: Image.asset(
              'assets/images/Group 3.png',
              width: 20,
            )))
                .animate(delay: 500.ms)
                .slide(
                    end: const Offset(-0.30, -0.30),
                    duration: 2900.ms,
                    curve: Curves.easeInOut)
                .fadeOut(
                    delay: 1000.ms, curve: Curves.easeInOut, duration: 800.ms)
                .shimmer(
                    delay: 500.ms, duration: 800.ms, curve: Curves.easeInOut),
            Animate(
                    child: Center(
                        child: Image.asset(
              'assets/images/Group 3.png',
              width: 20,
            )))
                .animate(delay: 500.ms)
                .slide(
                    end: const Offset(0.30, -0.30),
                    duration: 3000.ms,
                    curve: Curves.easeInOut)
                .fadeOut(
                    delay: 1000.ms, curve: Curves.easeInOut, duration: 800.ms)
                .shimmer(
                    delay: 500.ms, duration: 800.ms, curve: Curves.easeInOut),
            Animate(
                    child: Center(
                        child: Image.asset(
              'assets/images/Group 3.png',
              width: 20,
            )))
                .animate(delay: 500.ms)
                .slide(
                    end: const Offset(0, -0.40),
                    duration: 3200.ms,
                    curve: Curves.easeInOut)
                .fadeOut(
                    delay: 1000.ms, curve: Curves.easeInOut, duration: 800.ms)
                .shimmer(
                    delay: 500.ms, duration: 800.ms, curve: Curves.easeInOut),
            Center(
              child: Animate(
                  child: Container(
                height: 130,
                width: 130,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
              ).animate()),
            ),
          ]),
        ),
      ),
    );
  }
}
