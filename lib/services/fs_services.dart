import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launchpad/models/app.dart';
import 'package:flutter_launchpad/models/post.dart';
import 'package:flutter_launchpad/models/tester.dart';
import 'package:flutter_launchpad/models/user.dart';
import 'package:flutter_launchpad/services/storage.dart';

class FirestoreServices {
  static Future addApplication(
      {required UserModel user, required AppModel application}) async {
    var _fs = FirebaseFirestore.instance;

    await _fs.collection('apps').add({
      'app_name': application.name,
      'app_description': application.description,
      'launchpad_app_id': application.launchpadAppId,
      'app_category': application.appCategory,
      'app_image_url': '',
      'seeking': application.seeking,
      'featured': false,
      'date_added': DateTime.now(),
      'app_store_link': application.appStoreLink,
      'play_store_link': application.playStoreLink,
      'ios_test_link': application.iosTestLink,
      'android_test_link': application.androidTestLink,
      'app_owner_id': user.userId,
      'app_owner_info': UserModel.toJson(user)
    });
    await increaseDevBits(userId: user.userId, bitAmount: 2);
  }

  static Future editApplication({required AppModel application}) async {
    var _fs = FirebaseFirestore.instance;

    QueryDocumentSnapshot<Map<String, dynamic>> _appDoc = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: application.launchpadAppId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);
    await _appDoc.reference.set({
      'app_name': application.name,
      'app_description': application.description,
      'app_category': application.appCategory,
      'app_image_url': '',
      'seeking': application.seeking,
      'featured': false,
      'app_store_link': application.appStoreLink,
      'play_store_link': application.playStoreLink,
      'ios_test_link': application.iosTestLink,
      'android_test_link': application.androidTestLink
    }, SetOptions(merge: true));
  }

  static Future<List<AppModel>> getAllApplications() async {
    List<AppModel> _apps = [];
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs.collection('apps').get();
    _query.docs.forEach((doc) {
      AppModel _a = AppModel.fromJson(doc.data());
      _apps.add(_a);
    });

    return _apps;
  }

  static Future<AppModel> getAppById({required String appId}) async {
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);
    AppModel _a = AppModel.fromJson(_query.data());
    return _a;
  }

  static Future<List<PostModel>> getCommentsOnApplication(
      {required String appId}) async {
    List<PostModel> _comments = [];
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get();
    var _comms = await _query.docs.first.reference
        .collection('comments')
        .get()
        .then((value) => value.docs);
    _comms.forEach((commDoc) {
      PostModel _c = PostModel.fromJson(commDoc.data(), commDoc.id);
      _comments.add(_c);
    });

    return _comments;
  }
  // add servic e for commenting on apps if feedback /comments. subcollection

  static Future<List<PostModel>> getAllPosts() async {
    List<PostModel> _apps = [];
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs.collection('posts').get();
    _query.docs.forEach((doc) {
      PostModel _a = PostModel.fromJson(doc.data(), doc.id);
      _apps.add(_a);
    });
    _apps.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return _apps;
  }

  static Future<DocumentReference<Map<String, dynamic>>> createPost({
    required UserModel user,
    required String text,
    AppModel? mentionedApp,
    String? link,
    required BuildContext ctx,
  }) async {
    var _fs = FirebaseFirestore.instance;
    var _mApp = mentionedApp != null
        ? {
            'app_name': mentionedApp.name,
            'launchpad_app_id': mentionedApp.launchpadAppId,
            'app_category': mentionedApp.appCategory
          }
        : null;

    DocumentReference<Map<String, dynamic>> _s =
        await _fs.collection('posts').add({
      'user_info': {
        'username': user.username,
        'id': user.userId,
        'email': user.email,
        'pfp_url': user.pfpUrl,
        'dev_bits': user.bitCount
      },
      'mentioned_app': _mApp,
      'reply_count': 0,
      'link': link ?? '',
      'id': user.userId,
      'text': text,
      'featured': false,
      'date_added': DateTime.now()
    });

    await increaseDevBits(userId: user.userId, bitAmount: 1);
    return _s;
  }

  static Future<void> replyToPost({
    required UserModel user,
    required String text,
    required String replyToPost,
  }) async {
    var _fs = FirebaseFirestore.instance;

    var _doc = await _fs.collection('posts').doc(replyToPost);
    await _doc.update({'reply_count': FieldValue.increment(1)});
    await _doc.collection('comments').add({
      'user_info': {
        'username': user.username,
        'id': user.userId,
        'email': user.email,
        'pfp_url': user.pfpUrl
      },
      'id': user.userId,
      'text': text,
      'date_added': DateTime.now()
    });
  }

  static Future<void> replyToAppComment(
      {required UserModel user,
      required String text,
      required String commentDocId,
      required String replyUnderAppId}) async {
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: replyUnderAppId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);
    await _query.reference.update({'reply_count': FieldValue.increment(1)});
    await _query.reference
        .collection('comments')
        .doc(commentDocId)
        .update({'reply_count': FieldValue.increment(1)});
    await _query.reference
        .collection('comments')
        .doc(commentDocId)
        .collection('comments')
        .add({
      'user_info': {
        'username': user.username,
        'id': user.userId,
        'email': user.email,
        'pfp_url': user.pfpUrl
      },
      'id': user.userId,
      'text': text,
      'date_added': DateTime.now()
    });
  }

  static Future<List<PostModel>> fetchCommentsToPost(
      {required String replyToPost}) async {
    List<PostModel> _comments = [];
    var _fs = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> _query = await _fs
        .collection('posts')
        .doc(replyToPost)
        .collection('comments')
        .get();
    _query.docs.forEach((commDoc) {
      PostModel _comm = PostModel.fromJson(commDoc.data(), replyToPost);
      _comments.add(_comm);
    });
    _comments.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    return _comments;
  }

  static Future<List<PostModel>> fetchRepliesToAppComment(
      {required String replyToPost, required String appId}) async {
    List<PostModel> _comments = [];
    var _fs = FirebaseFirestore.instance;
    DocumentReference<Map<String, dynamic>> _doc = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first.reference);
    var _query = await _doc
        .collection('comments')
        .doc(replyToPost)
        .collection('comments')
        .get();

    _query.docs.forEach((commDoc) {
      PostModel _comm = PostModel.fromJson(commDoc.data(), commDoc.id);
      _comments.add(_comm);
    });
    return _comments;
  }

  static Future<void> deletePost({required String docId}) async {
    var _fs = FirebaseFirestore.instance;
    DocumentReference<Map<String, dynamic>> _doc =
        _fs.collection('posts').doc(docId);
    var _comments = await _doc.collection('comments').get();
    _comments.docs.forEach((commDoc) async {
      await commDoc.reference.delete();
    });
    await _doc.delete();
  }

  static Future<void> deleteAppComment(
      {required String commentDocId, required String appId}) async {
    var _fs = FirebaseFirestore.instance;
    QueryDocumentSnapshot<Map<String, dynamic>> _appDoc = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);

    var _comment =
        await _appDoc.reference.collection('comments').doc(commentDocId).get();
    var _subComms = await _comment.reference
        .collection('comments')
        .get()
        .then((value) => value.docs);
    _subComms.forEach((element) {
      element.reference.delete();
    });
    await _comment.reference.delete();
  }

  static Future<void> deleteApp(
      {required String appId, required String userId}) async {
    var _fs = FirebaseFirestore.instance;
    QueryDocumentSnapshot<Map<String, dynamic>> _snap = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);
    if (userId == _snap.data()['app_owner_id']) {
      DocumentReference _ref = _snap.reference;
      try {
        var appComms = await _ref.collection('comments').get();
        appComms.docs.forEach((comm) async {
          var replies = await comm.reference.collection('comments').get();
          replies.docs.forEach((element) {
            element.reference.delete();
          });
          comm.reference.delete();
        });
      } catch (e) {}
      //delete coments and testers collection
      try {
        var testers = await _ref.collection('testers').get();
        testers.docs.forEach((element) {
          element.reference.delete();
        });
      } catch (e) {}
      _snap.reference.delete();
    }
  }

  static Future<List<AppModel>> getAppsForUser({required String userId}) async {
    var _fs = FirebaseFirestore.instance;
    List<AppModel> _apps = [];
    var _query = await _fs
        .collection('apps')
        .where('app_owner_id', isEqualTo: userId)
        .get();

    try {
      _query.docs.forEach((doc) {
        AppModel _a = AppModel.fromJson(doc.data());
        _apps.add(_a);
      });

      return _apps;
    } catch (e) {
      return [];
    }
  }

  static Future<DocumentReference<Map<String, dynamic>>> commentOnApp(
      {required UserModel user,
      required String text,
      required String replyToAppid}) async {
    var _fs = FirebaseFirestore.instance;
    var _appQuery = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: replyToAppid)
        .limit(1)
        .get()
        .then((value) => value.docs.first);

    var _doc = _appQuery.reference.collection('comments').add({
      'user_info': {
        'username': user.username,
        'id': user.userId,
        'email': user.email,
        'pfp_url': user.pfpUrl
      },
      'reply_count': 0,
      'id': user.userId,
      'text': text,
      'date_added': DateTime.now()
    });
    await increaseDevBits(userId: user.userId, bitAmount: 1);
    return _doc;
  }

  static Future<bool> updateUsername(String newUsername, String userId) async {
    var _fs = FirebaseFirestore.instance;
    var _q = await _fs
        .collection('users')
        .where('username', isEqualTo: newUsername)
        .limit(1)
        .get()
        .then((value) => value.docs);
    if (_q.isNotEmpty) {
      return false;
    } else {
      var _q = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: userId)
          .limit(1)
          .get()
          .then((value) => value.docs.first);
      await _q.reference.update({'username': newUsername});
      var _comms = await _fs
          .collectionGroup('comments')
          .where('id', isEqualTo: userId)
          .get();

      _comms.docs.forEach((comDoc) {
        comDoc.reference.update({'user_info.username': newUsername});
      });

      var _posts =
          await _fs.collection('posts').where('id', isEqualTo: userId).get();
      _posts.docs.forEach((postDoc) {
        postDoc.reference.update({'user_info.username': newUsername});
      });
      var _apps = await _fs
          .collection('apps')
          .where('app_owner_id', isEqualTo: userId)
          .get();
      _apps.docs.forEach((postDoc) {
        postDoc.reference.update({'app_owner_info.username': newUsername});
      });
      return true;
    }
  }

  static Future updatePfp(String newPfp, String userId) async {
    var _fs = FirebaseFirestore.instance;
    var _q = await _fs
        .collection('users')
        .where('id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);
    await AppStorage.updateStorageKey(key: 'pfp_url', newValue: newPfp);
    await _q.reference.update({'pfp_url': newPfp});
    var _comms = await _fs
        .collectionGroup('comments')
        .where('id', isEqualTo: userId)
        .get();
    _comms.docs.forEach((comDoc) {
      comDoc.reference.update({'user_info.pfp_url': newPfp});
    });
    var _posts =
        await _fs.collectionGroup('posts').where('id', isEqualTo: userId).get();
    _posts.docs.forEach((postDoc) {
      postDoc.reference.update({'user_info.pfp_url': newPfp});
    });
    var _apps = await _fs
        .collection('apps')
        .where('app_owner_id', isEqualTo: userId)
        .get();
    _apps.docs.forEach((postDoc) {
      postDoc.reference.update({'app_owner_info.pfp_url': newPfp});
    });
  }

  static Future<UserModel> fetchUserInfo(String userId) async {
    QueryDocumentSnapshot<Map<String, dynamic>> _queryDocSnap =
        await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: userId)
            .limit(1)
            .get()
            .then((value) => value.docs.first);
    UserModel _u = UserModel.fromJson(_queryDocSnap.data());
    return _u;
  }

  static Future<void> joinAppTesters(
      {required String appId,
      required UserModel userToJoin,
      required bool isAndroid}) async {
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);

    var exists = await _query.reference
        .collection('testers')
        .where('id', isEqualTo: userToJoin.userId)
        .limit(1)
        .get();
    if (exists.docs.isNotEmpty) {
      return;
    } else {
      await _query.reference.collection('testers').add({
        'id': userToJoin.userId,
        'username': userToJoin.username,
        'date_joined': DateTime.now(),
        'verified_tester': false,
        'android_tester': isAndroid,
        'email': userToJoin.email
      });
      await increaseDevBits(userId: userToJoin.userId, bitAmount: 2);
    }
  }

  static Future<List<TesterModel>> getAppTesters(
      {required String appId}) async {
    var _fs = FirebaseFirestore.instance;
    List<TesterModel> _testers = [];
    var _query = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);

    var _testerQuery = await _query.reference.collection('testers').get();
    _testerQuery.docs.forEach((doc) {
      TesterModel _c = TesterModel.fromJson(doc.data());
      _testers.add(_c);
    });
    return _testers;
  }

  static Future<bool> checkIfTester(
      {required String appId, required String userid}) async {
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);

    var _testerQuery = await _query.reference
        .collection('testers')
        .where('id', isEqualTo: userid)
        .limit(1)
        .get();
    if (_testerQuery.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static Future increaseDevBits(
      {required String userId, required int bitAmount}) async {
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs
        .collection('users')
        .where('id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);
    await _query.reference
        .update({'dev_bits': FieldValue.increment(bitAmount)});
  }

  static Future<bool> verifyTester(
      {required String appId, required String userIdToVerify}) async {
    var _fs = FirebaseFirestore.instance;
    var _query = await _fs
        .collection('apps')
        .where('launchpad_app_id', isEqualTo: appId)
        .limit(1)
        .get()
        .then((value) => value.docs.first);

    var _testerQuery = await _query.reference
        .collection('testers')
        .where('id', isEqualTo: userIdToVerify)
        .limit(1)
        .get();
    QueryDocumentSnapshot<Map<String, dynamic>> _doc = _testerQuery.docs.first;
    bool _isVerified = _doc.data()['verified_tester'] as bool;
    if (_isVerified) {
      return false;
    } else {
      _testerQuery.docs.first.reference.update({'verified_tester': true});
      await increaseDevBits(userId: userIdToVerify, bitAmount: 5);
      return true;
    }
  }

  static Future<bool> sendReport(
      {required String text,
      required UserModel user,
      required bool isProblem}) async {
    var _fs = FirebaseFirestore.instance;
    try {
      await _fs.collection('reports').add({
        'user_info': UserModel.toJson(user),
        'date_added': DateTime.now(),
        'is_issue': isProblem,
        'text': text
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
