import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: Text('Create Challenge'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video upload section
            GestureDetector(
              onTap: () {
                // TODO: Pick video from gallery
              },
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.darkSlateGray,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.neonBlue,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_rounded,
                      size: 64,
                      color: AppTheme.neonBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tap to record or upload',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Challenge title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Challenge Title',
                hintText: 'e.g., Kickflip over 4 steps',
              ),
            ),

            SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your challenge...',
              ),
            ),

            SizedBox(height: 24),

            // Challenge type selector
            Text(
              'Challenge Type',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard('FAIL / LAND', Icons.sports),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTypeCard('Head-to-Head', Icons.people),
                ),
              ],
            ),

            SizedBox(height: 32),

            // Create button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Create challenge
                },
                child: Text(
                  'CREATE CHALLENGE',
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
    );
  }

  Widget _buildTypeCard(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.neonBlue, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
