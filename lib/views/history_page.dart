import 'package:ai_teacher/animation/animated_background.dart';
import 'package:ai_teacher/data/study_session.dart';
import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  List<StudySession> _sessions = [];
  bool _isLoading = true;
  String _activeFilter = 'all';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadSessions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessions = await StudySessionManager.loadSessions();
      
      // If no sessions are found, create some sample sessions for demo purposes
      if (sessions.isEmpty) {
        // This is just for demo purposes; in a real app, we would use the actual sessions
        final sampleSessions = [
          StudySession(
            type: SessionType.questionSolver,
            title: 'Quadratic Equation',
            content: 'Subject: Mathematics',
            response: 'The solution to a quadratic equation ax² + bx + c = 0 is given by the formula x = (-b ± √(b² - 4ac)) / 2a.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          StudySession(
            type: SessionType.writingAssistant,
            title: 'Essay Introduction',
            content: 'I need to write an introduction about climate change',
            response: 'Climate change represents one of the most significant challenges facing humanity in the 21st century...',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            isFavorite: true,
          ),
          StudySession(
            type: SessionType.quiz,
            title: 'Quiz on World History',
            content: 'Difficulty: medium, Questions: 5',
            response: 'Generated quiz with 5 questions',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          StudySession(
            type: SessionType.codeHelper,
            title: 'Python Code Review',
            content: 'def factorial(n):\n    if n == 0:\n        return 1\n    else:\n        return n * factorial(n-1)',
            response: 'The recursive factorial function is correct but could lead to stack overflow for large inputs...',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            isFavorite: true,
          ),
        ];
        
        setState(() {
          _sessions = sampleSessions;
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading sessions: $e');
    }
  }

  Future<void> _toggleFavorite(String sessionId) async {
    try {
      await StudySessionManager.toggleFavorite(sessionId);
      // Update the local state for immediate UI feedback
      setState(() {
        final index = _sessions.indexWhere((s) => s.id == sessionId);
        if (index >= 0) {
          _sessions[index] = _sessions[index].copyWith(
            isFavorite: !_sessions[index].isFavorite,
          );
        }
      });
    } catch (e) {
      _showSnackBar('Error toggling favorite: $e');
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      await StudySessionManager.deleteSession(sessionId);
      // Update the local state for immediate UI feedback
      setState(() {
        _sessions.removeWhere((s) => s.id == sessionId);
      });
      _showSnackBar('Session deleted');
    } catch (e) {
      _showSnackBar('Error deleting session: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: message.contains('Error') 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  List<StudySession> _getFilteredSessions() {
    if (_activeFilter == 'all') {
      return _sessions;
    } else if (_activeFilter == 'favorites') {
      return _sessions.where((s) => s.isFavorite).toList();
    } else {
      final SessionType filterType = SessionType.values.firstWhere(
        (t) => t.toString().split('.').last == _activeFilter,
        orElse: () => SessionType.questionSolver,
      );
      return _sessions.where((s) => s.type == filterType).toList();
    }
  }

  IconData _getIconForSessionType(SessionType type) {
    switch (type) {
      case SessionType.questionSolver:
        return Icons.help_outline;
      case SessionType.writingAssistant:
        return Icons.edit_note;
      case SessionType.quiz:
        return Icons.quiz_outlined;
      case SessionType.codeHelper:
        return Icons.code;
      case SessionType.summary:
        return Icons.summarize;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filteredSessions = _getFilteredSessions();

    return AnimatedStarBackground(isDarkMode: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Study History',
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
        body: _isLoading
            ? const Center(child: LoadingIndicator(message: 'Loading your study sessions...'))
            : Column(
                children: [
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'All', Icons.folder_open),
                        _buildFilterChip('favorites', 'Favorites', Icons.favorite),
                        _buildFilterChip('questionSolver', 'Questions', Icons.help_outline),
                        _buildFilterChip('writingAssistant', 'Writing', Icons.edit_note),
                        _buildFilterChip('quiz', 'Quizzes', Icons.quiz_outlined),
                        _buildFilterChip('codeHelper', 'Code', Icons.code),
                      ],
                    ),
                  ),
                  
                  // Sessions list or empty state
                  Expanded(
                    child: filteredSessions.isEmpty
                        ? _buildEmptyState()
                        : _buildSessionsList(filteredSessions),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = _activeFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _activeFilter = value;
            });
          }
        },
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        checkmarkColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_outlined,
                size: 64,
                color: colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No study sessions found',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _activeFilter == 'all'
                    ? 'Start using the app\'s features to create your first study session!'
                    : 'No sessions matching the selected filter. Try a different filter.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Return to Home',
                icon: Icons.home,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList(List<StudySession> sessions) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Calculate delay based on index to create a staggered effect
              final double delay = index * 0.05;
              final Animation<double> delayedAnimation = CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay.clamp(0.0, 0.9),
                  1.0,
                  curve: Curves.easeOut,
                ),
              );

              return Transform.translate(
                offset: Offset(
                  0.0,
                  20 * (1.0 - delayedAnimation.value),
                ),
                child: Opacity(
                  opacity: delayedAnimation.value,
                  child: child,
                ),
              );
            },
            child: Dismissible(
              key: Key(session.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                color: Colors.red,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: Text(
                        'Are you sure you want to delete "${session.title}"?',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) => _deleteSession(session.id),
              child: SessionCard(
                title: session.title,
                subtitle: _getSessionSubtitle(session),
                dateTime: session.createdAt,
                icon: _getIconForSessionType(session.type),
                isFavorite: session.isFavorite,
                onFavoriteToggle: () => _toggleFavorite(session.id),
                onTap: () => _showSessionDetails(session),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSessionSubtitle(StudySession session) {
    switch (session.type) {
      case SessionType.questionSolver:
        return 'Question: ${session.content}';
      case SessionType.writingAssistant:
        if (session.content.length > 60) {
          return '${session.content.substring(0, 60)}...';
        }
        return session.content;
      case SessionType.quiz:
        return 'Quiz settings: ${session.content}';
      case SessionType.codeHelper:
        if (session.content.length > 60) {
          return '${session.content.substring(0, 60)}...';
        }
        return session.content;
      case SessionType.summary:
        return 'Summary of text';
      default:
        return 'Study session';
    }
  }

  void _showSessionDetails(StudySession session) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getIconForSessionType(session.type),
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${session.createdAt.day}/${session.createdAt.month}/${session.createdAt.year} at ${session.createdAt.hour}:${session.createdAt.minute.toString().padLeft(2, '0')}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      session.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: session.isFavorite ? colorScheme.tertiary : colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      _toggleFavorite(session.id);
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(color: colorScheme.outline.withOpacity(0.3)),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Input:',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        session.content,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AI Response:',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.secondary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: SelectableText(
                        session.response ?? 'No response available',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Close',
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Delete',
                      icon: Icons.delete,
                      onPressed: () {
                        _deleteSession(session.id);
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}