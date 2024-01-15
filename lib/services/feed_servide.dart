import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/post.dart';
import 'package:flutter_launchpad/services/fs_services.dart';

class FeedService with ChangeNotifier {
  List<PostModel> _homeFeedPosts = [];
  List<PostModel> get feedPosts => _homeFeedPosts;

  loadHomePosts() async {
    _homeFeedPosts = await FirestoreServices.getAllPosts();
    notifyListeners();
  }

  // FirestoreServices.getCommentsOnApplication(
  //       appId: widget.app.launchpadAppId)
  loadAppPosts(String appId) async {
    _homeFeedPosts =
        await FirestoreServices.getCommentsOnApplication(appId: appId);
    notifyListeners();
  }

  addPost(PostModel post) {
    _homeFeedPosts.add(post);
    _homeFeedPosts.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    notifyListeners();
  }

  removePost(PostModel post) {
    _homeFeedPosts.remove(post);
    notifyListeners();
  }

  clearFeed() {
    _homeFeedPosts.clear();
    notifyListeners();
  }
}
