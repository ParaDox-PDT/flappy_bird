import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Reactive stream of user authentication status changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the currently authenticated user, or null if none
  User? get currentUser => _auth.currentUser;

  /// Initiates the Google Sign-in flow
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Sign-in was cancelled by the user
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Sync user data to leaderboard if they already have one, or initialize it
        await _initializeLeaderboardEntry(user);
      }

      return user;
    } catch (e) {
      print('Error during Google Sign-in: $e');
      rethrow;
    }
  }

  /// Signs the current user out of both Firebase and Google accounts
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error during sign-out: $e');
      rethrow;
    }
  }

  /// Initializes a leaderboard entry for new users, keeping existing high scores
  Future<void> _initializeLeaderboardEntry(User user) async {
    final docRef = _firestore.collection('leaderboard').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // First-time signup: write empty/initial document
      await docRef.set({
        'userId': user.uid,
        'displayName': user.displayName ?? 'Player',
        'photoUrl': user.photoURL ?? '',
        'score': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Existing user: ensure displayName or photoUrl are up to date
      await docRef.update({
        'displayName': user.displayName ?? 'Player',
        'photoUrl': user.photoURL ?? '',
      });
    }
  }

  /// Submits a new score to the global Firestore leaderboard if it exceeds their current record
  Future<void> submitScore(int score) async {
    final user = currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('leaderboard').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'userId': user.uid,
        'displayName': user.displayName ?? 'Player',
        'photoUrl': user.photoURL ?? '',
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      final currentBest = doc.data()?['score'] as num? ?? 0;
      if (score > currentBest) {
        await docRef.update({
          'score': score,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Retrieves the top 20 players on the global leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final querySnapshot = await _firestore
          .collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
      rethrow;
    }
  }
}
