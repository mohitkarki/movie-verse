import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  /// CONTROLLERS (GET INPUT FROM USER)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// LOADING STATE (FOR BUTTON)
  bool isLoading = false;

  /// PASSWORD VISIBILITY
  bool _obscurePassword = true;

  /// SNACKBAR FUNCTION (SHOW MESSAGE)
  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// SIGNUP FUNCTION (WITH EMAIL VERIFICATION)
  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    /// VALIDATION
    if (email.isEmpty || password.isEmpty) {
      _show("All fields are required");
      return;
    }

    if (!email.contains("@")) {
      _show("Enter a valid email");
      return;
    }

    if (password.length < 6) {
      _show("Password must be at least 6 characters");
      return;
    }

    try {
      setState(() => isLoading = true);

      /// CREATE USER
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(code: "user-null");
      }

      /// SEND EMAIL VERIFICATION
      await user.sendEmailVerification();

      /// SIGN OUT (IMPORTANT)
      await FirebaseAuth.instance.signOut();

      _show("Verification email sent! Check Inbox or Spam.");

      /// GO BACK TO LOGIN
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String message = "Signup failed";

      if (e.code == 'email-already-in-use') {
        message = "Email already registered";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      } else if (e.code == 'weak-password') {
        message = "Weak password";
      }

      _show(message);

    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// FORGOT PASSWORD FUNCTION
  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    /// CHECK EMAIL ENTERED
    if (email.isEmpty) {
      _show("Enter your email first");
      return;
    }

    try {
      /// SEND RESET EMAIL
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _show("Password reset link sent");

    } catch (e) {
      _show("Failed to send reset email");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[300],

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// TITLE
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// EMAIL INPUT
                _buildInputField(
                  controller: emailController,
                  label: "Email",
                ),

                const SizedBox(height: 12),

                /// PASSWORD INPUT
                _buildInputField(
                  controller: passwordController,
                  label: "Password",
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                /// FORGOT PASSWORD BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: forgotPassword,
                    child: const Text("Forgot Password?"),
                  ),
                ),

                const SizedBox(height: 10),

                /// SIGNUP BUTTON
                SizedBox(
                  width: screenWidth * 0.3,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signup,

                    child: isLoading
                        ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1.8,
                      ),
                    )
                        : const Text("Sign Up"),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔙 BACK TO LOGIN
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// INPUT FIELD UI
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),

      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: TextField(
        controller: controller,
        obscureText: obscure,

        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}