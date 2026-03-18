import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Daftar halaman utama
  final List<Widget> _pages = [const HomeScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga agar 'state' halaman tidak reset saat pindah tab
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade100,
              width: 1,
            ), // Garis pembatas tipis elegan
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: AppColors.accentBlue.withOpacity(
              0.1,
            ), // Pill transparan biru
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(
                  color: AppColors.accentBlue,
                  size: 24,
                );
              }
              return IconThemeData(color: Colors.grey.shade400, size: 24);
            }),
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppStyles.caption.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: AppColors.accentBlue,
                  letterSpacing: 0.5,
                );
              }
              return AppStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: Colors.grey.shade400,
                letterSpacing: 0.5,
              );
            }),
          ),
          child: NavigationBar(
            height: 65, // Tinggi yang pas untuk jempol
            elevation: 0, // Hilangkan bayangan berat agar terlihat minimalis
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'BERANDA',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'PROFIL',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
