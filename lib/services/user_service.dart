class UserService {
  // Просто храним текущего пользователя в памяти
  static Map<String, dynamic>? _currentUser;

  // Сохранение текущего пользователя (только в памяти)
  static void saveCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  // Получение текущего пользователя
  static Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  // Выход пользователя
  static void logout() {
    _currentUser = null;
  }

  // Проверка авторизации
  static bool isLoggedIn() {
    return _currentUser != null;
  }
}