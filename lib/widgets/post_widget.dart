import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/app.dart';
import 'package:flutter_launchpad/models/post.dart';
import 'package:flutter_launchpad/pages/app_detail_visitor.dart';
import 'package:flutter_launchpad/pages/visited_profile_page.dart';
import 'package:flutter_launchpad/services/fs_services.dart';
import 'package:flutter_launchpad/services/platform_services.dart';
import 'package:flutter_launchpad/styles/app_styles.dart';
import 'package:flutter_launchpad/widgets/misc/base_snackbar.dart';
import 'package:flutter_launchpad/widgets/inputs/basic_button.dart';
import 'package:flutter_launchpad/widgets/misc/dev_bit.dart';
import 'package:url_launcher/url_launcher.dart';

class PostWidget extends StatefulWidget {
  final PostModel post;
  final bool appView;
  final String? appId;
  final Function onDeletePress;
  final bool isWeb;

  final Function onReplyPress;
  final Function(String) onSubReplyPress;

  final String currentUserId;

  const PostWidget(
      {super.key,
      required this.post,
      required this.isWeb,
      this.appView = false,
      this.appId,
      required this.onSubReplyPress,
      required this.onDeletePress,
      required this.onReplyPress,
      required this.currentUserId});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late Future<List<PostModel>> _fetchComments;
  ScrollController scrollController = ScrollController();
  bool _expanded = false;

  @override
  void initState() {
    _fetchComments = widget.appView
        ? Future.delayed(Duration(seconds: 1)).then((value) =>
            FirestoreServices.fetchRepliesToAppComment(
                replyToPost: widget.post.postId, appId: widget.appId!))
        : Future.delayed(Duration(seconds: 1)).then((value) =>
            FirestoreServices.fetchCommentsToPost(
                replyToPost: widget.post.postId));

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _s = MediaQuery.of(context).size;
    return Material(
      color: AppStyles.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            splashColor: AppStyles.backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            tileColor:
                _expanded ? AppStyles.panelColor : AppStyles.backgroundColor,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 40, horizontal: 8.0),
            leading: SizedBox(
              height: 100,
              width: 60,
              child: Wrap(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => VisitedProfilePage(
                                      visitedUserId:
                                          widget.post.userInfo!.userId)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                  image: PlatformServices.renderUserPfp(
                                      widget.post.userInfo?.pfpUrl ?? ''),
                                  fit: BoxFit.cover)),
                          height: 55,
                          width: 55,
                        ),
                      ),
                      if (widget.post.userInfo!.bitCount != null &&
                          widget.post.userInfo!.bitCount! > 0)
                        DevBit(bitCount: widget.post.userInfo!.bitCount!),
                    ],
                  ),
                ],
              ),
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.post.userInfo!.username,
                    style: AppStyles.poppinsBold22.copyWith(fontSize: 16)),
                // if (widget.post.userInfo!.bitCount! > 0)
                //   Padding(
                //     padding: const EdgeInsets.only(left: 8.0),
                //     child: DevBit(bitCount: widget.post.userInfo!.bitCount!),
                //   ),
                if (widget.post.mentionedApp!.launchpadAppId.isNotEmpty &&
                    widget.isWeb)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _MentionedAppTile(
                      app: widget.post.mentionedApp!,
                    ),
                  ),
                Spacer(),
                if (widget.post.userId == widget.currentUserId)
                  InkWell(
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                          BaseSnackbar.buildSnackBar(context,
                              message: 'Post deleted', success: false));
                      widget.onDeletePress();
                    },
                    child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red)),
                  ),
              ],
            ),
            subtitle: Row(
              children: [
                if (widget.post.externalink!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 6.0),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            builder: (context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 40, top: 20),
                                decoration: const BoxDecoration(
                                    color: AppStyles.backgroundColor,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('OPEN THIS LINK?',
                                            style: AppStyles.poppinsBold22),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12),
                                          child: BasicButton(
                                              isMobile:
                                                  PlatformServices.isWebMobile,
                                              onClick: () {
                                                //open
                                                Navigator.pop(context);
                                                launchUrl(Uri.parse(
                                                    widget.post.externalink!));
                                              },
                                              label: 'OPEN'),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          launchUrl(Uri.parse(
                                              widget.post.externalink!));
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .8,
                                          child: Text(
                                            widget.post.externalink!,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          // color: Color(0xFFC2ECFF),
                          color: AppStyles.panelColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child:
                            Icon(Icons.insert_link, color: Color(0xFF6EDBFF)),

                        // Icon(Icons.insert_link, color: Color(0xFF3E95FA)),
                      ),
                    ),
                  ),
                Flexible(
                  child: Text(widget.post.text,
                      softWrap: true,
                      style: const TextStyle(
                          color: Color(0xFFFEFFF4), fontSize: 16)),
                ),
              ],
            ),
            trailing: Padding(
              padding: EdgeInsets.only(right: _s.width > 800 ? 40 : 8),
              child: InkWell(
                onTap: () {
                  widget.onReplyPress();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppStyles.actionButtonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.reply_rounded,
                      color: AppStyles.iconColor),
                ),
              ),
            ),
          ),
          if (_expanded && widget.post.replyCount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: AppStyles.panelColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  width: widget.isWeb ? _s.width * .4 : _s.width * .8,
                  height: 220,
                  child: FutureBuilder(
                      future: _fetchComments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return RawScrollbar(
                            thumbColor: Colors.white70,
                            radius: const Radius.circular(3.0),
                            thickness: 10,
                            minThumbLength: 30,
                            controller: scrollController,
                            child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                controller: scrollController,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    tileColor: AppStyles.panelColor,
                                    title: Text(
                                        snapshot.data![i].userInfo!.username,
                                        style: AppStyles.poppinsBold22
                                            .copyWith(fontSize: 16)),
                                    subtitle: Text(snapshot.data![i].text,
                                        style: AppStyles.poppinsBold22
                                            .copyWith(fontSize: 14)),
                                    leading: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                              image: PlatformServices
                                                  .renderUserPfp(snapshot
                                                          .data![i]
                                                          .userInfo!
                                                          .pfpUrl ??
                                                      ''),
                                              fit: BoxFit.cover)),
                                    ),
                                    trailing: InkWell(
                                      onTap: () {
                                        widget.onSubReplyPress(snapshot
                                            .data![i].userInfo!.username);
                                      },
                                      child: Icon(Icons.reply_rounded,
                                          color: AppStyles.iconColor, size: 28),
                                    ),
                                  );
                                }),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppStyles.actionButtonColor),
                          );
                        }
                      }),
                ),
              ],
            )
        ],
      ),
    );
  }
}

class _MentionedAppTile extends StatelessWidget {
  final AppModel app;

  const _MentionedAppTile({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => AppDetailVisitorPage(
              app: AppModel(
                  name: app.name,
                  launchpadAppId: app.launchpadAppId,
                  appOwnerId: '',
                  appCategory: app.appCategory),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF5E35B1), Color(0xFF9C27B0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        child: Row(
          children: [
            Icon(PlatformServices.appIcon(app.appCategory ?? ''),
                size: 18, color: Colors.white),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(app.name,
                  style: AppStyles.poppinsBold22
                      .copyWith(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
