import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mqtt_webrtc_example/core/componsnts/app_colors.dart';
import 'package:mqtt_webrtc_example/core/componsnts/custom_textstyle.dart';
import 'package:mqtt_webrtc_example/core/router/router.gr.dart';

@RoutePage()
class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [ChatHomeRoute(), const ProfileRoute()],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          floatingActionButton: FloatingActionButton.extended(
            shape: const CircleBorder(side: BorderSide(color: Colors.white)),
            onPressed: () {},
            backgroundColor: AppColors.primaryColor,
            label: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: SizedBox(
            child: SafeArea(
              bottom: false,
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedFontSize: 12,
                unselectedFontSize: 11,
                selectedItemColor: AppColors.black,
                unselectedItemColor: AppColors.grey,
                unselectedLabelStyle: getCustomTextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                  height: 14,
                  fontWeight: FontWeight.w400,
                ),
                selectedLabelStyle: getCustomTextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  height: 14,
                  fontWeight: FontWeight.w500,
                ),
                type: BottomNavigationBarType.fixed,
                currentIndex: tabsRouter.activeIndex,
                onTap: (index) {
                  if (tabsRouter.activeIndex == index) {
                    tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
                  } else {
                    tabsRouter.setActiveIndex(index);
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    label: '',
                    icon: SizedBox(
                      child: _buildNavItem(
                        icon: 'assets/svg/Home.svg',
                        label: 'Home',
                        isSelected: tabsRouter.activeIndex == 0,
                        onTap: () => tabsRouter.setActiveIndex(0),
                      ),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: SizedBox(
                      child: _buildNavItem(
                        icon: 'assets/svg/User.svg',
                        label: 'Profile',
                        isSelected: tabsRouter.activeIndex == 1,
                        onTap: () => tabsRouter.setActiveIndex(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 2),
          SvgPicture.asset(icon,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.black : AppColors.grey,
                BlendMode.srcIn,
              )),
          const SizedBox(height: 4),
          Text(
            label,
            style: getCustomTextStyle(
              fontSize: isSelected ? 12 : 11,
              color: isSelected ? AppColors.black : AppColors.grey,
              height: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
