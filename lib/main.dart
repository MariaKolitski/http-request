import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const UserSearchApp());
}

class UserSearchApp extends StatelessWidget {
  const UserSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscar Usuário - ReqRes API', //Título da página
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserSearchScreen(), //telahome
    );
  }
}

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _idController = TextEditingController();
  Map<String, dynamic>? _userData; //armazena os dados do usuário retornados
  bool _isLoading = false; //estado carregamento

  void messageGrow(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(255, 235, 235, 1),
          title: const Text("Erro!", style: TextStyle(color: Colors.red)),
          content: Text(text),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ); //AlertDialog de fato
      },
    );
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _userData = null;
    });

    try {
      final id = _idController.text.trim();

      // Validação do ID
      if (id.isEmpty || int.tryParse(id) == null) {
        messageGrow('Usuário não encontrado! Por favor, digite um ID válido (número entre 1 e 12)');
        return;
      }

      final numericId = int.parse(id);
      if (numericId < 1 || numericId > 12) {
        messageGrow('O ID deve ser um número entre 1 e 12');
        return;
      }

      final response = await http.get( //requisição api
        Uri.parse('https://reqres.in/api/users/$id'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userData = data['data'];
        });
      } else if (response.statusCode == 404) {
        messageGrow('Usuário não encontrado!');
      } else {
        messageGrow('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      messageGrow('Erro ao conectar com a API: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  //'tela' de fato, 'estilização'
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Usuário - ReqRes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Digite o ID do usuário (1-12)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchUser,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Buscar Usuário', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
            if (_userData != null) ...[
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_userData!['avatar']),
              ),
              const SizedBox(height: 20),
              Text(
                '${_userData!['first_name']} ${_userData!['last_name']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _userData!['email'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'ID: ${_userData!['id']}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}