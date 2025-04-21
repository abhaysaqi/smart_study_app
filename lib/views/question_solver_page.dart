import 'dart:typed_data';
import 'package:ai_teacher/animation/animated_background.dart';
import 'package:ai_teacher/controller/ai_controller.dart';
import 'package:ai_teacher/data/study_session.dart';
import 'package:ai_teacher/helper/image_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class QuestionSolverPage extends StatefulWidget {
  const QuestionSolverPage({Key? key}) : super(key: key);

  @override
  State<QuestionSolverPage> createState() => _QuestionSolverPageState();
}

class _QuestionSolverPageState extends State<QuestionSolverPage> with SingleTickerProviderStateMixin {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  Uint8List? _selectedImage;
  String? _response;
  bool _isLoading = false;
  bool _showResponse = false;
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool fromCamera) async {
    final Uint8List? imageBytes = fromCamera 
        ? await ImageUploadHelper.captureImage() 
        : await ImageUploadHelper.pickImageFromGallery();
    
    if (imageBytes != null) {
      setState(() {
        _selectedImage = imageBytes;
        _showResponse = false;
        _response = null;
      });
    }
  }

  Future<void> _solveQuestion() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select or capture an image first');
      return;
    }

    if (_subjectController.text.isEmpty) {
      _showSnackBar('Please enter a subject');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a title for this question');
      return;
    }

    setState(() {
      _isLoading = true;
      _showResponse = true;
    });

    try {
      final response = await AIController.solveQuestion(
        _selectedImage!,
        _subjectController.text,
      );

      // Save this session
      final session = StudySession(
        type: SessionType.questionSolver,
        title: _titleController.text,
        content: 'Subject: ${_subjectController.text}',
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedImage = null;
      _response = null;
      _showResponse = false;
      _subjectController.clear();
      _titleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedStarBackground(
      isDarkMode: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Question Solver',
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
          actions: [
            if (_selectedImage != null)
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: colorScheme.primary,
                ),
                onPressed: _resetForm,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value * 100),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title input
                SmartInputField(
                  label: 'Title',
                  hintText: 'Give your question a title',
                  controller: _titleController,
                  prefixIcon: Icons.title,
                ),
                const SizedBox(height: 16),
                
                // Subject input
                SmartInputField(
                  label: 'Subject',
                  hintText: 'Math, Physics, Chemistry, etc.',
                  controller: _subjectController,
                  prefixIcon: Icons.book,
                ),
                const SizedBox(height: 24),
                
                // Image selection area
                if (_selectedImage == null) ...[  
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select or capture an image of your question',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Take Photo',
                          icon: Icons.camera_alt,
                          onPressed: () => _pickImage(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Gallery',
                          icon: Icons.photo_library,
                          onPressed: () => _pickImage(false),
                        ),
                      ),
                    ],
                  ),
                ] else ...[  
                  Stack(
                    children: [
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            _selectedImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () => _pickImage(false),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Solve Question',
                    icon: Icons.psychology,
                    isLoading: _isLoading,
                    onPressed: _solveQuestion,
                    fullWidth: true,
                  ),
                ],
                const SizedBox(height: 24),
                
                // Response section
                if (_showResponse) ...[  
                  AnimatedResponseContainer(
                    text: _response ?? '',
                    isLoading: _isLoading,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}