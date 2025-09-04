import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';
import '../main.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.darkNeutral100, AppColors.darkNeutral50],
                )
                : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(230),
                    Colors.white.withAlpha(217),
                  ],
                ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withAlpha(60)
                    : Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkNeutral100.withAlpha(180)
                    : Colors.white.withAlpha(230),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkNeutral300.withAlpha(77)
                    : Colors.white.withAlpha(77),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBackButton)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient:
                        Theme.of(context).brightness == Brightness.dark
                            ? LinearGradient(
                              colors: [
                                AppColors.darkNeutral300.withAlpha(26),
                                AppColors.darkNeutral100.withAlpha(13),
                              ],
                            )
                            : LinearGradient(
                              colors: [
                                const Color(0xFF1e3a8a).withAlpha(26),
                                const Color(0xFF3b82f6).withAlpha(13),
                              ],
                            ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkNeutral100.withAlpha(51)
                              : const Color(0xFF1e3a8a).withAlpha(51),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkNeutral200
                            : Color(0xFF1e3a8a),
                    size: 18,
                  ),
                ),
              ),
            if (showBackButton) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
                        ).createShader(bounds),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkNeutral200
                                : Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkNeutral400
                              : const Color(0xFF6b7280).withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Theme toggle
                GestureDetector(
                  onTap: () => ThemeController.toggle(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkNeutral200
                              : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.brightness_6,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.techGreen
                              : const Color(0xFF1e3a8a),
                      size: 20,
                    ),
                  ),
                ),
                // Sign out
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient:
                          Theme.of(context).brightness == Brightness.dark
                              ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.error.withAlpha(26),
                                  AppColors.darkNeutral200.withAlpha(38),
                                ],
                              )
                              : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFdc2626).withAlpha(26),
                                  const Color(0xFFb91c1c).withAlpha(38),
                                ],
                              ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.error.withAlpha(51)
                                  : const Color(0xFFdc2626).withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.error
                                : const Color(0xFFdc2626),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.error
                              : const Color(0xFFdc2626),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
