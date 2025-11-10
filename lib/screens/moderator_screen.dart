import 'package:flutter/material.dart';

class ModeratorScreen extends StatefulWidget {
  const ModeratorScreen({super.key});

  @override
  State<ModeratorScreen> createState() => _ModeratorScreenState();
}

class _ModeratorScreenState extends State<ModeratorScreen> {
  int _currentTab = 0;

  void _addFranchise() {
    // Реализация перехода к созданию франшизы
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateFranchiseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель модератора'),
      ),
      body: _currentTab == 0 
          ? _buildFranchisesTab()
          : _buildApplicationsTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Франшизы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Заявки',
          ),
        ],
      ),
      floatingActionButton: _currentTab == 0 
          ? FloatingActionButton(
              onPressed: _addFranchise,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFranchisesTab() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.business, color: Colors.blue),
          title: const Text('Кофейня "Coffee Time"'),
          subtitle: const Text('Инвестиции: 300 000 ₽'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {},
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.business, color: Colors.blue),
          title: const Text('Бургерная "Burger Master"'),
          subtitle: const Text('Инвестиции: 500 000 ₽'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsTab() {
    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.all(8),
          color: Colors.orange.withAlpha(25),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Иван Иванов'),
            subtitle: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Франшиза: Кофейня "Coffee Time"'),
                Text('Статус: На рассмотрении'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Временная заглушка для экрана создания франшизы
class CreateFranchiseScreen extends StatelessWidget {
  const CreateFranchiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создание франшизы')),
      body: const Center(child: Text('Создание франшизы')),
    );
  }
}