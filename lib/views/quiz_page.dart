import 'dart:math';
import 'package:ai_teacher/animation/animated_background.dart';
import 'package:ai_teacher/controller/ai_controller.dart';
import 'package:ai_teacher/data/study_session.dart';
import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  final TextEditingController _topicController = TextEditingController();
  String _selectedDifficulty = 'medium';
  int _questionCount = 5;
  bool _isLoading = false;
  bool _quizGenerated = false;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _answered = false;
  String? _selectedAnswer;
  bool _quizCompleted = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _difficulties = [
    {
      'value': 'easy',
      'label': 'Easy',
      'color': Colors.green,
    },
    {
      'value': 'medium',
      'label': 'Medium',
      'color': Colors.orange,
    },
    {
      'value': 'hard',
      'label': 'Hard',
      'color': Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    if (_topicController.text.isEmpty) {
      _showSnackBar('Please enter a topic');
      return;
    }

    setState(() {
      _isLoading = true;
      _quizGenerated = false;
      _quizCompleted = false;
      _questions = [];
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
    });

    try {
      final response = await AIController.generateQuiz(
        _topicController.text,
        _questionCount,
        _selectedDifficulty,
      );

      // Process the response
      if (response.containsKey('questions') && response['questions'] is List) {
        setState(() {
          _questions = List<Map<String, dynamic>>.from(response['questions']);
          _isLoading = false;
          _quizGenerated = true;
          _answered = false;
          _selectedAnswer = null;
        });

        // Save this session
        final session = StudySession(
          type: SessionType.quiz,
          title: 'Quiz on ${_topicController.text}',
          content: 'Difficulty: ${_selectedDifficulty}, Questions: $_questionCount',
          response: 'Generated quiz with ${_questions.length} questions',
        );

        await StudySessionManager.addSession(session);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error generating quiz: $e');
    }
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = answer == currentQuestion['correctAnswer'];
    
    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (isCorrect) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _quizGenerated = false;
      _quizCompleted = false;
      _questions = [];
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _answered = false;
      _selectedAnswer = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedStarBackground(isDarkMode: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Quiz Generator',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _quizGenerated 
                  ? _quizCompleted 
                      ? _buildQuizResults(colorScheme, textTheme)
                      : _buildQuizContent(colorScheme, textTheme)
                  : _buildQuizSetup(colorScheme, textTheme),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuizSetup(ColorScheme colorScheme, TextTheme textTheme) {
    return [
      // Topic input
      SmartInputField(
        label: 'Topic',
        hintText: 'Enter any topic you want to be quizzed on',
        controller: _topicController,
        prefixIcon: Icons.topic,
      ),
      const SizedBox(height: 24),
      
      // Difficulty selection
      Text(
        'Difficulty Level',
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _difficulties.map((difficulty) {
          final bool isSelected = _selectedDifficulty == difficulty['value'];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(
                  difficulty['label'] as String,
                  style: TextStyle(
                    color: isSelected 
                        ? colorScheme.onPrimary 
                        : difficulty['color'],
                    fontWeight: isSelected 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: difficulty['color'],
                backgroundColor: colorScheme.surface,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDifficulty = difficulty['value'] as String;
                    });
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),
      
      // Number of questions
      Text(
        'Number of Questions: $_questionCount',
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 12),
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: colorScheme.primary,
          inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
          thumbColor: colorScheme.primary,
          overlayColor: colorScheme.primary.withOpacity(0.1),
          valueIndicatorColor: colorScheme.primary,
          valueIndicatorTextStyle: TextStyle(
            color: colorScheme.onPrimary,
          ),
        ),
        child: Slider(
          value: _questionCount.toDouble(),
          min: 3,
          max: 10,
          divisions: 7,
          label: _questionCount.toString(),
          onChanged: (value) {
            setState(() {
              _questionCount = value.toInt();
            });
          },
        ),
      ),
      const SizedBox(height: 32),
      
      // Generate button
      PrimaryButton(
        text: 'Generate Quiz',
        icon: Icons.quiz,
        onPressed: _generateQuiz,
        isLoading: _isLoading,
        fullWidth: true,
      ),
      
      if (_isLoading) ...[  
        const SizedBox(height: 24),
        const LoadingIndicator(message: 'Creating your personalized quiz...'),
      ],
    ];
  }

  List<Widget> _buildQuizContent(ColorScheme colorScheme, TextTheme textTheme) {
    if (_questions.isEmpty) {
      return [
        Center(
          child: Text(
            'No questions available',
            style: textTheme.titleMedium,
          ),
        ),
      ];
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final questionText = currentQuestion['question'] as String;
    final options = List<String>.from(currentQuestion['options']);

    return [
      // Progress indicator
      LinearProgressIndicator(
        value: (_currentQuestionIndex + 1) / _questions.length,
        backgroundColor: colorScheme.surface,
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _difficulties.firstWhere(
                (d) => d['value'] == _selectedDifficulty,
                orElse: () => _difficulties[1],
              )['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _difficulties.firstWhere(
                (d) => d['value'] == _selectedDifficulty,
                orElse: () => _difficulties[1],
              )['label'] as String,
              style: textTheme.labelSmall?.copyWith(
                color: _difficulties.firstWhere(
                  (d) => d['value'] == _selectedDifficulty,
                  orElse: () => _difficulties[1],
                )['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      
      // Question
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.2),
              colorScheme.primary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          questionText,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ),
      const SizedBox(height: 24),
      
      // Options
      ...options.map((option) {
        final bool isSelected = _selectedAnswer == option;
        final bool showResult = _answered;
        final bool isCorrect = option == currentQuestion['correctAnswer'];
        
        Color getOptionColor() {
          if (!showResult) return colorScheme.surface.withOpacity(0.7);
          if (isSelected && isCorrect) return Colors.green.withOpacity(0.2);
          if (isSelected && !isCorrect) return Colors.red.withOpacity(0.2);
          if (isCorrect) return Colors.green.withOpacity(0.2);
          return colorScheme.surface.withOpacity(0.7);
        }
        
        IconData? getOptionIcon() {
          if (!showResult) return null;
          if (isSelected && isCorrect) return Icons.check_circle;
          if (isSelected && !isCorrect) return Icons.cancel;
          if (isCorrect) return Icons.check_circle_outline;
          return null;
        }
        
        Color? getIconColor() {
          if (!showResult) return null;
          if (isSelected && isCorrect) return Colors.green;
          if (isSelected && !isCorrect) return Colors.red;
          if (isCorrect) return Colors.green;
          return null;
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: _answered ? null : () => _selectAnswer(option),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getOptionColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? (isCorrect ? Colors.green : Colors.red).withOpacity(0.7) 
                      : colorScheme.outline.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (getOptionIcon() != null) ...[  
                    Icon(
                      getOptionIcon(),
                      color: getIconColor(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
      const SizedBox(height: 16),
      
      // Explanation (when answered)
      if (_answered) ...[  
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.secondary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explanation:',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentQuestion['explanation'] as String,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Next Question',
          icon: Icons.arrow_forward,
          onPressed: _nextQuestion,
          fullWidth: true,
        ),
      ],
    ];
  }

  List<Widget> _buildQuizResults(ColorScheme colorScheme, TextTheme textTheme) {
    final percentage = (_correctAnswers / _questions.length) * 100;
    final String emoji;
    final String message;
    
    if (percentage >= 90) {
      emoji = '🏆';
      message = 'Excellent job! You\'re a master of this topic!';
    } else if (percentage >= 70) {
      emoji = '🎉';
      message = 'Great work! You have solid knowledge of this topic.';
    } else if (percentage >= 50) {
      emoji = '👍';
      message = 'Good effort! Keep studying to improve your score.';
    } else {
      emoji = '📚';
      message = 'Keep practicing! You\'ll get better with more study.';
    }
    
    return [
      Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 72),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          'Quiz Completed!',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      const SizedBox(height: 24),
      
      // Score display
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.2),
              colorScheme.primary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_correctAnswers',
                  style: textTheme.displaySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/${_questions.length}',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${percentage.round()}% Correct',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 70 ? Colors.green : 
                percentage >= 50 ? Colors.orange : 
                Colors.red,
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        message,
        textAlign: TextAlign.center,
        style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.9),
          fontStyle: FontStyle.italic,
        ),
      ),
      const SizedBox(height: 32),
      Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'New Quiz',
              icon: Icons.refresh,
              onPressed: _restartQuiz,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              text: 'Try Again',
              icon: Icons.replay,
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _correctAnswers = 0;
                  _answered = false;
                  _selectedAnswer = null;
                  _quizCompleted = false;
                });
              },
            ),
          ),
        ],
      ),
    ];
  }
}