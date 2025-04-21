import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AIController {
  static const String _apiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _apiKey = 'OPENAI-API-KEY'; // Replace with your API key in production

  // Headers for OpenAI API requests
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
  }

  // Generic method to send text-only prompts to OpenAI
  static Future<String> _sendRequest(String systemPrompt, String userPrompt, {String model = 'gpt-4o'}) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: _getHeaders(),
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': userPrompt,
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API request failed with status code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending request to OpenAI: $e');
    }
  }

  // Send a request with an image
  static Future<String> _sendImageRequest(String systemPrompt, String userPrompt, Uint8List imageBytes, {String model = 'gpt-4o'}) async {
    try {
      final String base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: _getHeaders(),
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': userPrompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
              ],
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API request failed with status code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending image request to OpenAI: $e');
    }
  }

  // Send a request expecting JSON response
  static Future<Map<String, dynamic>> _sendJsonRequest(String systemPrompt, String userPrompt, {String model = 'gpt-4o'}) async {
    try {
      final enhancedSystemPrompt = '$systemPrompt Please output the result as a JSON object.';
      
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: _getHeaders(),
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': enhancedSystemPrompt,
            },
            {
              'role': 'user',
              'content': userPrompt,
            }
          ],
          'temperature': 0.7,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception('API request failed with status code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending JSON request to OpenAI: $e');
    }
  }

  // Analyze an image of a question and provide an answer
  static Future<String> solveQuestion(Uint8List imageBytes, String subject) async {
    const String systemPrompt = '''
    You are an expert academic tutor specializing in solving questions across various subjects. 
    Your task is to analyze the question in the image, solve it step-by-step, and provide a clear, educational answer.
    ''';
    
    final String userPrompt = 'Please solve this $subject question shown in the image. Provide a detailed explanation of your solution.';
    
    return await _sendImageRequest(systemPrompt, userPrompt, imageBytes);
  }

  // Enhance, paraphrase, or expand text/essays
  static Future<String> enhanceWriting(String text, String goal) async {
    const String systemPrompt = '''
    You are an expert writing assistant specializing in academic and professional writing. 
    Your task is to help improve the user's text based on their specific goal.
    ''';
    
    final String userPrompt = 'Here is my text: "$text". Please $goal this text while maintaining its core meaning.';
    
    return await _sendRequest(systemPrompt, userPrompt);
  }

  // Generate a quiz on a specific topic
  static Future<Map<String, dynamic>> generateQuiz(String topic, int numberOfQuestions, String difficulty) async {
    const String systemPrompt = '''
    You are an expert educator specializing in creating educational quizzes. 
    Your task is to generate a quiz on the requested topic with the specified number of questions and difficulty level.
    The quiz should be educational, challenging, and engaging.
    ''';
    
    final String userPrompt = '''
    Please create a quiz on "$topic" with $numberOfQuestions questions at a $difficulty difficulty level. 
    Format each question with the following structure:
    {
      "questions": [
        {
          "question": "Question text here",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correctAnswer": "The correct option here",
          "explanation": "Explanation of why this is the correct answer"
        },
        ...
      ]
    }
    ''';
    
    return await _sendJsonRequest(systemPrompt, userPrompt);
  }

  // Review and optimize code
  static Future<String> analyzeCode(String code, String language, String goal) async {
    const String systemPrompt = '''
    You are an expert software engineer specializing in code review and optimization. 
    Your task is to analyze the user's code, provide feedback, and suggest improvements based on their specific goal.
    ''';
    
    final String userPrompt = '''
    Here is my $language code:
    ```
    $code
    ```
    
    Please $goal this code. Provide explanations for your suggestions.
    ''';
    
    return await _sendRequest(systemPrompt, userPrompt);
  }

  // Summarize a document or text
  static Future<String> summarizeText(String text, int maxLength) async {
    const String systemPrompt = '''
    You are an expert in information synthesis and summarization. 
    Your task is to create concise, accurate summaries of longer texts while preserving the key information and main points.
    ''';

    final String userPrompt = '''
    Please summarize the following text in approximately $maxLength words:
    "$text"
    ''';

    return await _sendRequest(systemPrompt, userPrompt, model: 'gpt-4o-mini');
  }
}