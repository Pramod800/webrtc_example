// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:mqtt_webrtc_example/core/pages/bottom_nav.dart' as _i1;
import 'package:mqtt_webrtc_example/screens/chat_detailpage.dart' as _i2;
import 'package:mqtt_webrtc_example/screens/chat_homepage.dart' as _i3;
import 'package:mqtt_webrtc_example/screens/profile_screen.dart' as _i4;

/// generated route for
/// [_i1.BottomNavigationScreen]
class BottomNavigationRoute extends _i5.PageRouteInfo<void> {
  const BottomNavigationRoute({List<_i5.PageRouteInfo>? children})
    : super(BottomNavigationRoute.name, initialChildren: children);

  static const String name = 'BottomNavigationRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.BottomNavigationScreen();
    },
  );
}

/// generated route for
/// [_i2.ChatDetailScreen]
class ChatDetailRoute extends _i5.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i6.Key? key,
    required String currentUserId,
    required String chatWithUserId,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(
           key: key,
           currentUserId: currentUserId,
           chatWithUserId: chatWithUserId,
         ),
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatDetailRouteArgs>();
      return _i2.ChatDetailScreen(
        key: args.key,
        currentUserId: args.currentUserId,
        chatWithUserId: args.chatWithUserId,
      );
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({
    this.key,
    required this.currentUserId,
    required this.chatWithUserId,
  });

  final _i6.Key? key;

  final String currentUserId;

  final String chatWithUserId;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{key: $key, currentUserId: $currentUserId, chatWithUserId: $chatWithUserId}';
  }
}

/// generated route for
/// [_i3.ChatHomeScreen]
class ChatHomeRoute extends _i5.PageRouteInfo<ChatHomeRouteArgs> {
  ChatHomeRoute({_i6.Key? key, List<_i5.PageRouteInfo>? children})
    : super(
        ChatHomeRoute.name,
        args: ChatHomeRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'ChatHomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatHomeRouteArgs>(
        orElse: () => const ChatHomeRouteArgs(),
      );
      return _i3.ChatHomeScreen(key: args.key);
    },
  );
}

class ChatHomeRouteArgs {
  const ChatHomeRouteArgs({this.key});

  final _i6.Key? key;

  @override
  String toString() {
    return 'ChatHomeRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.ProfileScreen]
class ProfileRoute extends _i5.PageRouteInfo<void> {
  const ProfileRoute({List<_i5.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.ProfileScreen();
    },
  );
}
