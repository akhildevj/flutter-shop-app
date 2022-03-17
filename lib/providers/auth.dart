import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

const webHost = "identitytoolkit.googleapis.com";
const webSignUpPath = "/v1/accounts:signUp";
const webSignInPath = "/v1/accounts:signInWithPassword";
const webApi = "AIzaSyDdnSbIRxk1aUUDK394gO8UiIu-oV7nqjg";

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate != null &&
        _token != null &&
        ((_expiryDate as DateTime).isAfter(DateTime.now()))) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(String email, String password, String path) async {
    try {
      final url = Uri.https(webHost, path, {'key': webApi});
      final body = json.encode(
          {'email': email, 'password': password, 'returnSecureToken': true});

      final response = await http.post(url, body: body);
      final data = json.decode(response.body);

      if (data['error'] != null) throw HttpException(data['error']['message']);

      _token = data['idToken'];
      _userId = data['localId'];
      _expiryDate =
          DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));

      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (err) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, webSignUpPath);
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, webSignInPath);
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final Map<String, dynamic> userData = Map<String, dynamic>.from(
        json.decode(prefs.getString('userData') as String));

    final expiryDate = DateTime.parse(userData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = userData['token'] as String;
    _userId = userData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }

    final timeToExpiry =
        (_expiryDate as DateTime).difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    notifyListeners();
  }
}
