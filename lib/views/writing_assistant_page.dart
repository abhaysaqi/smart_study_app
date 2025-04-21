import 'package:ai_teacher/animation/animated_background.dart';
import 'package:ai_teacher/controller/ai_controller.dart';
import 'package:ai_teacher/data/study_session.dart';
import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class WritingAssistantPage extends StatefulWidget {
  const WritingAssistantPage({Key? key}) : super(key: key);

  @override
  State<WritingAssistantPage> createState() => _WritingAssistantPageState();
}

class _WritingAssistantPageState extends State<WritingAssistantPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _selectedGoal = 'enhance';
  String? _response;
  bool _isLoading = false;
  bool _showResponse = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _goals = [
    {
      'value': 'enhance',
      'label': 'Enhance',
      'icon': Icons.auto_awesome,
      'description': 'Improve writing quality while maintaining meaning'
    },
    {
      'value': 'paraphrase',
      'label': 'Paraphrase',
      'icon': Icons.shuffle,
      'description': 'Rewrite using different words but same meaning'
    },
    {
      'value': 'expand',
      'label': 'Expand',
      'icon': Icons.expand,
      'description': 'Add more details and elaborate on ideas'
    },
    {
      'value': 'summarize',
      'label': 'Summarize',
      'icon': Icons.compress,
      'description': 'Create a concise version of the text'
    },
    {
      'value': 'simplify',
      'label': 'Simplify',
      'icon': Icons.lightbulb_outline,
      'description': 'Make the text easier to understand'
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
    _textController.dispose();
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Please enter some text');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a title for this session');
      return;
    }

    setState(() {
      _isLoading = true;
      _showResponse = true;
    });

    try {
      final goal = _getGoalDescription();
      final response = await AIController.enhanceWriting(
        _textController.text,
        goal,
      );

      // Save this session
      final session = StudySession(
        type: SessionType.writingAssistant,
        title: _titleController.text,
        content: _textController.text,
        response: response,
      );

      await StudySessionManager.addSession(session);

      if (mounted) {
        setState(() {
          _response = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _response = 'Error: $e';
        });
      }
      _showSnackBar('An error occurred: $e');
    }
  }

  String _getGoalDescription() {
    final goal = _goals.firstWhere(
      (goal) => goal['value'] == _selectedGoal,
      orElse: () => _goals.first,
    );
    return goal['label'].toLowerCase();
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
            'Writing Assistant',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title input
                SmartInputField(
                  label: 'Title',
                  hintText: 'Give your writing a title',
                  controller: _titleController,
                  prefixIcon: Icons.title,
                ),
                const SizedBox(height: 24),
                
                // Goal selection
                Text(
                  'What would you like to do with your text?',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Goal selection chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _goals.map((goal) {
                      final bool isSelected = _selectedGoal == goal['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                goal['icon'] as IconData,
                                size: 16,
                                color: isSelected 
                                    ? colorScheme.onPrimary 
                                    : colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                goal['label'] as String,
                                style: TextStyle(
                                  color: isSelected 
                                      ? colorScheme.onPrimary 
                                      : colorScheme.primary,
                                  fontWeight: isSelected 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedGoal = goal['value'] as String;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Goal description
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _goals.firstWhere(
                      (goal) => goal['value'] == _selectedGoal,
                      orElse: () => _goals.first,
                    )['description'] as String,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Text input
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Enter your text here...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Process button
                PrimaryButton(
                  text: _getGoalDescription().capitalize(),
                  icon: _goals.firstWhere(
                    (goal) => goal['value'] == _selectedGoal,
                    orElse: () => _goals.first,
                  )['icon'] as IconData,
                  isLoading: _isLoading,
                  onPressed: _processText,
                  fullWidth: true,
                ),
                const SizedBox(height: 24),
                
                // Response section
                if (_showResponse) ... [
                  AnimatedResponseContainer(
                    text: _response ?? '',
                    isLoading: _isLoading,
                  ),
                  if (!_isLoading && _response != null) ...[  
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            // Copy to clipboard logic would go here
                            _showSnackBar('Copied to clipboard');
                          },
                          tooltip: 'Copy to clipboard',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: colorScheme.primary,
                          ),
                          onPressed: _processText,
                          tooltip: 'Regenerate',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.text_fields,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _textController.text = _response!;
                              _response = null;
                              _showResponse = false;
                            });
                          },
                          tooltip: 'Use as new input',
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}