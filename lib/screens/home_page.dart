import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signin_page.dart';
import 'trip_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the auth provider to check user's authentication status
    final authProvider = context.watch<UserAuthProvider>();
    final user = authProvider.user;

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If user is signed in, go to TripPage; otherwise, go to SignIn page
    return user != null ? const TripPage() : const SignIn();
  }
}
