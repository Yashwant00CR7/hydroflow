import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserGreeting extends StatefulWidget {
  const UserGreeting({super.key});

  @override
  State<UserGreeting> createState() => _UserGreetingState();
}

class _UserGreetingState extends State<UserGreeting> {
  String _userName = "User";
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final name = userData?['name'] ?? "User";
          setState(() {
            _userName = name;
            _isLoadingUser = false;
          });
        } else {
          setState(() {
            _userName = user.displayName ?? "User";
            _isLoadingUser = false;
          });
        }
      } else {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1e3a8a).withAlpha(26),
            const Color(0xFF3b82f6).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1e3a8a).withAlpha(26),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withAlpha(204),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF1e3a8a).withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1e3a8a).withAlpha(77),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.waving_hand, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                _isLoadingUser
                    ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFFdc2626).withAlpha(204),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(
                              0xFF6b7280,
                            ).withAlpha(204),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(
                              0xFF6b7280,
                            ).withAlpha(204),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1e3a8a),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}