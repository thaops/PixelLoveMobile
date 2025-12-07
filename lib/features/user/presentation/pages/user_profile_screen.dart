import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pixel_love/features/user/presentation/controllers/user_controller.dart';

class UserProfileScreen extends GetView<UserController> {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading && controller.currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.currentUser;

        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchProfile,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.avatar != null
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null
                      ? Text(
                          user.name?.isNotEmpty == true
                              ? user.name![0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 40),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mode: ${user.mode}',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.email,
                        label: 'Email',
                        value: user.email ?? 'Not set',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: user.phone ?? 'Not set',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.monetization_on,
                        label: 'Coins',
                        value: user.coins.toString(),
                      ),
                      if (user.coupleRoomId != null) ...[
                        const Divider(height: 1),
                        _buildInfoTile(
                          icon: Icons.favorite,
                          label: 'Couple Room',
                          value: user.coupleRoomId!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final authController = Get.find<AuthController>();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: controller.currentUser?.name,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.updateProfile(name: nameController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
