// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/app.dart';
import 'package:flutter_launchpad/models/post.dart';
import 'package:flutter_launchpad/models/user.dart';
import 'package:flutter_launchpad/services/app_comments_service.dart';
import 'package:flutter_launchpad/services/fs_services.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/services/storage.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/app_visit_header.dart';
import 'package:flutter_launchpad/widgets/inputs/base_app_bar.dart';
import 'package:flutter_launchpad/widgets/inputs/base_text_field.dart';
import 'package:flutter_launchpad/widgets/misc/base_snackbar.dart';
import 'package:flutter_launchpad/widgets/inputs/basic_button.dart';
import 'package:flutter_launchpad/widgets/post_widget.dart';
import 'package:flutter_launchpad/widgets/inputs/modal_sheet.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailVisitorPage extends StatefulWidget {
  final AppModel app;

  const AppDetailVisitorPage({super.key, required this.app});

  @override
  State<AppDetailVisitorPage> createState() => _AppDetailVisitorPageState();
}

class _AppDetailVisitorPageState extends State<AppDetailVisitorPage> {
  TextEditingController replyController = TextEditingController();
  late TextEditingController usernameController;
  final bool isWebMobile = PlatformServices.isWebMobile;
  // late Future<AppModel> _fetchApp;
  late Future _fetchComments;
  late Future<AppModel> _fetchAppInfo;

  late Future<bool> checkTesterStatus;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    // _fetchApp = FirestoreServices.getAppById(appId: widget.app.launchpadAppId);
    _fetchComments = Provider.of<AppCommentsService>(context, listen: false)
        .loadAppPosts(widget.app.launchpadAppId);
    _fetchAppInfo =
        FirestoreServices.getAppById(appId: widget.app.launchpadAppId);
    checkTesterStatus = FirestoreServices.checkIfTester(
        appId: widget.app.launchpadAppId, userid: currentUid);

    super.initState();
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _s = MediaQuery.of(context).size;
    final String appname = widget.app.name;
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
                onCloseAction: () {
                  Provider.of<AppCommentsService>(context, listen: false)
                      .clearFeed();
                },
                isMobileWeb: PlatformServices.isWebMobile,
              )),
          body: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                    future: _fetchAppInfo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Column(
                          children: [
                            AppDetailHeader(
                                app: snapshot.data!, isMobileWeb: isWebMobile),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (snapshot
                                      .data!.androidTestLink!.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: BasicButton(
                                          isMobile: isWebMobile,
                                          onClick: () {
                                            usernameController =
                                                TextEditingController();
                                            showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                isScrollControlled: true,
                                                builder: (context) => Container(
                                                      height: isWebMobile
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              1
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .4,
                                                      width: double.infinity,
                                                      decoration: const BoxDecoration(
                                                          color: AppStyles
                                                              .backgroundColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          12))),
                                                      child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      isWebMobile
                                                                          ? 20
                                                                          : 100),
                                                          child: FutureBuilder(
                                                              future:
                                                                  checkTesterStatus,
                                                              builder: (context,
                                                                  testSnap) {
                                                                if (testSnap.connectionState ==
                                                                        ConnectionState
                                                                            .done &&
                                                                    testSnap.data ==
                                                                        false) {
                                                                  return Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 20),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.red[400],
                                                                                      borderRadius: BorderRadius.circular(8),
                                                                                    ),
                                                                                    padding: const EdgeInsets.all(6),
                                                                                    child: const Icon(Icons.close, color: AppStyles.iconColor)),
                                                                              ),
                                                                              SizedBox(width: 10),
                                                                              Text('Join ${widget.app.name} Android testers', style: AppStyles.poppinsBold22.copyWith(fontSize: 20)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 10),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                'Email to use',
                                                                                style: AppStyles.poppinsBold22.copyWith(fontSize: 14),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                12,
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Flexible(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(right: 40),
                                                                                  child: BasicTextField.singleLine(
                                                                                      onSubmitted: (s) {
                                                                                        if (replyController.text.isNotEmpty) {}
                                                                                      },
                                                                                      autofocus: true,
                                                                                      controller: replyController),
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  String email = await AppStorage.returnStoredKeyValue(key: 'email');
                                                                                  //join tester and open relevant test link
                                                                                  setState(() {
                                                                                    replyController.text = email;
                                                                                  });
                                                                                },
                                                                                child: Icon(Icons.mail, color: AppStyles.iconColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        //username
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 10),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                'Username you\'ll use [ optional ]',
                                                                                style: AppStyles.poppinsBold22.copyWith(fontSize: 14),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                12,
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Flexible(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(right: 40),
                                                                                  child: BasicTextField.singleLine(onSubmitted: (s) {}, maxLength: 28, autofocus: true, controller: usernameController),
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  String usr = await AppStorage.returnStoredKeyValue(key: 'username');
                                                                                  //join tester and open relevant test link
                                                                                  setState(() {
                                                                                    usernameController.text = usr;
                                                                                  });
                                                                                },
                                                                                child: Icon(Icons.person, color: AppStyles.iconColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        BasicButton(
                                                                            isMobile:
                                                                                isWebMobile,
                                                                            onClick:
                                                                                () async {
                                                                              //join tester and open relevant test link
                                                                              await FirestoreServices.joinAppTesters(appId: widget.app.launchpadAppId, isAndroid: true, userToJoin: UserModel(email: replyController.text, username: usernameController.text, userId: currentUid));
                                                                              Navigator.of(context).pop();
                                                                              if (widget.app.androidTestLink!.isNotEmpty) {
                                                                                await launchUrl(Uri.parse(widget.app.androidTestLink!));
                                                                              }
                                                                            },
                                                                            label:
                                                                                'JOIN'),
                                                                      ]);
                                                                } else {
                                                                  return Text(
                                                                      "You're already a tester",
                                                                      style: AppStyles
                                                                          .poppinsBold22);
                                                                }
                                                              })),
                                                    )).then((value) {
                                              usernameController.clear();
                                              replyController.clear();
                                            });
                                          },
                                          label: 'Test Android'),
                                    ),
                                  if (snapshot.data!.iosTestLink!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: BasicButton(
                                          isMobile: isWebMobile,
                                          onClick: () {
                                            usernameController =
                                                TextEditingController();
                                            showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                isScrollControlled: true,
                                                builder: (context) => Container(
                                                      height: isWebMobile
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              1
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .4,
                                                      width: double.infinity,
                                                      decoration: const BoxDecoration(
                                                          color: AppStyles
                                                              .backgroundColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          12))),
                                                      child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      isWebMobile
                                                                          ? 20
                                                                          : 100),
                                                          child: FutureBuilder(
                                                              future:
                                                                  checkTesterStatus,
                                                              builder: (context,
                                                                  testSnap) {
                                                                if (testSnap.connectionState ==
                                                                        ConnectionState
                                                                            .done &&
                                                                    testSnap.data ==
                                                                        false) {
                                                                  return Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 20),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.red[400],
                                                                                      borderRadius: BorderRadius.circular(8),
                                                                                    ),
                                                                                    padding: const EdgeInsets.all(6),
                                                                                    child: const Icon(Icons.close, color: AppStyles.iconColor)),
                                                                              ),
                                                                              SizedBox(width: 10),
                                                                              Text('Join ${widget.app.name} iOS testers', style: AppStyles.poppinsBold22.copyWith(fontSize: 20)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 10),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                'Email to use',
                                                                                style: AppStyles.poppinsBold22.copyWith(fontSize: 14),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                12,
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Flexible(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(right: 40),
                                                                                  child: BasicTextField.singleLine(
                                                                                      onSubmitted: (s) {
                                                                                        if (replyController.text.isNotEmpty) {}
                                                                                      },
                                                                                      autofocus: true,
                                                                                      controller: replyController),
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  String email = await AppStorage.returnStoredKeyValue(key: 'email');
                                                                                  //join tester and open relevant test link
                                                                                  setState(() {
                                                                                    replyController.text = email;
                                                                                  });
                                                                                },
                                                                                child: Icon(Icons.mail, color: AppStyles.iconColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        //username
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 10),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                'Username you\'ll use [ optional ]',
                                                                                style: AppStyles.poppinsBold22.copyWith(fontSize: 14),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                12,
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Flexible(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(right: 40),
                                                                                  child: BasicTextField.singleLine(onSubmitted: (s) {}, maxLength: 28, autofocus: true, controller: usernameController),
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  String usr = await AppStorage.returnStoredKeyValue(key: 'username');
                                                                                  //join tester and open relevant test link
                                                                                  setState(() {
                                                                                    usernameController.text = usr;
                                                                                  });
                                                                                },
                                                                                child: Icon(Icons.person, color: AppStyles.iconColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        BasicButton(
                                                                            isMobile:
                                                                                isWebMobile,
                                                                            onClick:
                                                                                () async {
                                                                              //join tester and open relevant test link
                                                                              await FirestoreServices.joinAppTesters(appId: widget.app.launchpadAppId, isAndroid: false, userToJoin: UserModel(email: replyController.text, username: usernameController.text, userId: currentUid));
                                                                              Navigator.of(context).pop();
                                                                              if (widget.app.iosTestLink!.isNotEmpty) {
                                                                                await launchUrl(Uri.parse(widget.app.iosTestLink!));
                                                                              }
                                                                            },
                                                                            label:
                                                                                'JOIN'),
                                                                      ]);
                                                                } else {
                                                                  return Text(
                                                                      "You're already a tester",
                                                                      style: AppStyles
                                                                          .poppinsBold22);
                                                                }
                                                              })),
                                                    )).then((value) {
                                              usernameController.clear();
                                              replyController.clear();
                                            });
                                          },
                                          label: 'Test iOS'),
                                    )
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return SizedBox();
                      }
                    }),
                Padding(
                  padding: EdgeInsets.only(
                      top: 30, left: PlatformServices.isWebMobile ? 10 : 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Comments',
                              style: AppStyles.poppinsBold22
                                  .copyWith(fontSize: 20)),
                          SizedBox(width: 10),
                          BasicButton(
                              isMobile: isWebMobile,
                              onClick: () {
                                buildModalSheet(context,
                                    title: "Comment on $appname",
                                    controller: replyController,
                                    isCreatePost: false,
                                    onSubmitPress: (x, y) async {
                                  // add post
                                  Map<String, dynamic> _userProfile =
                                      await AppStorage.returnProfile();
                                  UserModel _u =
                                      UserModel.fromJson(_userProfile);
                                  DocumentReference<Map<String, dynamic>> _ref =
                                      await FirestoreServices.commentOnApp(
                                          text: replyController.text,
                                          user: _u,
                                          replyToAppid:
                                              widget.app.launchpadAppId);
                                  Navigator.of(context).pop();
                                  PostModel _p = PostModel(
                                      postId: _ref.id,
                                      text: replyController.text,
                                      userInfo: _u,
                                      mentionedApp: AppModel(
                                          name: '',
                                          launchpadAppId: '',
                                          appOwnerId: ''),
                                      userId: _u.userId,
                                      externalink: '',
                                      replyCount: 0,
                                      dateAdded: DateTime.now(),
                                      isFeatured: false);
                                  try {
                                    Provider.of<AppCommentsService>(context,
                                            listen: false)
                                        .addPost(_p);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        BaseSnackbar.buildSnackBar(context,
                                            message: 'Comment sent',
                                            success: true));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        BaseSnackbar.buildSnackBar(context,
                                            message: '${e.toString()}',
                                            success: false));
                                  }
                                });
                              },
                              label: 'COMMENT')
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Consumer<AppCommentsService>(
                            builder: (context, service, _) {
                              if (service.appPosts.isEmpty) {
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(
                                      color: AppStyles.panelColor,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text('No comments yet',
                                          style: AppStyles.poppinsBold22
                                              .copyWith(fontSize: 18))),
                                );
                              } else {
                                return ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(scrollbars: false),
                                  child: ListView.builder(
                                      itemCount: service.appPosts.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              left: PlatformServices.isWebMobile
                                                  ? 10
                                                  : 45,
                                              right:
                                                  PlatformServices.isWebMobile
                                                      ? 10
                                                      : 220),
                                          child: PostWidget(
                                              appView: true,
                                              appId: widget.app.launchpadAppId,
                                              currentUserId: currentUid,
                                              isWeb:
                                                  PlatformServices.isWebMobile
                                                      ? false
                                                      : true,
                                              post: service.appPosts[i],
                                              onDeletePress: () async {
                                                await FirestoreServices
                                                    .deleteAppComment(
                                                        commentDocId: service
                                                            .appPosts[i].postId,
                                                        appId: widget.app
                                                            .launchpadAppId);
                                                service.removePost(
                                                    service.appPosts[i]);
                                              },
                                              onSubReplyPress: (username) {
                                                buildModalSheet(context,
                                                    title:
                                                        "Reply to ${username}'s comment",
                                                    controller: replyController,
                                                    onSubmitPress:
                                                        (x, y) async {
                                                  // add post
                                                  Map<String, dynamic>
                                                      _userProfile =
                                                      await AppStorage
                                                          .returnProfile();
                                                  UserModel _u =
                                                      UserModel.fromJson(
                                                          _userProfile);
                                                  String _comment =
                                                      '@$username  ${replyController.text}';
                                                  try {
                                                    await FirestoreServices
                                                        .replyToAppComment(
                                                            user: _u,
                                                            text: _comment,
                                                            commentDocId:
                                                                service
                                                                    .appPosts[i]
                                                                    .postId,
                                                            replyUnderAppId: widget
                                                                .app
                                                                .launchpadAppId);
                                                  } catch (e) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(BaseSnackbar
                                                            .buildSnackBar(
                                                                context,
                                                                message:
                                                                    'Failed to send',
                                                                success:
                                                                    false));
                                                  }
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(BaseSnackbar
                                                          .buildSnackBar(
                                                              context,
                                                              message:
                                                                  'Reply sent',
                                                              success: true));
                                                });
                                              },
                                              onReplyPress: () {
                                                buildModalSheet(context,
                                                    title:
                                                        "Reply to ${service.appPosts[i].userInfo!.username}'s post",
                                                    controller: replyController,
                                                    onSubmitPress:
                                                        (x, y) async {
                                                  // add post
                                                  Map<String, dynamic>
                                                      _userProfile =
                                                      await AppStorage
                                                          .returnProfile();
                                                  UserModel _u =
                                                      UserModel.fromJson(
                                                          _userProfile);
                                                  await FirestoreServices
                                                      .replyToAppComment(
                                                          user: _u,
                                                          text: replyController
                                                              .text,
                                                          replyUnderAppId: widget
                                                              .app
                                                              .launchpadAppId,
                                                          commentDocId: service
                                                              .appPosts[i]
                                                              .postId);

                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(BaseSnackbar
                                                          .buildSnackBar(
                                                              context,
                                                              message:
                                                                  'Reply sent',
                                                              success: true));
                                                  // reply to post
                                                });
                                              }),
                                        );
                                      }),
                                );
                              }
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
