import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.chevron_left,
                        size: 28, color: AppColors.foreground),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Introduction',
                      'Welcome to Story Book Creator. We value your privacy and are committed to protecting your personal data. This privacy policy will inform you how we handle your data when you use our application.',
                    ),
                    _buildSection(
                      'Data We Collect',
                      'We collect information that you provide directly to us, such as your username, email address, and the stories you create. We also collect local database entries to ensure your work is saved correctly on your device.',
                    ),
                    _buildSection(
                      'How We Use Your Data',
                      'Your data is primarily used to provide and maintain the service, including saving your stories, syncing across devices (if enabled), and personalizing your experience.',
                    ),
                    _buildSection(
                      'Storage & Security',
                      'Your stories are stored locally on your device and, if synchronized, on our secure cloud servers. We implement industry-standard security measures to protect your information.',
                    ),
                    _buildSection(
                      'Your Rights',
                      'You have the right to access, update, or delete your personal information at any time through the app settings or by contacting us.',
                    ),
                    _buildSection(
                      'Changes to This Policy',
                      'We may update our privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'Last updated: May 2026',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.mutedForeground,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
