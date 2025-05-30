import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seblak_sulthane_app/core/constants/colors.dart';
import 'package:seblak_sulthane_app/core/extensions/build_context_ext.dart';
import 'package:seblak_sulthane_app/data/datasources/auth_local_datasource.dart';
import 'package:seblak_sulthane_app/presentation/auth/login_page.dart';
import 'package:seblak_sulthane_app/presentation/table/pages/table_page.dart';
import 'package:seblak_sulthane_app/presentation/report/pages/report_page.dart';
import 'package:seblak_sulthane_app/presentation/setting/pages/settings_page.dart';

import '../../../core/assets/assets.gen.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../bloc/online_checker/online_checker_bloc.dart';
import '../widgets/nav_item.dart';
import 'home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final bool _wasOffline = true; // Track if we were previously offline

  final List<Widget> _pages = [
    const HomePage(
      isTable: false,
    ),
    const TablePage(),
    const ReportPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    _selectedIndex = index;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) {
      final bool isOnline =
          connectivityResult.contains(ConnectivityResult.mobile) ||
              connectivityResult.contains(ConnectivityResult.wifi);

      // Update the UI status indicator
      context.read<OnlineCheckerBloc>().add(OnlineCheckerEvent.check(isOnline));
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: context.deviceHeight - 20.0,
                child: ColoredBox(
                  color: AppColors.primary,
                  child: ListView(
                    children: [
                      NavItem(
                        iconPath: Assets.icons.homeResto.path,
                        isActive: _selectedIndex == 0,
                        onTap: () => _onItemTapped(0),
                      ),
                      NavItem(
                        iconPath: Assets.icons.kelolaProduk.path,
                        isActive: _selectedIndex == 1,
                        onTap: () => _onItemTapped(1),
                      ),
                      NavItem(
                        iconPath: Assets.icons.dashboard.path,
                        isActive: _selectedIndex == 2,
                        onTap: () => _onItemTapped(2),
                      ),
                      NavItem(
                        iconPath: Assets.icons.setting.path,
                        isActive: _selectedIndex == 3,
                        onTap: () => _onItemTapped(3),
                      ),
                      BlocBuilder<OnlineCheckerBloc, OnlineCheckerState>(
                        builder: (context, state) {
                          return state.maybeWhen(
                            orElse: () => Container(
                              width: 40,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(
                                Icons.signal_wifi_off,
                                color: AppColors.white,
                              ),
                            ),
                            online: () {
                              // No sync here - it's handled in the connectivity listener
                              return Container(
                                width: 40,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Icon(
                                  Icons.wifi,
                                  color: AppColors.white,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      BlocListener<LogoutBloc, LogoutState>(
                        listener: (context, state) {
                          state.maybeMap(
                            orElse: () {},
                            error: (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.message),
                                  backgroundColor: AppColors.red,
                                ),
                              );
                            },
                            success: (value) {
                              AuthLocalDataSource().removeAuthData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logout success'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return const LoginPage();
                              }));
                            },
                          );
                        },
                        child: NavItem(
                          iconPath: Assets.icons.logout.path,
                          isActive: false,
                          onTap: () {
                            context
                                .read<LogoutBloc>()
                                .add(const LogoutEvent.logout());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
