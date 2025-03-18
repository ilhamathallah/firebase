part of '../pages.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isObscureText = true;
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseService firebaseService = FirebaseService();

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email and password cannot be empty',
          ),
        ),
      );
    } else {
      final user = await firebaseService.signIn(email, password);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email and password cannot be empty',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.asset(
                        'assets/images/check-circle_6997701.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // text welcome
                    Text(
                      welcomeBackTextLogin,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    // text sub
                    Text(
                      subWelcomeTextLogin,
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 35),
                    // email
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: hintEmail,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // password
                    TextField(
                      controller: passwordController,
                      obscureText: isObscureText ? true : false,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: hintPassword,
                        suffixIcon: IconButton(
                          icon: Icon(isObscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () {
                            setState(() {
                              isObscureText = !isObscureText;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // forgot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            print(hintForgotPassword);
                          },
                          child: Text(
                            'Forgot password?',
                            style: subWelcomeTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // button
                    SizedBox(
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                _login();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(hintLogin),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // or text
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child:
                              Text('or', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                image: DecorationImage(
                                  image: AssetImage(imageGoogle),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                image: DecorationImage(
                                  image: AssetImage(imageFacebook),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hintDoesntHaveAccount,
                    style: subWelcomeTextStyle,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/sign-up');
                    },
                    child: Text(
                      hintRegister,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
