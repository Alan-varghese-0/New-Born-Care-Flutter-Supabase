import 'package:flutter/material.dart';
import 'package:user/screens/community/addpost.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/screens/community/view_comments.dart';
import 'package:user/main.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class Viewpost extends StatefulWidget {
  const Viewpost({super.key});

  @override
  State<Viewpost> createState() => _ViewpostState();
}

class _ViewpostState extends State<Viewpost> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await supabase
          .from('tbl_post')
          .select('*, tbl_user(*)')
          .order('post_datetime', ascending: false);
      print("POST: $response");
      final currentUserId = supabase.auth.currentUser!.id;

      List<Map<String, dynamic>> postsWithLikes = [];
      for (var post in response) {
        final likesResponse = await supabase
            .from('tbl_like')
            .select('user_id')
            .eq('post_id', post['id']);
        bool isLiked = likesResponse.any((like) => like['user_id'] == currentUserId);
        post['like_count'] = likesResponse.length;
        post['is_liked_by_user'] = isLiked;
        postsWithLikes.add(post);
      }

      setState(() {
        posts = postsWithLikes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading posts. Please try again.';
      });
      print('Error fetching posts: $e');
    }
  }

  Future<void> toggleLike(int postId, bool isLiked) async {
    try {
      final currentUserId = supabase.auth.currentUser!.id;
      setState(() {
        for (var post in posts) {
          if (post['id'] == postId) {
            post['is_liked_by_user'] = !isLiked;
            post['like_count'] = isLiked ? (post['like_count'] - 1) : (post['like_count'] + 1);
          }
        }
      });

      if (isLiked) {
        await supabase.from('tbl_like').delete().match({'post_id': postId, 'user_id': currentUserId});
      } else {
        await supabase.from('tbl_like').insert({'post_id': postId, 'user_id': currentUserId});
      }
    } catch (e) {
      setState(() {
        for (var post in posts) {
          if (post['id'] == postId) {
            post['is_liked_by_user'] = isLiked;
            post['like_count'] = isLiked ? (post['like_count'] + 1) : (post['like_count'] - 1);
          }
        }
      });
      await fetchPosts();
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like. Please try again.')),
      );
    }
  }

  String getTimeAgo(String dateTime) {
    final date = DateTime.parse(dateTime);
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Soft pink background
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200], // Matching pregnancy theme
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Moments & Milestones',
          style: GoogleFonts.pacifico( // Nurturing font
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: fetchPosts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade300),
                strokeWidth: 4,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 70, color: Colors.pink.shade300),
                      const SizedBox(height: 20),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.purple.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: fetchPosts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 2,
                        ),
                        child: const Text("Try Again", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              : posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 90, color: Colors.pink.shade200),
                          const SizedBox(height: 20),
                          Text(
                            "No moments yet",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Share your pregnancy journey",
                            style: TextStyle(fontSize: 16, color: Colors.pink.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchPosts,
                      color: Colors.purple.shade300,
                      child: ListView.builder(
                        itemCount: posts.length,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final isLiked = post['is_liked_by_user'] ?? false;
                          final likeCount = post['like_count'] ?? 0;
                          final postId = post['id'];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2, // Softer elevation
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.pink.shade50], // Softer gradient
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.pink.shade100,
                                          child: Text(
                                            (post['tbl_user']['user_name'] ?? 'U')[0].toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.purple.shade800,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['tbl_user']['user_name'] ?? 'Unknown User',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.purple.shade900,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                getTimeAgo(post['post_datetime']),
                                                style: TextStyle(
                                                  color: Colors.pink.shade600,
                                                  fontSize: 13,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.more_horiz, color: Colors.grey[700], size: 28),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                    if (post['post_content'] != null && post['post_content'].trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16, bottom: 12),
                                        child: Text(
                                          post['post_content'],
                                          style: const TextStyle(
                                            fontSize: 17,
                                            height: 1.5,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    if (post['post_file'] != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        height: 450,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            imageUrl: post['post_file'],
                                            placeholder: (context, url) => Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.pink.shade100, Colors.purple.shade100],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.purple.shade300,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.pink.shade100,
                                              child: Center(
                                                child: Icon(Icons.error, color: Colors.red[300], size: 50),
                                              ),
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                                      child: Row(
                                        children: [
                                          if (likeCount > 0)
                                            Row(
                                              children: [
                                                Icon(Icons.favorite, size: 20, color: Colors.pink.shade400),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '$likeCount',
                                                  style: TextStyle(
                                                    color: Colors.purple.shade800,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const Spacer(),
                                          if ((post['comment_count'] ?? 0) > 0)
                                            Text(
                                              '${post['comment_count']} comments',
                                              style: TextStyle(
                                                color: Colors.purple.shade800,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Divider(color: Colors.pink.shade200, height: 1),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: TextButton.icon(
                                            icon: Icon(
                                              isLiked ? Icons.favorite : Icons.favorite_border,
                                              color: isLiked ? Colors.pink.shade400 : Colors.purple.shade700,
                                              size: 24,
                                            ),
                                            label: Text(
                                              'Like',
                                              style: TextStyle(
                                                color: isLiked ? Colors.pink.shade600 : Colors.purple.shade800,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            onPressed: () => toggleLike(postId, isLiked),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextButton.icon(
                                            icon: Icon(
                                              Icons.chat_bubble_outline,
                                              color: Colors.purple.shade700,
                                              size: 24,
                                            ),
                                            label: Text(
                                              'Comment',
                                              style: TextStyle(
                                                color: Colors.purple.shade800,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CommentsPage(postId: postId),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePost())),
        backgroundColor: Colors.pink.shade300,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

// CommentsBottomSheet remains largely unchanged in terms of functionality but updated for theme
class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  final Future<void> Function(int) fetchCommentsCallback;
  final Future<void> Function(int) addCommentCallback;
  final TextEditingController commentController;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.fetchCommentsCallback,
    required this.addCommentCallback,
    required this.commentController,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  List<Map<String, dynamic>> comments = [];
  bool isLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => isLoading = true);
    await widget.fetchCommentsCallback(widget.postId);
    setState(() => isLoading = false);
  }

  Future<void> _addComment() async {
    if (widget.commentController.text.trim().isEmpty) return;
    setState(() => isSubmitting = true);
    await widget.addCommentCallback(widget.postId);
    await _fetchComments();
    setState(() => isSubmitting = false);
  }

  String getTimeAgo(String dateTime) {
    final date = DateTime.parse(dateTime);
    return timeago.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.pink.shade50], // Softer gradient
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade300, Colors.purple.shade300], // Theme matching
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                        shadows: const [Shadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.pink.shade200, height: 1),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.purple.shade300))
                    : comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 70, color: Colors.pink.shade200),
                                const SizedBox(height: 20),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    color: Colors.purple.shade800,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Share your thoughts!',
                                  style: TextStyle(color: Colors.pink.shade600, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: comments.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.pink.shade100,
                                      child: Text(
                                        (comment['tbl_user']['user_name'] ?? 'U')[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.purple.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.pink.shade50, Colors.white],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.pink.shade200,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment['tbl_user']['user_name'] ?? 'Unknown User',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.purple.shade900,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  comment['comment_content'],
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, top: 8),
                                            child: Text(
                                              getTimeAgo(comment['created_at']),
                                              style: TextStyle(
                                                color: Colors.pink.shade600,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.pink.shade200, width: 1)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.purple.shade500, fontStyle: FontStyle.italic),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.pink.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          prefixIcon: Icon(Icons.comment, color: Colors.purple.shade600, size: 22),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade300, Colors.purple.shade300], // Theme matching
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.pink.shade200, blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: IconButton(
                        icon: isSubmitting
                            ? SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Icon(Icons.send, color: Colors.white, size: 26),
                        onPressed: isSubmitting ? null : _addComment,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}