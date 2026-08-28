import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => appState.go(AppScreen.appSettings),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Balance the back button
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.white54, size: 60),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: WaziColors.bg, width: 2),
                              ),
                              child: Icon(Icons.camera_alt_rounded, color: WaziColors.bg, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Personal Information Block
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _ProfileRow(title: 'Full Name', value: 'JOHN DOE', canEdit: false),
                          _ProfileRow(title: 'Phone Number', value: '+234 801 234 5678', canEdit: false),
                          _ProfileRow(title: 'Email Address', value: 'johndoe@example.com', canEdit: true),
                          _ProfileRow(title: 'Date of Birth', value: '01/01/1990', canEdit: false, isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Verification Block
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _ProfileRow(
                            title: 'BVN', 
                            value: '223****8990', 
                            canEdit: false,
                            status: 'Verified',
                            statusColor: Colors.greenAccent,
                          ),
                          _ProfileRow(
                            title: 'NIN', 
                            value: '123****7890', 
                            canEdit: false,
                            status: 'Verified',
                            statusColor: Colors.greenAccent,
                          ),
                          _ProfileRow(
                            title: 'Residential Address', 
                            value: '123 Wazi Street, Lagos', 
                            canEdit: true, 
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.title,
    required this.value,
    this.canEdit = false,
    this.status,
    this.statusColor,
    this.isLast = false,
  });

  final String title;
  final String value;
  final bool canEdit;
  final String? status;
  final Color? statusColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: WaziText.inter(size: 14, color: Colors.white70),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor?.withValues(alpha: 0.2) ?? Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status!,
                      style: WaziText.inter(size: 10, weight: FontWeight.w600, color: statusColor ?? Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.edit_rounded, color: Colors.white.withValues(alpha: 0.3), size: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
