import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/community/mock_posts.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key, this.posts = mockPosts});

  final List<CommunityPost> posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('社区互助')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                key: Key('communityPostCard_$index'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(post.username.substring(0, 1)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              post.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Chip(label: Text(post.tag)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text(post.location),
                          const SizedBox(width: 16),
                          const Icon(Icons.schedule_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text(post.time),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('发布互助（演示）')),
          );
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text('发布互助'),
      ),
    );
  }
}
