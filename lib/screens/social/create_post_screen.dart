import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_theme.dart';
import '../../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  String _postType = 'general';
  String _visibility = 'public';
  bool _isLoading = false;
  List<XFile>? _selectedImages;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final postProvider = context.read<PostProvider>();

    // TODO: Upload media if selected
    List<String>? mediaUrls;
    if (_selectedImages != null && _selectedImages!.isNotEmpty) {
      // For now, we'll skip media upload
      // In production, upload images using PostService.uploadMedia()
    }

    final post = await postProvider.createPost(
      content: _contentController.text.trim(),
      type: _postType,
      visibility: _visibility,
      mediaUrls: mediaUrls,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (post != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (postProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        postProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.hotPink,
                    ),
                  )
                : const Text(
                    'POST',
                    style: TextStyle(
                      color: AppTheme.hotPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Content input
          TextField(
            controller: _contentController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(),
              filled: true,
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),

          const SizedBox(height: 20),

          // Post Type
          const Text(
            'Post Type',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('General'),
                selected: _postType == 'general',
                onSelected: (selected) {
                  if (selected) setState(() => _postType = 'general');
                },
                selectedColor: AppTheme.neonBlue,
              ),
              ChoiceChip(
                label: const Text('Bet Update'),
                selected: _postType == 'bet_update',
                onSelected: (selected) {
                  if (selected) setState(() => _postType = 'bet_update');
                },
                selectedColor: AppTheme.electricYellow,
              ),
              ChoiceChip(
                label: const Text('Bet Result'),
                selected: _postType == 'bet_result',
                onSelected: (selected) {
                  if (selected) setState(() => _postType = 'bet_result');
                },
                selectedColor: AppTheme.neonGreen,
              ),
              ChoiceChip(
                label: const Text('Achievement'),
                selected: _postType == 'achievement',
                onSelected: (selected) {
                  if (selected) setState(() => _postType = 'achievement');
                },
                selectedColor: AppTheme.richPurple,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Visibility
          const Text(
            'Visibility',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Public'),
                selected: _visibility == 'public',
                onSelected: (selected) {
                  if (selected) setState(() => _visibility = 'public');
                },
                selectedColor: AppTheme.hotPink,
              ),
              ChoiceChip(
                label: const Text('Followers'),
                selected: _visibility == 'followers',
                onSelected: (selected) {
                  if (selected) setState(() => _visibility = 'followers');
                },
                selectedColor: AppTheme.hotPink,
              ),
              ChoiceChip(
                label: const Text('Private'),
                selected: _visibility == 'private',
                onSelected: (selected) {
                  if (selected) setState(() => _visibility = 'private');
                },
                selectedColor: AppTheme.hotPink,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Add Media button
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Add Photos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.neonBlue,
              side: const BorderSide(color: AppTheme.neonBlue),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          if (_selectedImages != null && _selectedImages!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${_selectedImages!.length} image(s) selected',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
