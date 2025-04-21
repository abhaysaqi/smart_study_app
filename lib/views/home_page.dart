import 'package:ai_teacher/animation/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/common_widgets.dart';
import 'question_solver_page.dart';
import 'writing_assistant_page.dart';
import 'quiz_page.dart';
import 'code_helper_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  bool _showShootingStar = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Trigger shooting star animation periodically
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showShootingStar = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showShootingStar = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return AnimatedStarBackground(
      isDarkMode: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: size.height * 0.25,
                floating: false,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'StudySmart',
                                  textStyle: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                  speed: const Duration(milliseconds: 100),
                                ),
                              ],
                              totalRepeatCount: 1,
                              displayFullTextOnTap: true,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'AI',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Making studying efficient, interactive, and personalized',
                              textStyle: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                              speed: const Duration(milliseconds: 50),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Features section
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        'Features',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 2,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.history,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const HistoryPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Feature cards
              SliverList(
                delegate: SliverChildListDelegate([
                  // Question Solver
                  _buildFeatureCard(
                    context,
                    'Question Solver',
                    'Scan and solve handwritten or printed questions. Get instant answers across subjects.',
                    Icons.camera_alt_outlined,
                    colorScheme.primary,
                    () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const QuestionSolverPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                      ),
                    ),
                  ),

                  // Writing Assistant
                  _buildFeatureCard(
                    context,
                    'Writing Assistant',
                    'Enhance, paraphrase, or expand essays. Refine content or summarize documents.',
                    Icons.edit_note,
                    colorScheme.secondary,
                    () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const WritingAssistantPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                      ),
                    ),
                  ),

                  // Quiz Generator
                  _buildFeatureCard(
                    context,
                    'Quiz Generator',
                    'Practice with AI-generated quizzes to boost your knowledge on any subject.',
                    Icons.quiz_outlined,
                    colorScheme.tertiary,
                    () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const QuizPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                      ),
                    ),
                  ),

                  // Code Helper
                  _buildFeatureCard(
                    context,
                    'Code Helper',
                    'Get code reviews, optimization help, and learn coding concepts.',
                    Icons.code,
                    Colors.indigo,
                    () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const CodeHelperPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate delay based on index to create a staggered effect
        final double delay = title.hashCode % 4 * 0.2;
        final Animation<double> delayedAnimation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            delay,
            1.0,
            curve: Curves.easeOut,
          ),
        );

        return Transform.translate(
          offset: Offset(
            0.0,
            50 * (1.0 - delayedAnimation.value),
          ),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: child,
          ),
        );
      },
      child: FeatureCard(
        title: title,
        description: description,
        icon: icon,
        iconColor: iconColor,
        onTap: onTap,
      ),
    );
  }
}
