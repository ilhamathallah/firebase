import 'package:firebase/themes/shared.dart';
import 'package:firebase/ui/pages.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
      webProvider:
      ReCaptchaEnterpriseProvider('C652E33B-7AB1-4EA0-842B-E1FF16E12B8C'),
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.debug);
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showIntro = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _showIntro ? _buildIntroductionScreen() : SignInPage(),
      routes: {
        '/sign-in': (context) => SignInPage(),
        '/home': (context) => HomePage(),
        '/sign-up': (context) => SignUpPage(),
        '/note': (context) => NotePage(),
        '/profile': (context) => ProfilePage(),
        '/change-password': (context) => ChangePassword(),
        '/attendance': (context) => Attendance(),
        '/history': (context) => HistoryPage(),
        '/leave': (context) => LeavePage(),
        '/home-attendance': (context) => HomeAttendance(),
      },
    );
  }

  Widget _buildIntroductionScreen() {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Our App",
          body: "This is a good app to manage your attendance.",
          image: Center(child: Image.network("https://img.freepik.com/free-vector/signing-contract-official-document-agreement-deal-commitment-businessmen-cartoon-characters-shaking-hands-legal-contract-with-signature-concept-illustration_335657-2040.jpg?t=st=1741773420~exp=1741777020~hmac=d87bf9b08d5214e47a5985c946b2f30378e98dfe7868ee06c6a6aa96fc677fce&w=1060", height: 350)),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Attendance feature",
          body: "With facial recognition and permission to be absent from school",
          image: Center(child: Image.network("https://img.freepik.com/free-vector/appointment-booking-mobile-concept_23-2148570788.jpg?t=st=1741772951~exp=1741776551~hmac=87765c923cf57f0505bbc99853f4db9b99d0ff98716bce28b0d87d54754559a1&w=1060", height: 350)),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Let's Get Started",
          body: "Sign in now and start your journey!",
          image: Center(child: Image.network("https://img.freepik.com/premium-vector/people-manage-work-schedule-date-calendar-concept-flat-style-design-illustration_90661-1117.jpg?uid=R138124009&ga=GA1.1.661940043.1739158481&semt=ais_hybrid", height: 350)),
          decoration: _pageDecoration(),
        ),
      ],
      onDone: () {
        setState(() {
          _showIntro = false; // Beralih ke halaman Sign In setelah selesai
        });
      },
      globalBackgroundColor: Colors.white,
      showSkipButton: false,
      showBackButton: true,
      skip: const Text("Skip"),
      back: Icon(Icons.arrow_back_ios,),
      next: const Icon(Icons.arrow_forward_ios),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: const Size(22.0, 10.0),
        activeColor: Colors.blue,
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }

  PageDecoration _pageDecoration() {
    return PageDecoration(
      pageMargin: EdgeInsets.only(top: 50),
      pageColor: Colors.white,
      titleTextStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
      bodyTextStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.black54),
      bodyPadding: const EdgeInsets.all(5),
      imagePadding: const EdgeInsets.all(20),
    );
  }
}
