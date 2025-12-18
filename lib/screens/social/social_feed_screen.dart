import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/post_provider.dart';
import '../../models/post.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import '../leaderboard/leaderboard_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Social Feed',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: AppTheme.neonBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppTheme.neonBlue),
            color: AppTheme.darkSlateGray,
            onSelected: (filter) {
              setState(() => _selectedFilter = filter);
              context.read<PostProvider>().loadFeed(filter: filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Posts'),
              ),
              const PopupMenuItem(
                value: 'general',
                child: Text('General'),
              ),
              const PopupMenuItem(
                value: 'bet_update',
                child: Text('Bet Updates'),
              ),
              const PopupMenuItem(
                value: 'bet_result',
                child: Text('Bet Results'),
              ),
              const PopupMenuItem(
                value: 'achievement',
                child: Text('Achievements'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.hotPink),
            );
          }

          if (postProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.hotPink),
                  const SizedBox(height: 16),
                  Text(
                    postProvider.errorMessage!,
                    style: const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      postProvider.loadFeed(filter: _selectedFilter);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final posts = postProvider.feed;

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feed_outlined,
                    size: 64,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePostScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Post'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => postProvider.loadFeed(filter: _selectedFilter),
            color: AppTheme.hotPink,
            backgroundColor: AppTheme.darkSlateGray,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(post: posts[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.hotPink,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  String _getPostTypeLabel(PostType type) {
    switch (type) {
      case PostType.general:
        return 'General';
      case PostType.betUpdate:
        return 'Bet Update';
      case PostType.betResult:
        return 'Bet Result';
      case PostType.achievement:
        return 'Achievement';
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.general:
        return AppTheme.neonBlue;
      case PostType.betUpdate:
        return AppTheme.electricYellow;
      case PostType.betResult:
        return AppTheme.neonGreen;
      case PostType.achievement:
        return AppTheme.richPurple;
    }
  }

  IconData _getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.general:
        return Icons.chat_bubble_outline;
      case PostType.betUpdate:
        return Icons.update;
      case PostType.betResult:
        return Icons.emoji_events;
      case PostType.achievement:
        return Icons.stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPostTypeColor(post.type).withAlpha(51),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: post.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.hotPink,
                      backgroundImage: post.profileImageUrl != null
                          ? NetworkImage(post.profileImageUrl!)
                          : null,
                      child: post.profileImageUrl == null
                          ? Text(
                              post.username.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${post.username}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm')
                                .format(post.createdAt),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getPostTypeColor(post.type).withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPostTypeIcon(post.type),
                            size: 14,
                            color: _getPostTypeColor(post.type),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPostTypeLabel(post.type),
                            style: TextStyle(
                              color: _getPostTypeColor(post.type),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Content
                Text(
                  post.content,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                // Media (if available)
                if (post.media != null && post.media!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.media!.first['mediaUrl'] ?? post.media!.first['media_url'] ?? '',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: AppTheme.deepNavy,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    // Like button
                    InkWell(
                      onTap: () {
                        if (post.isLiked) {
                          postProvider.unlikePost(post.id);
                        } else {
                          postProvider.likePost(post.id);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: post.isLiked
                                  ? AppTheme.hotPink
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${post.likesCount}',
                              style: TextStyle(
                                color: post.isLiked
                                    ? AppTheme.hotPink
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Comment button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(postId: post.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${post.commentsCount}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Share button
                    IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        // TODO: Implement share
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
