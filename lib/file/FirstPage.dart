import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tosha/file/ConnexionPage.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  @override
  void initState() {
    super.initState();
    // Naviguer vers la page suivante après 3 secondes
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Connexionpage()),
      );
    });
  }

  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Text(
          "TODOLIST",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
