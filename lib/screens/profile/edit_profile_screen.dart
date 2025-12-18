import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _handicapController = TextEditingController();
  final _favoriteCourseController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _bioController.text = user.bio ?? '';
      _handicapController.text = user.handicap?.toString() ?? '';
      _favoriteCourseController.text = user.favoriteCourse ?? '';
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _handicapController.dispose();
    _favoriteCourseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploadingImage = true);

      try {
        final userService = UserService(ApiClient());
        final imageUrl = await userService.uploadProfileImage(image.path);

        if (mounted) {
          final authProvider = context.read<AuthProvider>();
          final updatedUser = authProvider.user!.copyWith(
            profileImageUrl: imageUrl,
          );
          await authProvider.updateUser(updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingImage = false);
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userService = UserService(ApiClient());
      final updatedUser = await userService.updateProfile(
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        handicap: _handicapController.text.trim().isNotEmpty
            ? double.parse(_handicapController.text.trim())
            : null,
        favoriteCourse: _favoriteCourseController.text.trim().isNotEmpty
            ? _favoriteCourseController.text.trim()
            : null,
      );

      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.hotPink,
                      backgroundImage: user?.profileImageUrl != null
                          ? NetworkImage(user!.profileImageUrl!)
                          : null,
                      child: user?.profileImageUrl == null
                          ? Text(
                              user?.username.substring(0, 2).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.neonBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              AppTheme.neonGlow(AppTheme.neonBlue),
                            ],
                          ),
                          child: _isUploadingImage
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself...',
                  prefixIcon: Icon(Icons.edit_note, color: AppTheme.neonBlue),
                ),
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return 'Bio must be 200 characters or less';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Handicap
              TextFormField(
                controller: _handicapController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Handicap',
                  hintText: '12.5',
                  prefixIcon: Icon(Icons.golf_course, color: AppTheme.neonBlue),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final handicap = double.tryParse(value);
                    if (handicap == null) {
                      return 'Please enter a valid handicap';
                    }
                    if (handicap < 0 || handicap > 54) {
                      return 'Handicap must be between 0 and 54';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Favorite Course
              TextFormField(
                controller: _favoriteCourseController,
                decoration: const InputDecoration(
                  labelText: 'Favorite Course',
                  hintText: 'Pebble Beach',
                  prefixIcon: Icon(Icons.landscape, color: AppTheme.neonBlue),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
