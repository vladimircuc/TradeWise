import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../service/nav_bar.dart';
import 'landing_page.dart';

/// AuthPage is a stateless widget that handles authentication status changes
/// and displays appropriate screens based on the user's authentication state.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Listening to authentication state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // When user is logged in, display the navigation bar

            // Uncomment the following lines to fetch user-specific data from Firestore using UserModel
            /*
            final firestore = FirebaseFirestore.instance;
            final FirebaseAuth auth = FirebaseAuth.instance;
            final User? user = auth.currentUser;
            final usersCollection = firestore.collection('Users');
            final tempUser = UserModel.fromUid(uid: user!.uid);
            print(tempUser.getBalance());
            */

            return const NavBar();
          } else {
            // When no user is logged in, display the landing page
            return const LandingPage();
          }
        },
      ),
    );
  }
}
