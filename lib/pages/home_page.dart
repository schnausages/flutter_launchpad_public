import 'package:flutter/material.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/inputs/base_app_bar.dart';
import 'package:flutter_launchpad/widgets/home_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppStyles.backgroundColor,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 60),
            child: BaseAppBar(
              showSearch: true,
              showUser: true,
              isMobileWeb: PlatformServices.isWebMobile,
            )),
        body: HomeBody(),
      ),
    );
  }
}
