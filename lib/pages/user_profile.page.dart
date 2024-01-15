import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/user.dart';
import 'package:flutter_launchpad/services/fs_services.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/inputs/base_app_bar.dart';
import 'package:flutter_launchpad/widgets/user_profile_detail_body.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<UserModel> _fetchUserFuture;

  @override
  void initState() {
    _fetchUserFuture =
        FirestoreServices.fetchUserInfo(FirebaseAuth.instance.currentUser!.uid);
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
                  return UserProfileBody(
                    userData: snapshot.data!,
                    isMobileWeb: PlatformServices.isWebMobile ? true : false,
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
