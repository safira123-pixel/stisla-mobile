import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stisla/models/user_model.dart';

class AuthService {
  String token;
  static String endPoint = '192.168.100.191:8000';

  AuthService({
    required this.token,
  });

  factory AuthService.createObjectResult(Map<String, dynamic> objectResult) {
    return AuthService(token: objectResult['token']);
  }

  static Future requestLogin(String email, String password) async {
    final sharedPref = await SharedPreferences.getInstance();
    var apiUrl = Uri.http(AuthService.endPoint, '/api/auth/login');

    var response = await http.post(
      apiUrl,
      body: {
        "email": email,
        "password": password,
        "device_name": "Safsaf",
      },
      headers: {
        'Accept': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
    );

    var jsonObject = json.decode(response.body);
    if (response.statusCode == 200) {
      var object = AuthService.createObjectResult(jsonObject);
      var userData = (jsonObject as Map<String, dynamic>)['data'];

      var user = User.fromMap(userData);
      var userPropertiesList = User.toStrList(user);
      // simpen ke shared pref
      sharedPref.setString('token', object.token);
      sharedPref.setStringList('user', userPropertiesList);
    }

    return response;
  }

  static Future requestRegister(String name, String email, String password,
      String passwordConfirmation) async {
    var apiUrl = Uri.http(AuthService.endPoint, '/api/auth/register');
    final sharedPref = await SharedPreferences.getInstance();

    final response = await http.post(
      apiUrl,
      headers: {
        "Accept": "application/json",
        "Access-Control_Allow_Origin": "*"
      },
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': 'Safsaf',
      },
    );

    var jsonObject = json.decode(response.body);

    if (response.statusCode == 200) {
      var object = AuthService.createObjectResult(jsonObject);
      var userData = (jsonObject as Map<String, dynamic>)['data'];

      var user = User.fromMap(userData);
      var userPropertiesList = User.toStrList(user);

      sharedPref.setString('token', object.token);
      sharedPref.setStringList('user', userPropertiesList);
    }

    return response;
  }

  static Future requestLogout() async {
    var apiUrl = Uri.http(AuthService.endPoint, '/api/auth/logout');
    final sharedPref = await SharedPreferences.getInstance();
    final token = sharedPref.getString('token');

    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      sharedPref.remove('token');
      sharedPref.remove('user');
    }

    return response;
  }
}
