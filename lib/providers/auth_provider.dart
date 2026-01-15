import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  AuthProvider() {
    _initialize();
    _listenToAuthChanges();
  }

  void _initialize() {
    _user = SupabaseService.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  void _listenToAuthChanges() {
    SupabaseService.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        _user = session?.user;
        _error = null;
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
      } else if (event == AuthChangeEvent.userUpdated) {
        _user = session?.user;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Parse Supabase errors for better user messages
      String errorMessage = 'Failed to create account';
      
      if (e.toString().contains('over_email_send_rate_limit')) {
        errorMessage = 'Too many signup attempts. Please wait 48 seconds and try again.';
      } else if (e.toString().contains('User already registered')) {
        errorMessage = 'An account with this email already exists. Try signing in instead.';
      } else if (e.toString().contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('Password')) {
        errorMessage = 'Password must be at least 6 characters.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthApiException: ', '');
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Parse Supabase errors for better user messages
      String errorMessage = 'Sign in failed';
      
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please check your email and confirm your account first.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthApiException: ', '');
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await SupabaseService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
