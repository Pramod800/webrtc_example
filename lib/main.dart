import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mqtt_webrtc_example/core/componsnts/app_theme.dart';
import 'package:mqtt_webrtc_example/core/router/router.dart';
import 'package:mqtt_webrtc_example/core/router/router.gr.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('chat_messages');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.config(
            navigatorObservers: () => [],
            deepLinkBuilder: (deepLink) {
              final route = ChatHomeRoute();

              return DeepLink(route.flattened);
            }),
        theme: getApplicationTheme());
  }
}
