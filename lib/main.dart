import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launchpad/pages/auth_page.dart';
import 'package:flutter_launchpad/pages/home_page.dart';
import 'package:flutter_launchpad/pages/landing_page.dart';
import 'package:flutter_launchpad/pages/user_profile.page.dart';
import 'package:flutter_launchpad/sec/keys.dart';
import 'package:flutter_launchpad/services/app_comments_service.dart';
import 'package:flutter_launchpad/services/auth_service.dart';
import 'package:flutter_launchpad/services/feed_servide.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const LaunchpadApp());
}

class LaunchpadApp extends StatelessWidget {
  const LaunchpadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthService(),
        ),
        ChangeNotifierProvider(create: (context) => FeedService()),
        ChangeNotifierProvider(create: (context) => AppCommentsService()),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Launchpad',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('ar'),
            Locale('de'),
            Locale('fr'),
            Locale('hi'),
            Locale('in'),
          ],
          home: auth.isAuth
              ? const HomePage()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppStyles.actionButtonColor),
                            )
                          : LandingPage()),
          // initialRoute: '/',
          routes: {
            // '/': (context) => LandingPage(),

            // When navigating to the "/" route, build the FirstScreen widget.

            // When navigating to the "/second" route, build the SecondScreen widget.
            '/auth': (context) => AuthenticationPage(
                  isWeb: !PlatformServices.isWebMobile,
                  isSignUp: true,
                  onAuthCancel: () {
                    Navigator.of(context).popUntil(ModalRoute.withName('/'));
                  },
                ),
            '/home': (context) => HomePage(),

            '/user_profile': (context) => UserProfilePage(),
          },
        ),
      ),
    );
  }
}

// class LoggedOutScreen extends StatefulWidget {
//   const LoggedOutScreen({super.key});

//   @override
//   State<LoggedOutScreen> createState() => _LoggedOutScreenState();
// }

// class _LoggedOutScreenState extends State<LoggedOutScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(padding: EdgeInsets.only(top: 20.0), child: LandingPage());
//   }
// }
