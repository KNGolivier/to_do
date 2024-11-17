import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tosha/file/ConnexionPage.dart';

class Inscriptionpage extends StatefulWidget {
  const Inscriptionpage({super.key});

  @override
  State<Inscriptionpage> createState() => _InscriptionpageState();
}

class _InscriptionpageState extends State<Inscriptionpage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // URL de l'API pour l'inscription
  final String apiUrl =
      "https://todolist-api-production-1e59.up.railway.app/auth/inscription";

  Future<void> _createAccount(BuildContext context) async {
    final String nom = nomController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // Validation basique
    if (nom.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tous les champs sont obligatoires.')),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un email valide.')),
      );
      return;
    }

    if (password.length <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mot de passe trop court.')),
      );
      return;
    }

    // Activer l'indicateur de chargement
    setState(() {
      isLoading = true;
    });

    // Envoyer la requête POST à l'API
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nom": nom,
        "email": email,
        "password": password,
      }),
    );

    // Désactiver l'indicateur de chargement
    setState(() {
      isLoading = false;
    });

    // Vérifier la réponse de l'API
    print("Response status: ${response.statusCode}"); // Affichage du statut
    print(
        "Response body: ${response.body}"); // Affichage du corps de la réponse

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !')),
      );

      // Rediriger vers la page d'accueil après la création
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Connexionpage()),
      );
    } else {
      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String errorMessage = responseData['message'] != null
            ? responseData['message'].join(', ')
            : 'Échec de la création du compte. Veuillez réessayer.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur inconnue est survenue.')),
        );
      }
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
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => _createAccount(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Créer le compte'),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Vous avez déjà un compte ? Connexion",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
