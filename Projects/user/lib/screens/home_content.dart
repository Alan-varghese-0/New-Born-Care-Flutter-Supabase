import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/main.dart';
import 'package:user/screens/breathing.dart';
import 'package:user/screens/community/viewpost.dart';
import 'package:user/screens/forum.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {

  String name = "";

@override
  void initState() {
    super.initState();
    fetchUser();
  }
  Future<void> fetchUser() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response =
          await supabase.from("tbl_user").select().eq('id', uid).single();
      print("User data fetched: $response");

      setState(() {
        name = response['user_name'] ?? "";
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Banner Section
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade200,
                Colors.purple.shade200
              ], // Softer, pregnancy-friendly colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome $name",
                style: GoogleFonts.pacifico(
                  // Changed to a more cursive, gentle font
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Nurturing you and your little one",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // List of Features
        Expanded(
          child: Container(
            color: Colors.pink.shade50, // Very light pink background
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFeatureTile(
                  context,
                  title: "Pregnancy Q&A",
                  subtitle: "Connect with experts and moms",
                  icon: Icons.chat_bubble_outline,
                  color: Colors.pink.shade300,
                  screen: const Forum(),
                ),
                _buildFeatureTile(
                  context,
                  title: "Moments & Milestones",
                  subtitle: "Share your pregnancy journey",
                  icon: Icons.favorite_border,
                  color: Colors.purple.shade300,
                  screen: const Viewpost(),
                ),
                _buildFeatureTile(
                  context,
                  title: "Calm & Breathe",
                  subtitle: "Relaxation for you and baby",
                  icon: Icons.self_improvement,
                  color: Colors.teal.shade300,
                  screen: const BreathingExercise(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      elevation: 2, // Slightly reduced elevation for a softer look
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)), // More rounded corners
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2), // Slightly more transparent
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600, // Slightly lighter weight
            color: Colors.purple.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.pink.shade400,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        },
      ),
    );
  }
}
