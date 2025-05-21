import 'package:auto_route/auto_route.dart';
import 'package:mqtt_webrtc_example/core/router/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      page: BottomNavigationRoute.page,
      path: '/bottomNavigation',
      children: [
        AutoRoute(page: ChatHomeRoute.page, initial: true, path: ''),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
      ],
    ),
    AutoRoute(page: ChatDetailRoute.page, path: '/chatDetail'),
  ];
}
