import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tosha/file/ConnexionPage.dart';
import 'package:tosha/file/UserInfo.dart';

class Task {
  String id;
  String contenu;
  bool isComplete;

  Task({required this.id, required this.contenu, this.isComplete = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(id: json['id'], contenu: json['contenu']);
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController taskController = TextEditingController();
  List<Task> tasks = [];
  final String apiUrl =
      "https://todolist-api-production-1e59.up.railway.app/task";
  bool isLoading = false;
  String? accessToken; // Token d'accès pour l'authentification

  @override
  void initState() {
    super.initState();
    _loadToken(); // Charger le token à l'initialisation
    _fetchTasks(); // Récupérer les tâches à l'initialisation
  }

  // Fonction pour charger le token d'accès depuis le stockage local
  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('auth_token');
    });
  }

  // Fonction pour récupérer les tâches depuis l'API
  Future<void> _fetchTasks() async {
    setState(() {
      isLoading = true;
    });
    // Dans la fonction _fetchTasks
    print("Fetching tasks...");
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $accessToken"},
      );
      print("API response: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> taskList = jsonDecode(response.body);
        setState(() {
          tasks = taskList.map((task) => Task.fromJson(task)).toList();
        });
      } else {
        print("Erreur de statut: ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur: $e");
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> taskList = jsonDecode(response.body);
        setState(() {
          tasks = taskList.map((task) => Task.fromJson(task)).toList();
        });
      } else {
        throw Exception(
            'Erreur lors du chargement des tâches : ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fonction pour ajouter une nouvelle tâche
  Future<void> _addTask() async {
    final taskContenu = taskController.text;
    if (taskContenu.isNotEmpty) {
      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur d\'authentification. Veuillez vous reconnecter.')),
        );
        return;
      }

      try {
        final Map<String, dynamic> tache = {'contenu': taskContenu};
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
          body: jsonEncode(tache),
        );

        if (response.statusCode == 201) {
          taskController.clear();
          _fetchTasks();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tâche ajoutée avec succès !')),
          );
        } else {
          throw Exception(
              'Erreur lors de l\'ajout de la tâche : ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  // Fonction pour confirmer la suppression d'une tâche
  Future<void> _confirmDeleteTask(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _deleteTask(index); // Appel de la fonction de suppression
    }
  }

  // Fonction pour supprimer une tâche
  Future<void> _deleteTask(int index) async {
    final task = tasks[index];
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/${task.id}'),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          tasks.removeAt(index); // Retirer la tâche de la liste
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tâche supprimée avec succès')),
        );
      } else {
        throw Exception(
            'Erreur lors de la suppression de la tâche : ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  // Fonction pour mettre à jour une tâche
  Future<void> _updateTask(int index) async {
    final taskContenu = taskController.text;
    if (taskContenu.isNotEmpty) {
      final task = tasks[index];
      try {
        final response = await http.put(
          Uri.parse('$apiUrl/${task.id}'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
          body: jsonEncode({"contenu": taskContenu}),
        );

        if (response.statusCode == 200) {
          setState(() {
            tasks[index].contenu = taskContenu;
            taskController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tâche mise à jour avec succès')),
          );
        } else {
          throw Exception(
              'Erreur lors de la mise à jour de la tâche : ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  // Fonction pour éditer une tâche
  void _editTask(int index) {
    taskController.text = tasks[index].contenu;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la tâche'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: 'Nom de la tâche'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateTask(index);
              },
              child: const Text('Sauvegarder'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todolist', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          // Utilisation de Builder pour obtenir le contexte
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.green),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Ouvre le Drawer
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context); // Ferme le Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Userinfo()),
                ); // Redirige vers la page Profil
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Connexionpage()),
                ); // Redirige vers la page Profil
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la tâche',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: Text(
                      'Ajouter la tâche',
                      style: TextStyle(color: Colors.white),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(tasks[index].contenu),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editTask(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteTask(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
