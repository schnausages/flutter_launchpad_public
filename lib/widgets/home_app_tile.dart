import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/app.dart';
import 'package:flutter_launchpad/pages/app_detail_owner.dart';
import 'package:flutter_launchpad/pages/app_detail_visitor.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';

class HomeAppTile extends StatelessWidget {
  final AppModel app;
  final Size s;
  const HomeAppTile({super.key, required this.app, required this.s});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      // borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (app.appOwnerId == FirebaseAuth.instance.currentUser!.uid) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => AppDetailOwnerPage(app: app, ownsApp: true)));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => AppDetailVisitorPage(app: app)));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppStyles.panelColor,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppStyles.backgroundColor),
                  child: Icon(PlatformServices.appIcon(app.appCategory ?? ''),
                      color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: AppStyles.poppinsBold22.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
            if (app.seeking!.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: SizedBox(
                  width: 30,
                  height: 30,
                ),
              ),
            if (app.seeking!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(children: [
                  if (app.seeking!.contains('testers'))
                    Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Center(
                        child: Icon((Icons.troubleshoot_rounded),
                            size: 18, color: Colors.white),
                      ),
                    ),
                  SizedBox(width: 6),
                  if (app.seeking!.contains('feedback'))
                    Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Color(0xFFEC407A),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Center(
                        child: Icon((Icons.textsms_rounded),
                            size: 16, color: Colors.white),
                      ),
                    ),
                ]),
              )
          ],
        ),
      ),
    );
  }
}
