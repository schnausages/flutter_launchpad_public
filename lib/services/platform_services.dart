import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformServices {
  static final bool isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  static const List<String> appCategories = [
    'Social Media',
    'Gaming',
    'Travel',
    'Entertainment',
    'Utility',
    'Communication',
    'Sports',
    'Finance',
    'Audio and Video',
    'Shopping',
    'Photography',
    'Health and Wellness'
  ];

  static const List<String> _pfps = [
    'gizmo.jpg',
    'lady01.jpg',
    'lady02.jpg',
    'lady03.jpg',
    'man01.jpg',
    'man02.jpeg',
    'man03.jpg',
    'monke.jpg',
    'nopfp.jpg',
    'samurai.jpg'
  ];

  static IconData appIcon(String c) {
    if (c == 'Social Media') {
      return Icons.alternate_email_rounded;
    }
    if (c == 'Gaming') {
      return Icons.gamepad_rounded;
    }
    if (c == 'Travel') {
      return Icons.airplane_ticket_rounded;
    }
    if (c == 'Entertainment') {
      return Icons.movie_filter_sharp;
    }
    if (c == 'Utility') {
      return Icons.construction;
    }
    if (c == 'Communication') {
      return Icons.send_rounded;
    }
    if (c == 'Sports') {
      return Icons.sports_football_rounded;
    }
    if (c == 'Finance') {
      return Icons.attach_money_rounded;
    }
    if (c == 'Audio and Video') {
      return Icons.video_chat;
    }
    if (c == 'Shopping') {
      return Icons.shopping_bag;
    }
    if (c == 'Photography') {
      return Icons.camera_alt;
    }
    if (c == 'Health and Wellness') {
      return Icons.monitor_heart_rounded;
    }
    return Icons.circle;
  }

  static ImageProvider renderUserPfp(String pfpUrl) {
    if (pfpUrl.isNotEmpty && _pfps.contains(pfpUrl)) {
      return AssetImage('assets/defaults/$pfpUrl');
    } else if (pfpUrl.isNotEmpty) {
      return NetworkImage(pfpUrl);
    } else {
      return const AssetImage('assets/defaults/nopfp.jpg');
    }
  }
}
