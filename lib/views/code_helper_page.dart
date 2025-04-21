import 'package:ai_teacher/animation/animated_background.dart';
import 'package:ai_teacher/controller/ai_controller.dart';
import 'package:ai_teacher/data/study_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/common_widgets.dart';

class CodeHelperPage extends StatefulWidget {
  const CodeHelperPage({Key? key}) : super(key: key);

  @override
  State<CodeHelperPage> createState() => _CodeHelperPageState();
}

class _CodeHelperPageState extends State<CodeHelperPage> with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  String _selectedGoal = 'explain';
  String? _response;
  bool _isLoading = false;
  bool _showResponse = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _goals = [
    {
      'value': 'explain',
      'label': 'Explain',
      'icon': Icons.lightbulb_outline,
      'description': 'Understand what the code does'
    },
    {
      'value': 'optimize',
      'label': 'Optimize',
      'icon': Icons.speed,
      'description': 'Improve performance and efficiency'
    },
    {
      'value': 'review',
      'label': 'Review',
      'icon': Icons.rate_review,
      'description': 'Get feedback on code quality'
    },
    {
      'value': 'debug',
      'label': 'Debug',
      'icon': Icons.bug_report,
      'description': 'Find and fix issues in the code'
    },
    {
      'value': 'improve',
      'label': 'Improve',
      'icon': Icons.auto_awesome,
      'description': 'Enhance code readability and structure'
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
    _codeController.dispose();
    _languageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _analyzeCode() async {
    if (_codeController.text.isEmpty) {
      _showSnackBar('Please enter some code');
      return;
    }

    if (_languageController.text.isEmpty) {
      _showSnackBar('Please specify the programming language');
      return;
    }

    setState(() {
      _isLoading = true;
      _showResponse = true;
    });

    try {
      final goal = _getGoalDescription();
      final response = await AIController.analyzeCode(
        _codeController.text,
        _languageController.text,
        goal,
      );

      // Save this session
      final session = StudySession(
        type: SessionType.codeHelper,
        title: '${_languageController.text} Code ${_getGoalDescription().capitalize()}',
        content: _codeController.text,
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
            'Code Helper',
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
                // Language input
                SmartInputField(
                  label: 'Programming Language',
                  hintText: 'Python, JavaScript, Java, etc.',
                  controller: _languageController,
                  prefixIcon: Icons.code,
                ),
                const SizedBox(height: 24),
                
                // Goal selection
                Text(
                  'What would you like to do with your code?',
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
                
                // Code input
                Stack(
                  children: [
                    Container(
                      height: 250,
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 16, 
                        left: 16,
                        right: 40,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste your code here...',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontFamily: 'monospace',
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          Icons.content_paste,
                          color: colorScheme.primary,
                        ),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            setState(() {
                              _codeController.text = data!.text!;
                            });
                            _showSnackBar('Code pasted from clipboard');
                          }
                        },
                        tooltip: 'Paste from clipboard',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Process button
                PrimaryButton(
                  text: _getGoalDescription().capitalize() + ' Code',
                  icon: _goals.firstWhere(
                    (goal) => goal['value'] == _selectedGoal,
                    orElse: () => _goals.first,
                  )['icon'] as IconData,
                  isLoading: _isLoading,
                  onPressed: _analyzeCode,
                  fullWidth: true,
                ),
                const SizedBox(height: 24),
                
                // Response section
                if (_showResponse) ...[  
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
                            Clipboard.setData(ClipboardData(text: _response!));
                            _showSnackBar('Response copied to clipboard');
                          },
                          tooltip: 'Copy to clipboard',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: colorScheme.primary,
                          ),
                          onPressed: _analyzeCode,
                          tooltip: 'Regenerate',
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