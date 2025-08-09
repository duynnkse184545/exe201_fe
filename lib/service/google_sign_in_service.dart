import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  // TODO: Replace with your actual Google OAuth Client ID from Google Cloud Console
  static const String _webClientId = '241894839268-l62128bkfajdjhv81ftplcl271kotjd5.apps.googleusercontent.com';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // For web and some Android configurations
    clientId: _webClientId,
  );

  static Future<String?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication authentication = await account.authentication;
      return authentication.idToken;
    } catch (error) {
      print('Google Sign-In Error: $error');
      throw Exception('Google Sign-In failed: $error');
    }
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}