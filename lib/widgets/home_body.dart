// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/app.dart';
import 'package:flutter_launchpad/models/post.dart';
import 'package:flutter_launchpad/models/user.dart';
import 'package:flutter_launchpad/pages/add_app_page.dart';
import 'package:flutter_launchpad/services/feed_servide.dart';
import 'package:flutter_launchpad/services/fs_services.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/services/storage.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/misc/base_snackbar.dart';
import 'package:flutter_launchpad/widgets/inputs/basic_button.dart';
import 'package:flutter_launchpad/widgets/home_app_tile.dart';
import 'package:flutter_launchpad/widgets/post_widget.dart';
import 'package:flutter_launchpad/widgets/inputs/modal_sheet.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  TextEditingController replyController = TextEditingController();
  late Future<List<AppModel>> _fetchApps;
  late Future _fetchPosts;

  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    _fetchApps = FirestoreServices.getAllApplications();
    // _fetchPosts = FirestoreServices.getAllPosts();
    _fetchPosts =
        Provider.of<FeedService>(context, listen: false).loadHomePosts();

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
    // var cart = context.watch<FeedService>();
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 30, bottom: 15),
                child: Row(
                  children: [
                    Text('Apps', style: AppStyles.poppinsBold22),
                    SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: BasicButton(
                          isMobile: PlatformServices.isWebMobile,
                          onClick: () async {
                            UserModel _profData =
                                await FirestoreServices.fetchUserInfo(
                                    currentUid);
                            AppModel _newApp = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (ctx) =>
                                        AddApplicationPage(user: _profData)));
                            if (!mounted) return;
                            if (_newApp.launchpadAppId.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  BaseSnackbar.buildSnackBar(context,
                                      message: 'Application added',
                                      success: true));
                              _fetchApps =
                                  FirestoreServices.getAllApplications();
                              setState(() {});
                            }
                          },
                          label: 'NEW APP'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 15),
                child: SizedBox(
                  width: _s.width,
                  height: 190,
                  child: FutureBuilder(
                      future: _fetchApps,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return GridView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 1 / 2.5,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 8,
                                      crossAxisCount: 2),
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, i) {
                                return HomeAppTile(
                                  app: snapshot.data![i],
                                  s: _s,
                                );
                              });
                        } else {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: AppStyles.actionButtonColor,
                          ));
                        }
                      }),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 25),
                child: Row(
                  children: [
                    Text('Posts', style: AppStyles.poppinsBold22),
                    SizedBox(width: 10),
                    BasicButton(
                        isMobile: PlatformServices.isWebMobile,
                        onClick: () {
                          buildModalSheet(context,
                              title: "Create a new post!",
                              controller: replyController,
                              isCreatePost: true,
                              onSubmitPress: (link, app) async {
                            // add post
                            Map<String, dynamic> _userProfile =
                                await AppStorage.returnProfile();
                            UserModel _u = UserModel.fromJson(_userProfile);
                            dynamic _mApp =
                                app.launchpadAppId.isEmpty ? null : app;
                            DocumentReference<Map<String, dynamic>> _docRef =
                                await FirestoreServices.createPost(
                                    user: _u,
                                    link: link,
                                    mentionedApp: _mApp,
                                    text: replyController.text,
                                    ctx: context);
                            Navigator.pop(context);
                            PostModel _p = PostModel(
                                postId: _docRef.id,
                                text: replyController.text,
                                userInfo: _u,
                                mentionedApp: _mApp != null
                                    ? AppModel(
                                        name: _mApp.name,
                                        launchpadAppId: _mApp.launchpadAppId,
                                        appOwnerId: _u.userId,
                                        appCategory: _mApp.appCategory)
                                    : AppModel(
                                        name: '',
                                        launchpadAppId: '',
                                        appOwnerId: ''),
                                userId: _u.userId,
                                externalink: link,
                                replyCount: 0,
                                dateAdded: DateTime.now(),
                                isFeatured: false);

                            try {
                              Provider.of<FeedService>(context, listen: false)
                                  .addPost(_p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  BaseSnackbar.buildSnackBar(context,
                                      message: 'Post created!', success: true));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  BaseSnackbar.buildSnackBar(context,
                                      message: '${e.toString()}',
                                      success: false));
                            }
                          });
                        },
                        label: 'NEW POST')
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Consumer<FeedService>(
                    builder: (context, service, _) {
                      if (service.feedPosts.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: AppStyles.actionButtonColor,
                        ));
                      } else {
                        return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView.builder(
                              itemCount: service.feedPosts.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: PlatformServices.isWebMobile
                                          ? 10
                                          : 45,
                                      right: PlatformServices.isWebMobile
                                          ? 10
                                          : 220),
                                  child: PostWidget(
                                      currentUserId: currentUid,
                                      isWeb: PlatformServices.isWebMobile
                                          ? false
                                          : true,
                                      post: service.feedPosts[i],
                                      onDeletePress: () async {
                                        await FirestoreServices.deletePost(
                                            docId: service.feedPosts[i].postId);
                                        service
                                            .removePost(service.feedPosts[i]);
                                      },
                                      onSubReplyPress: (username) {
                                        buildModalSheet(context,
                                            title:
                                                "Reply to ${username}'s comment",
                                            controller: replyController,
                                            onSubmitPress: (x, y) async {
                                          // add post
                                          Map<String, dynamic> _userProfile =
                                              await AppStorage.returnProfile();
                                          UserModel _u =
                                              UserModel.fromJson(_userProfile);
                                          String _comment =
                                              '@$username  ${replyController.text}';
                                          await FirestoreServices.replyToPost(
                                              user: _u,
                                              text: _comment,
                                              replyToPost:
                                                  service.feedPosts[i].postId);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      onReplyPress: () {
                                        buildModalSheet(context,
                                            title:
                                                "Reply to ${service.feedPosts[i].userInfo!.username}'s post",
                                            controller: replyController,
                                            onSubmitPress: (x, y) async {
                                          // add post
                                          Map<String, dynamic> _userProfile =
                                              await AppStorage.returnProfile();
                                          UserModel _u =
                                              UserModel.fromJson(_userProfile);
                                          await FirestoreServices.replyToPost(
                                              user: _u,
                                              text: replyController.text,
                                              replyToPost:
                                                  service.feedPosts[i].postId);
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  BaseSnackbar.buildSnackBar(
                                                      context,
                                                      message: 'Reply sent',
                                                      success: true));
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
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
