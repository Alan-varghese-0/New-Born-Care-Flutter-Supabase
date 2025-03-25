import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'question_answer.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  final TextEditingController _questionController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final response = await _supabase
          .from('tbl_forum')
          .select('id, forum_question, forum_date')
          .order('forum_date', ascending: false);
      print('Fetched questions: $response');
      setState(() {
        _questions = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching questions: $error')),
      );
      print('Fetch error: $error');
    }
  }

  Future<void> _submitQuestion() async {
    print('Question controller text: "${_questionController.text}"');
    if (_questionController.text.trim().isNotEmpty) {
      try {
        print('Attempting to insert: ${_questionController.text.trim()}');
        final response = await _supabase.from('tbl_forum').insert({
          'forum_question': _questionController.text.trim(),
          'forum_date': DateTime.now().toIso8601String(),
        }).select('id, forum_question, forum_date');
        print('Inserted question response: $response');
        _questionController.clear();
        await _fetchQuestions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question submitted successfully!')),
        );
      } catch (error) {
        print('Insert error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting question: $error')),
        );
      }
    } else {
      print('Question is empty, not submitting');
    }
  }

  List<String> _getSuggestions(String query) {
    if (query.isEmpty) return [];
    return _questions
        .map((q) => q['forum_question'] as String? ?? '')
        .where((question) => question.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yy').format(date);
    } catch (e) {
      print('Date parsing error: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade200, Colors.purple.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Pregnancy Q&A",
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
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
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _getSuggestions(textEditingValue.text);
                },
                onSelected: (String selection) {
                  _questionController.text = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: _questionController,
                    focusNode: focusNode,
                    minLines: 2,
                    maxLines: 5,
                    onFieldSubmitted: (_) => _submitQuestion(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "Ask your pregnancy question",
                      labelStyle: GoogleFonts.nunito(
                        color: Colors.purple.shade600,
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
                            return GestureDetector(
                              onTap: () => onSelected(option),
                              child: ListTile(
                                title: Text(
                                  option,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _submitQuestion,
              child: Text(
                "Ask Away",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 70, color: Colors.pink.shade200),
                              const SizedBox(height: 20),
                              Text(
                                "No questions yet",
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  color: Colors.purple.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Ask something to connect with others!",
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: Colors.pink.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final questionText = _questions[index]["forum_question"] as String? ?? 'No question available';
                            final dateText = _formatDate(_questions[index]["forum_date"] as String?);
                            final questionId = _questions[index]["id"] as int?;
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
                                    questionText,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Posted: $dateText',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.purple.shade100.withOpacity(0.2),
                                    child: Icon(
                                      Icons.question_answer,
                                      color: Colors.purple.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward, color: Colors.purple),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => QuestionAnswerScreen(
                                            question: questionText,
                                            questionId: questionId ?? 0, // Fixed to include questionId
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}