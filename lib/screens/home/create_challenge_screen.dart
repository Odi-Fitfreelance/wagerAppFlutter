import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_theme.dart';
import '../../services/challenge_service.dart';
import '../../services/api_client.dart';
import 'challenges_list_screen.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _selectedVideo;
  String _selectedType = 'fail_land'; // 'fail_land' or 'head_to_head'
  int _stakeAmount = 50;
  int _maxPlayers = 10;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        setState(() {
          _selectedVideo = video;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createChallenge() async {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a challenge title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_stakeAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stake amount must be greater than 0'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final challengeService = ChallengeService(ApiClient());

      final _ = await challengeService.createChallenge(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        challengeType: _selectedType,
        videoPath: _selectedVideo!.path,
        stakeAmount: _stakeAmount,
        maxPlayers: _maxPlayers,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to challenges list
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChallengesListScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error creating challenge';
        if (e.toString().contains('max_players')) {
          errorMessage = 'Max players must be between 2 and 20';
        } else if (e.toString().contains('stake_amount')) {
          errorMessage = 'Stake amount must be greater than 0';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage: $e'),
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
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('Create Challenge'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'View Challenges',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChallengesListScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video upload section
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.darkSlateGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedVideo != null
                        ? AppTheme.neonGreen
                        : AppTheme.neonBlue,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedVideo != null
                    ? Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 64,
                                  color: AppTheme.neonGreen,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Video selected',
                                  style: TextStyle(
                                    color: AppTheme.neonGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    _selectedVideo!.name,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.close, color: AppTheme.hotPink),
                              onPressed: () {
                                setState(() {
                                  _selectedVideo = null;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_rounded,
                            size: 64,
                            color: AppTheme.neonBlue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to record or upload video',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Challenge Title',
                hintText: 'e.g., Kickflip over 4 steps',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 20),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your challenge...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 28),

            // Stake amount
            Text(
              'Stake Amount (GC)',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: '$_stakeAmount',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.monetization_on,
                  color: AppTheme.neonGreen,
                ),
                suffixText: 'GC',
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed > 0) {
                  _stakeAmount = parsed;
                }
              },
            ),

            const SizedBox(height: 28),

            // Max players (optional - comment out if backend doesn't support yet)
            Text(
              'Max Participants: $_maxPlayers',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _maxPlayers.toDouble(),
              min: 2,
              max: 20,
              divisions: 18,
              label: '$_maxPlayers players',
              activeColor: AppTheme.neonGreen,
              inactiveColor: AppTheme.darkSlateGray,
              onChanged: (value) {
                setState(() {
                  _maxPlayers = value.round();
                });
              },
            ),

            const SizedBox(height: 32),

            // Challenge type
            Text(
              'Challenge Type',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    'FAIL / LAND',
                    Icons.sports_esports,
                    'fail_land',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeCard(
                    'Head-to-Head',
                    Icons.people_alt,
                    'head_to_head',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Create button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createChallenge,
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Icons.add_circle_outline),
                label: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'CREATE CHALLENGE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String title, IconData icon, String type) {
    final isSelected = _selectedType == type;
    final color = type == 'fail_land' ? AppTheme.hotPink : AppTheme.neonBlue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.darkSlateGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? color : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
