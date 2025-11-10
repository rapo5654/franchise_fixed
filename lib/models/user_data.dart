class UserData {
  final String name;
  final String email;
  final List<Franchise> franchises;
  final List<Application> applications;
  final List<Calculation> calculations;

  UserData({
    required this.name,
    required this.email,
    required this.franchises,
    required this.applications,
    required this.calculations,
  });

  factory UserData.empty() {
    return UserData(
      name: '',
      email: '',
      franchises: [],
      applications: [],
      calculations: [],
    );
  }

  // Конструктор из данных API
  factory UserData.fromApiData(Map<String, dynamic> userData, List<dynamic> applications) {
    return UserData(
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      franchises: [],
      applications: applications.map((app) => Application.fromApiData(app)).toList(),
      calculations: [],
    );
  }
}

class Franchise {
  final String id;
  final String name;
  final String description;
  final int investment;
  final String imageUrl;

  Franchise({
    required this.id,
    required this.name,
    required this.description,
    required this.investment,
    required this.imageUrl,
  });

  // Конструктор из данных API
  factory Franchise.fromApiData(Map<String, dynamic> data) {
    return Franchise(
      id: data['id'].toString(),
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      investment: data['investment_amount'] ?? 0,
      imageUrl: data['logo_path'] ?? '',
    );
  }
}

class Application {
  final String id;
  final String franchiseName;
  final String status;
  final DateTime date;

  Application({
    required this.id,
    required this.franchiseName,
    required this.status,
    required this.date,
  });

  // Конструктор из данных API
  factory Application.fromApiData(Map<String, dynamic> data) {
    return Application(
      id: data['id'].toString(),
      franchiseName: data['franchise_name'] ?? '',
      status: data['status'] ?? 'pending',
      date: DateTime.parse(data['created_at']),
    );
  }
}

class Calculation {
  final String id;
  final String franchiseName;
  final double roi;
  final DateTime date;

  Calculation({
    required this.id,
    required this.franchiseName,
    required this.roi,
    required this.date,
  });
}