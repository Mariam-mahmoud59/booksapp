import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class EditProfileSheet extends StatefulWidget {
  final AuthProvider authProvider;
  final String currentName;

  const EditProfileSheet({
    super.key,
    required this.authProvider,
    required this.currentName,
  });

  static Future<void> show(BuildContext context, AuthProvider authProvider, String currentName) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditProfileSheet(
        authProvider: authProvider,
        currentName: currentName,
      ),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _newImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(
      text: widget.authProvider.profile?.bio ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 22,
              color: AppColors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          // Avatar picker
          Center(
            child: GestureDetector(
              onTap: () async {
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _newImagePath = image.path);
                }
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.border,
                      image: _newImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_newImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : (widget.authProvider.profile?.avatarUrl != null &&
                                  widget.authProvider.profile!.avatarUrl!
                                      .isNotEmpty)
                              ? DecorationImage(
                                  image: widget.authProvider.profile!.avatarUrl!
                                          .startsWith('http')
                                      ? NetworkImage(widget
                                          .authProvider.profile!.avatarUrl!) as ImageProvider
                                      : FileImage(File(widget
                                          .authProvider.profile!.avatarUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_newImagePath == null &&
                            (widget.authProvider.profile?.avatarUrl == null ||
                                widget.authProvider.profile!.avatarUrl!.isEmpty))
                        ? Icon(Icons.camera_alt,
                            color: AppColors.mutedForeground, size: 28)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: AppColors.mutedForeground),
              prefixIcon: Icon(Icons.person_outline, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 16),
          // Bio field
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell us a bit about yourself...',
              labelStyle: TextStyle(color: AppColors.mutedForeground),
              prefixIcon:
                  Icon(Icons.edit_note_outlined, color: AppColors.accent),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 28),
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await widget.authProvider.updateProfile(
                  username: _nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()
                      : widget.currentName,
                  avatarUrl: _newImagePath ?? widget.authProvider.profile?.avatarUrl,
                  bio: _bioController.text.trim(),
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
