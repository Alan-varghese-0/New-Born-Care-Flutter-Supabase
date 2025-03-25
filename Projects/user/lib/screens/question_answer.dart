import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final String question;
  final int questionId;

  const QuestionAnswerScreen({super.key, required this.question, required this.questionId});

  @override
  State<QuestionAnswerScreen> createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  final TextEditingController _answerController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnswers();
  }

  Future<void> _fetchAnswers() async {
    try {
      final response = await _supabase
          .from('tbl_forumreply')
          .select('id, freply_answer, user_id, tbl_user(user_name)') // Changed to user_name
          .eq('forum_id', widget.questionId);
      print('Fetched answers: $response');
      setState(() {
        _answers = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching answers: $error')),
      );
      print('Fetch error: $error');
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isNotEmpty) {
      try {
        final user = _supabase.auth.currentUser; // Get current authenticated user
        if (user == null) {
          throw Exception('User not authenticated');
        }

        print('Attempting to insert answer: ${_answerController.text.trim()}');
        final response = await _supabase.from('tbl_forumreply').insert({
          'forum_id': widget.questionId,
          'freply_answer': _answerController.text.trim(),
          'user_id': user.id,
        }).select('id, freply_answer, user_id, tbl_user(user_name)'); // Changed to user_name
        print('Inserted answer response: $response');
        _answerController.clear();
        await _fetchAnswers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answer submitted successfully!')),
        );
      } catch (error) {
        print('Insert error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting answer: $error')),
        );
      }
    } else {
      print('Answer is empty, not submitting');
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade300,
        title: Text(
          'Question',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _answers.isEmpty
                      ? Center(
                          child: Text(
                            'No answers yet...',
                            style: GoogleFonts.nunito(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _answers.length,
                          itemBuilder: (context, index) {
                            final answerText = _answers[index]["freply_answer"] as String? ?? 'No answer';
                            final username = _answers[index]["tbl_user"]?["user_name"] as String? ?? 'Anonymous'; // Changed to user_name
                            final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(
                                    answerText,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  subtitle: Text(
                                    'By: $username',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.purple.shade100.withOpacity(0.2),
                                    child: Text(
                                      initial,
                                      style: GoogleFonts.nunito(
                                        fontSize: 18,
                                        color: Colors.purple.shade600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade100.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _answerController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Add your answer",
                  labelStyle: GoogleFonts.nunito(
                    color: Colors.purple.shade600,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.pink.shade300,
                    ),
                    onPressed: _submitAnswer,
                    padding: const EdgeInsets.only(right: 16),
                  ),
                ),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}