import 'package:flutter/material.dart';
import 'calculation_screen.dart';
import '../models/user_data.dart';
import 'auth/login_screen.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserData userData = UserData.empty();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final currentUser = UserService.getCurrentUser();
    
    if (currentUser != null) {
      try {
        final applications = await ApiService.getUserApplications(currentUser['id'].toString());
        
        setState(() {
          userData = UserData.fromApiData(currentUser, applications);
        });
      } catch (e) {
        setState(() {
          userData = UserData(
            name: currentUser['name'],
            email: currentUser['email'],
            franchises: [],
            applications: [],
            calculations: [],
          );
        });
      }
    } else {
      setState(() {
        userData = UserData.empty();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MainContentScreen(userData: userData),
          const CatalogScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class MainContentScreen extends StatelessWidget {
  final UserData userData;

  const MainContentScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Franchise Economics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userData.franchises.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Предложения франшиз',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CatalogScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: userData.franchises.map((franchise) {
                    return _buildFranchiseCard(franchise, context);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (userData.applications.isNotEmpty) ...[
              const Text(
                'Ваши заявки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...userData.applications.map((app) => _buildApplicationCard(app)),
              const SizedBox(height: 20),
            ],

            if (userData.calculations.isNotEmpty) ...[
              const Text(
                'Последние расчеты',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...userData.calculations.map((calc) => _buildCalculationCard(calc, context)),
            ],

            if (userData.franchises.isEmpty && userData.applications.isEmpty && userData.calculations.isEmpty) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.business_center, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Добро пожаловать!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Начните с просмотра каталога франшиз',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFranchiseCard(Franchise franchise, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalculationScreen(franchiseName: franchise.name),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    franchise.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${franchise.investment} ₽',
                    style: const TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(Application application) {
    Color statusColor = Colors.orange;
    if (application.status == 'approved') statusColor = Colors.green;
    if (application.status == 'rejected') statusColor = Colors.red;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статус: ${_getStatusText(application.status)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
          ),
          Text('Франшиза: ${application.franchiseName}'),
          Text('Дата: ${_formatDate(application.date)}'),
        ],
      ),
    );
  }

  Widget _buildCalculationCard(Calculation calculation, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalculationScreen(franchiseName: calculation.franchiseName),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calculate, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ROI: ${calculation.roi}% | "${calculation.franchiseName}"'),
                  Text(
                    _formatDate(calculation.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'На рассмотрении';
      case 'approved': return 'Одобрена';
      case 'rejected': return 'Отклонена';
      default: return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог франшиз'),
      ),
      body: const Center(
        child: Text('Здесь будет каталог франшиз'),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = UserService.getCurrentUser();
    setState(() {
      _user = user;
    });
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesScreen()),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _navigateToApplications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ApplicationsScreen()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                UserService.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Выйти'),
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
        title: const Text('Профиль'),
      ),
      body: _user == null 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(_user!['name'] ?? 'Пользователь'),
                  accountEmail: Text(_user!['email'] ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      _user!['name'] != null && _user!['name'].isNotEmpty 
                          ? _user!['name'][0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Избранные франшизы'),
                  onTap: () => _navigateToFavorites(context),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('История расчетов'),
                  onTap: () => _navigateToHistory(context),
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Мои заявки'),
                  onTap: () => _navigateToApplications(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Настройки'),
                  onTap: () => _navigateToSettings(context),
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Выйти'),
                  onTap: _logout,
                ),
              ],
            ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранные франшизы')),
      body: const Center(child: Text('Избранные франшизы')),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История расчетов')),
      body: const Center(child: Text('История расчетов')),
    );
  }
}

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заявки')),
      body: const Center(child: Text('Мои заявки')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: const Center(child: Text('Настройки')),
    );
  }
}