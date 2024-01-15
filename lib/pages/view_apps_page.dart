import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/app.dart';
import 'package:flutter_launchpad/services/fs_services.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/misc/base_snackbar.dart';

class ViewAppsPage extends StatefulWidget {
  final bool isMobileWeb;
  const ViewAppsPage({super.key, required this.isMobileWeb});

  @override
  State<ViewAppsPage> createState() => _ViewAppsPageState();
}

class _ViewAppsPageState extends State<ViewAppsPage> {
  late Future<List<AppModel>> _fetchApps;

  @override
  void initState() {
    _fetchApps = FirestoreServices.getAllApplications();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: AppStyles.backgroundColor,
          appBar: AppBar(
              elevation: 0,
              backgroundColor: AppStyles.backgroundColor,
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child:
                          const Icon(Icons.close, color: AppStyles.iconColor)),
                ),
              ),
              title: !PlatformServices.isWebMobile
                  ? Text('Flutter  < 🚀 >  Launchpad',
                      style: AppStyles.poppinsBold22.copyWith(fontSize: 26))
                  : Text(' 🚀   Launchpad',
                      style: AppStyles.poppinsBold22.copyWith(fontSize: 20))),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 30, horizontal: widget.isMobileWeb ? 10 : 90),
                  child: Row(
                    children: [
                      Text('Apps',
                          style:
                              AppStyles.poppinsBold22.copyWith(fontSize: 26)),
                    ],
                  ),
                ),
                FutureBuilder(
                    future: _fetchApps,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: PlatformServices.isWebMobile
                                        ? 10
                                        : 120),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 45, horizontal: 24),
                                  tileColor: AppStyles.panelColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        BaseSnackbar.buildSnackBar(context,
                                            message: 'Join Launchpad to view',
                                            success: false));
                                  },
                                  title: Text(snapshot.data![i].name,
                                      style: AppStyles.poppinsBold22),
                                  subtitle: Text(
                                      snapshot.data![i].appOwnerInfo!.username,
                                      style: AppStyles.poppinsBold22.copyWith(
                                          fontSize: 14,
                                          color: Color(0xFFCECECE))),
                                  leading: Container(
                                    width: 65,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppStyles.backgroundColor),
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                        PlatformServices.appIcon(
                                            snapshot.data![i].appCategory ??
                                                ''),
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            });
                      } else {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: AppStyles.actionButtonColor,
                        ));
                      }
                    }),
              ],
            ),
          )),
    );
  }
}
