import 'package:ai_teacher/data/study_session.dart';


/// Sample data provider for the StudySession model
class SampleData {
  /// Get sample study sessions to demonstrate the app functionality
  static List<StudySession> getSampleSessions() {
    return [
      StudySession(
        type: SessionType.questionSolver,
        title: 'Quadratic Equation',
        content: 'Subject: Mathematics',
        response: 'The solution to a quadratic equation ax² + bx + c = 0 is given by the formula x = (-b ± √(b² - 4ac)) / 2a. To solve a specific quadratic equation:\n\n1. Identify the values of a, b, and c from the standard form.\n2. Calculate the discriminant (b² - 4ac).\n3. If the discriminant is positive, there are two real solutions.\n4. If the discriminant is zero, there is one real solution.\n5. If the discriminant is negative, there are two complex solutions.\n\nFor example, let\'s solve x² + 5x + 6 = 0:\n- a = 1, b = 5, c = 6\n- discriminant = 5² - 4(1)(6) = 25 - 24 = 1\n- x = (-5 ± √1) / 2(1) = (-5 ± 1) / 2\n- x = -3 or x = -2',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      StudySession(
        type: SessionType.writingAssistant,
        title: 'Essay Introduction',
        content: 'I need to write an introduction about climate change',
        response: 'Climate change represents one of the most significant challenges facing humanity in the 21st century. This global phenomenon, characterized by long-term shifts in temperature and weather patterns, is primarily driven by human activities that release greenhouse gases into the atmosphere. From the industrial revolution to modern transportation and agricultural practices, our collective carbon footprint has accelerated the warming of our planet at an alarming rate. The consequences are far-reaching and increasingly severe—rising sea levels threaten coastal communities, extreme weather events become more frequent and intense, ecosystems face disruption, and food security becomes more precarious for millions worldwide. Addressing climate change requires not only international cooperation and policy reform but also fundamental shifts in how we produce energy, manufacture goods, and organize our economies. This essay explores the multifaceted dimensions of climate change, examining its causes, impacts, and the urgent actions needed to mitigate its most devastating effects before we reach irreversible tipping points.',
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
        response: 'The recursive factorial function you\'ve provided is correct and works as expected for calculating factorials. However, there are some optimizations and improvements that could be made:\n\n1. **Stack Overflow Protection**: Your function will cause a stack overflow for large values of n (typically n > 1000 on most systems). Consider adding a parameter limit check.\n\n2. **Error Handling**: The function doesn\'t handle negative inputs gracefully. Factorial is not defined for negative numbers.\n\n3. **Performance**: Recursive implementations are elegant but less efficient than iterative solutions due to function call overhead.\n\nHere\'s an improved version:\n\n```python\ndef factorial(n):\n    # Error handling for negative inputs\n    if not isinstance(n, int):\n        raise TypeError("Input must be an integer")\n    if n < 0:\n        raise ValueError("Factorial is not defined for negative numbers")\n    \n    # Base case\n    if n == 0 or n == 1:\n        return 1\n    \n    # Stack overflow protection\n    if n > 1000:\n        raise OverflowError("Input too large, may cause stack overflow")\n        \n    # Recursive case\n    return n * factorial(n-1)\n\n# More efficient iterative implementation\ndef factorial_iterative(n):\n    if not isinstance(n, int):\n        raise TypeError("Input must be an integer")\n    if n < 0:\n        raise ValueError("Factorial is not defined for negative numbers")\n        \n    result = 1\n    for i in range(1, n + 1):\n        result *= i\n        \n    return result\n```\n\nThe iterative version is more efficient for large inputs and won\'t cause stack overflow issues.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isFavorite: true,
      ),
      StudySession(
        type: SessionType.writingAssistant,
        title: 'Research Paper Summary',
        content: 'I need to summarize a research paper on quantum computing',
        response: 'This research paper provides a comprehensive overview of recent advancements in quantum computing, focusing on the development of quantum algorithms and their potential applications in solving complex computational problems. The authors discuss the fundamental principles of quantum mechanics that enable quantum computing, including superposition and entanglement, and explain how these principles are leveraged in quantum bits (qubits) to perform calculations exponentially faster than classical computers for certain problems. The paper examines various quantum computing architectures, such as superconducting circuits, trapped ions, and topological qubits, comparing their strengths and limitations. A significant portion of the research is dedicated to quantum error correction techniques, acknowledging that quantum decoherence remains one of the primary challenges in building practical quantum computers. The authors also review recent experimental results, highlighting milestone achievements like quantum supremacy demonstrations and the implementation of Shor\'s algorithm for factoring small numbers. The paper concludes by discussing potential applications of quantum computing in cryptography, drug discovery, materials science, and optimization problems, while cautioning that many practical applications are still years away due to the need for more stable qubits and improved error correction methods.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      StudySession(
        type: SessionType.codeHelper,
        title: 'JavaScript Function Optimization',
        content: 'function fibonacci(n) {\n  if (n <= 1) return n;\n  return fibonacci(n-1) + fibonacci(n-2);\n}',
        response: 'Your recursive Fibonacci implementation works correctly but has significant performance issues. The time complexity is O(2^n), which becomes extremely slow for larger values of n due to redundant calculations. Here\'s an analysis and optimization:\n\n**Issues in Current Code:**\n1. Exponential time complexity (O(2^n))\n2. Redundant calculations - fibonacci(5) will recalculate fibonacci(3) multiple times\n3. Stack overflow risk for larger inputs\n\n**Optimized Solutions:**\n\n1. **Memoization (Top-Down Dynamic Programming):**\n```javascript\nfunction fibonacci(n, memo = {}) {\n  if (n in memo) return memo[n];\n  if (n <= 1) return n;\n  memo[n] = fibonacci(n-1, memo) + fibonacci(n-2, memo);\n  return memo[n];\n}\n```\n\n2. **Iterative (Bottom-Up Dynamic Programming):**\n```javascript\nfunction fibonacci(n) {\n  if (n <= 1) return n;\n  \n  let fib = [0, 1];\n  for (let i = 2; i <= n; i++) {\n    fib[i] = fib[i-1] + fib[i-2];\n  }\n  \n  return fib[n];\n}\n```\n\n3. **Space-Optimized Iterative:**\n```javascript\nfunction fibonacci(n) {\n  if (n <= 1) return n;\n  \n  let prev = 0, curr = 1;\n  for (let i = 2; i <= n; i++) {\n    let next = prev + curr;\n    prev = curr;\n    curr = next;\n  }\n  \n  return curr;\n}\n```\n\nThe iterative solutions have a time complexity of O(n) and space complexity of O(1) for the optimized version, making them vastly more efficient for larger inputs.\n\nFor very large n values, consider using BigInt for arbitrary precision.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      StudySession(
        type: SessionType.questionSolver,
        title: 'Photosynthesis Process',
        content: 'Subject: Biology',
        response: 'Photosynthesis is the process by which green plants, algae, and some bacteria convert light energy into chemical energy. Here\'s a detailed explanation:\n\n**The Basic Equation:**\n6CO₂ + 6H₂O + Light Energy → C₆H₁₂O₆ (Glucose) + 6O₂\n\n**Main Stages:**\n\n1. **Light-Dependent Reactions:**\n   - Occur in the thylakoid membrane\n   - Chlorophyll and other pigments capture light energy\n   - Water molecules are split (photolysis), releasing oxygen\n   - ATP and NADPH are produced as energy carriers\n   - Products: ATP, NADPH, and O₂\n\n2. **Calvin Cycle (Light-Independent Reactions):**\n   - Occurs in the stroma\n   - CO₂ is fixed (incorporated into organic molecules)\n   - Uses ATP and NADPH from light-dependent reactions\n   - RuBisCO enzyme catalyzes the first major step\n   - Products: Glucose and other carbohydrates\n\n**Factors Affecting Photosynthesis:**\n- Light intensity\n- CO₂ concentration\n- Temperature\n- Water availability\n- Chlorophyll content\n\nPlants use the glucose produced through photosynthesis for:\n- Energy production (cellular respiration)\n- Growth and development\n- Storage (as starch)\n- Production of other organic compounds\n\nThis process is fundamental to life on Earth as it produces oxygen and forms the base of food chains in most ecosystems.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        isFavorite: true,
      ),
    ];
  }
}