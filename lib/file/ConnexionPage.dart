import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tosha/file/HomePage.dart';
import 'package:tosha/file/InscriptionPage.dart';

class Connexionpage extends StatefulWidget {
  const Connexionpage({super.key});

  @override
  State<Connexionpage> createState() => _ConnexionpageState();
}

class _ConnexionpageState extends State<Connexionpage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final String apiUrl =
      "https://todolist-api-production-1e59.up.railway.app/auth/connexion";

  Future<void> _login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (!validateInputs(email, password)) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      setState(() {
        isLoading = false;
      });

      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? accessToken = responseData['accessToken'] as String?;

        if (accessToken != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', accessToken);
          print(
              "Token d'accès stocké: $accessToken"); // Vérification du stockage

          await prefs.setString('user_id', responseData['user']['id']);
          await prefs.setString('user_name', responseData['user']['nom']);
          await prefs.setString('user_email', responseData['user']['email']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
          );

          _clearInputFields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Le token d\'authentification est manquant.')),
          );
        }
      } else {
        handleError(response);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau : ${e.toString()}')),
      );
    }
  }

  void _clearInputFields() {
    emailController.clear();
    passwordController.clear();
  }

  bool validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont obligatoires.')),
      );
      return false;
    }
    return true;
  }

  void handleError(http.Response response) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final errorMessage = responseData['message'] ??
          'Échec de la connexion. Veuillez vérifier vos informations.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage.toString())));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur inconnue est survenue.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Todolist',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                  labelText: 'Mot de passe', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _login,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Connexion'),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Inscriptionpage()));
              },
              child: const Text("Vous n'avez pas de compte ? Créer un",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
