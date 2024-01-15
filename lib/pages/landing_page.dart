import 'package:flutter/material.dart';
import 'package:flutter_launchpad/pages/auth_page.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/misc/auth_status_box.dart';
import 'package:flutter_launchpad/widgets/inputs/base_app_bar.dart';
import 'package:flutter_launchpad/widgets/landing_body.dart';
import 'package:flutter_launchpad/widgets/misc/intro_tiny_tiles.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool intro = true;
  bool signUp = false;
  bool signIn = false;
  final bool isMobileWeb = PlatformServices.isWebMobile;

  @override
  Widget build(BuildContext context) {
    final Size _s = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppStyles.backgroundColor,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 60),
            child: BaseAppBar(
              showSearch: false,
              showUser: false,
              isMobileWeb: isMobileWeb,
            )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (intro)
                AuthAlertBox(
                  isMobileWeb: isMobileWeb,
                  signupTap: () {
                    setState(() {
                      intro = false;
                      signUp = true;
                    });
                  },
                  signinTap: () {
                    setState(() {
                      intro = false;
                      signIn = true;
                    });
                  },
                ),
              if (intro)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Row(
                    // spacing: isMobileWeb ? 8 : 30,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IntroTinyTile(
                          isMobileWeb: isMobileWeb,
                          w: isMobileWeb ? _s.width * .215 : _s.width * .17,
                          h: 100,
                          text: 'Add your app',
                          sheetMessage:
                              'Adding your app to Launchpad allows it to reach more people and lets users download it directly from the Play Store or App Store.',
                          displayyWidget: const Text('✅')),
                      IntroTinyTile(
                          isMobileWeb: isMobileWeb,
                          w: isMobileWeb ? _s.width * .215 : _s.width * .17,
                          h: 100,
                          text: 'Get testers',
                          sheetMessage:
                              'Finding testers is easy on Launchpad! Users can download from a link you provide or you can export a list of emails to invite testers.',
                          displayyWidget: const Text('🧪')),
                      IntroTinyTile(
                          isMobileWeb: isMobileWeb,
                          w: isMobileWeb ? _s.width * .215 : _s.width * .17,
                          h: 100,
                          text: 'Receive feedback',
                          sheetMessage:
                              'Each app on Launchpad includes a section where users can leave feedback whether it\'s already released or still in testing.',
                          displayyWidget: const Text('📲')),
                      IntroTinyTile(
                          isMobileWeb: isMobileWeb,
                          w: isMobileWeb ? _s.width * .215 : _s.width * .17,
                          h: 100,
                          text: 'Launch',
                          sheetMessage:
                              'Launch your app with confidence gained from reliable testing and user feedback you received!',
                          displayyWidget: const Text('🚀'))
                    ],
                  ),
                ),
              if (!intro)
                AuthenticationPage(
                  isSignUp: signUp,
                  isWeb: true,
                  onAuthCancel: () {
                    setState(() {
                      intro = true;
                    });
                  },
                ),
              if (intro)
                LayoutBuilder(builder: ((context, constraints) {
                  if (constraints.maxWidth < 850 || isMobileWeb) {
                    return MobileLandingBody(
                      onJoinTap: () {
                        setState(() {
                          intro = false;
                          signUp = true;
                        });
                      },
                    );
                  } else {
                    return DesktopHomeBody(
                      onJoinTap: () {
                        setState(() {
                          intro = false;
                          signUp = true;
                        });
                      },
                    );
                  }
                })),
              Padding(
                padding: EdgeInsets.only(top: intro ? 60.0 : 340, bottom: 15),
                child: InkWell(
                  onTap: () {
                    launchUrl(
                        Uri.parse('https://www.buymeacoffee.com/thenormal'));
                  },
                  child: Image.network(
                      'https://helloimjessa.files.wordpress.com/2021/06/bmc-button.png',
                      width: 200,
                      fit: BoxFit.contain),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
