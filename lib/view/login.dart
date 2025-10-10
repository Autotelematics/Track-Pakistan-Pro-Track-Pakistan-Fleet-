import 'package:flutter/material.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _launchURLBrowser(String link) async {
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _onSignInPressed() {
    if (emailController.text.isEmpty) {
      Utils.flushBarErrorMessage('Please enter email', context);
    } else if (passwordController.text.isEmpty) {
      Utils.flushBarErrorMessage('Please enter password', context);
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: AppStyles.appScreenBackgroundImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 250,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
              ),
              child: Image.asset(AppStyles.logoPath),
            ),
            SizedBox(height: 40),

            // "Sign in" text
            Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
              child: Row(
                children: const [
                  Text(
                    "Sign in!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff000000),
                    ),
                  ),
                ],
              ),
            ),

            // Email Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextField(
                controller: emailController,
                focusNode: emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.black12,
                  prefixIcon: Icon(Icons.person, color: Color(0xff212435), size: 15),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => Utils.fieldFocusChange(
                  context, emailFocusNode, passwordFocusNode,
                ),
              ),
            ),

            // Password Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.black12,
                  prefixIcon: Icon(Icons.vpn_key, color: Color(0xff212435), size: 15),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: InputBorder.none,
                ),
              ),
            ),

            // Sign In Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: ElevatedButton(
                onPressed: _onSignInPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don’t have an account? '),
                GestureDetector(
                  onTap: () => _launchURLBrowser('mailto:trackdrive37@gmail.com'),
                  child: Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
