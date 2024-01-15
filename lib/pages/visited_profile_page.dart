import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/user.dart';
import 'package:flutter_launchpad/services/fs_services.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/inputs/base_app_bar.dart';
import 'package:flutter_launchpad/widgets/visited_profile_body.dart';

class VisitedProfilePage extends StatefulWidget {
  final String visitedUserId;
  const VisitedProfilePage({super.key, required this.visitedUserId});

  @override
  State<VisitedProfilePage> createState() => _VisitedProfilePageState();
}

class _VisitedProfilePageState extends State<VisitedProfilePage> {
  late Future<UserModel> _fetchUserFuture;

  @override
  void initState() {
    _fetchUserFuture = FirestoreServices.fetchUserInfo(widget.visitedUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: AppStyles.backgroundColor,
          appBar: PreferredSize(
              preferredSize: Size(double.infinity, 60),
              child: BaseAppBar(
                showSearch: true,
                showUser: false,
                showHome: true,
                isMobileWeb: PlatformServices.isWebMobile,
              )),
          body: FutureBuilder(
              future: _fetchUserFuture,
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return VisitedProfileBody(
                    userData: snapshot.data!,
                    isMobileWeb: PlatformServices.isWebMobile,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }))),
    );
  }
}
