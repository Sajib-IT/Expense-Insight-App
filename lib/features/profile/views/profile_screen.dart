import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/shimmer_loading.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/features/profile/controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return ShimmerLoading.profile(context);
        }

        final user = controller.user.value;

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                  child: user?.avatar == null
                      ? Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                if (user?.isVerified == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      avatar: const Icon(Icons.verified, size: 16, color: Colors.green),
                      label: const Text('Verified', style: TextStyle(fontSize: 12)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                const SizedBox(height: 32),

                // Menu Items
                _menuItem(
                  context,
                  icon: Icons.person_outlined,
                  title: 'Edit Profile',
                  onTap: () => Get.toNamed(Routes.editProfile),
                ),
                _menuItem(
                  context,
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  onTap: () => Get.toNamed(Routes.categories),
                ),
                _menuItem(
                  context,
                  icon: Icons.lock_outlined,
                  title: 'Change Password',
                  onTap: () => Get.toNamed(Routes.changePassword),
                ),
                _menuItem(
                  context,
                  icon: Icons.document_scanner_outlined,
                  title: 'AI Extract',
                  subtitle: 'Scan receipt or describe expense',
                  onTap: () => Get.toNamed(Routes.aiExtract),
                ),
                const Divider(height: 32),
                _menuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.logout();
                            },
                            child: const Text('Logout', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}



