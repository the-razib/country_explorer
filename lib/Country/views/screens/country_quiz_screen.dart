import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import 'dart:math';

/// Quiz game screen for testing country knowledge
class CountryQuizScreen extends StatefulWidget {
  const CountryQuizScreen({Key? key}) : super(key: key);

  @override
  State<CountryQuizScreen> createState() => _CountryQuizScreenState();
}

class _CountryQuizScreenState extends State<CountryQuizScreen> {
  final controller = Get.find<CountryController>();
  
  // Quiz state
  int currentQuestion = 0;
  int score = 0;
  bool isAnswered = false;
  int? selectedAnswer;
  late List<QuizQuestion> questions;
  
  // Quiz types
  final List<QuizType> quizTypes = [
    QuizType.flagToCountry,
    QuizType.countryToCapital,
    QuizType.countryToPopulation,
    QuizType.countryToCurrency,
    QuizType.countryToRegion,
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Quiz'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Score: $score/${questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: currentQuestion >= questions.length
          ? _buildResultScreen()
          : _buildQuestionScreen(),
    );
  }

  /// Generate quiz questions
  void _generateQuestions() {
    final random = Random();
    questions = [];
    final availableCountries = List<Country>.from(controller.countries);
    
    for (int i = 0; i < 10; i++) {
      if (availableCountries.isEmpty) break;
      
      final quizType = quizTypes[random.nextInt(quizTypes.length)];
      final correctCountry = availableCountries.removeAt(
        random.nextInt(availableCountries.length),
      );
      
      // Generate wrong answers
      final wrongAnswers = <Country>[];
      final remainingCountries = List<Country>.from(controller.countries);
      remainingCountries.removeWhere((c) => c.name.common == correctCountry.name.common);
      
      while (wrongAnswers.length < 3 && remainingCountries.isNotEmpty) {
        final wrongCountry = remainingCountries.removeAt(
          random.nextInt(remainingCountries.length),
        );
        wrongAnswers.add(wrongCountry);
      }
      
      questions.add(QuizQuestion(
        type: quizType,
        correctCountry: correctCountry,
        wrongAnswers: wrongAnswers,
        correctAnswerIndex: random.nextInt(4),
      ));
    }
  }

  /// Build question screen
  Widget _buildQuestionScreen() {
    final question = questions[currentQuestion];
    final answers = question.getShuffledAnswers();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (currentQuestion + 1) / questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Question number
          Text(
            'Question ${currentQuestion + 1} of ${questions.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Question content
          Expanded(
            child: Column(
              children: [
                _buildQuestionContent(question),
                const SizedBox(height: 32),
                
                // Answer options
                Expanded(
                  child: ListView.builder(
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      return _buildAnswerOption(question, answers[index], index);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Next button
          if (isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  currentQuestion + 1 >= questions.length ? 'Finish Quiz' : 'Next Question',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build question content based on type
  Widget _buildQuestionContent(QuizQuestion question) {
    switch (question.type) {
      case QuizType.flagToCountry:
        return Column(
          children: [
            const Text(
              'Which country does this flag belong to?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: question.correctCountry.flags.png,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          ],
        );
        
      case QuizType.countryToCapital:
        return Column(
          children: [
            const Text(
              'What is the capital of',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              question.correctCountry.name.common,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              '?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        );
        
      default:
        return Text(
          question.getQuestionText(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        );
    }
  }

  /// Build answer option
  Widget _buildAnswerOption(QuizQuestion question, String answer, int index) {
    final isCorrect = answer == question.getCorrectAnswer();
    final isSelected = selectedAnswer == index;
    
    Color? backgroundColor;
    Color? textColor;
    IconData? icon;
    
    if (isAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green[100];
        textColor = Colors.green[800];
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[100];
        textColor = Colors.red[800];
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
      textColor = Theme.of(context).primaryColor;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAnswered ? null : () => _selectAnswer(index, isCorrect),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isAnswered && isCorrect
                      ? Colors.green
                      : isAnswered
                          ? Colors.red
                          : Theme.of(context).primaryColor)
                  : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isSelected
                    ? (isAnswered && isCorrect
                        ? Colors.green
                        : isAnswered
                            ? Colors.red
                            : Theme.of(context).primaryColor)
                    : Colors.grey[300],
                child: icon != null
                    ? Icon(icon, color: Colors.white, size: 20)
                    : Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build result screen
  Widget _buildResultScreen() {
    final percentage = (score / questions.length * 100).round();
    String title;
    String subtitle;
    IconData icon;
    Color color;
    
    if (percentage >= 80) {
      title = 'Excellent!';
      subtitle = 'You\'re a geography expert!';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (percentage >= 60) {
      title = 'Good Job!';
      subtitle = 'You know your countries well!';
      icon = Icons.thumb_up;
      color = Colors.green;
    } else if (percentage >= 40) {
      title = 'Not Bad!';
      subtitle = 'Keep exploring to learn more!';
      icon = Icons.sentiment_satisfied;
      color = Colors.orange;
    } else {
      title = 'Keep Learning!';
      subtitle = 'Practice makes perfect!';
      icon = Icons.school;
      color = Colors.blue;
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: color),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Final Score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$score / ${questions.length}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Back to Explorer'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _restartQuiz,
                  child: const Text('Play Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Select answer
  void _selectAnswer(int index, bool isCorrect) {
    setState(() {
      selectedAnswer = index;
      isAnswered = true;
      if (isCorrect) score++;
    });
  }

  /// Go to next question
  void _nextQuestion() {
    setState(() {
      currentQuestion++;
      selectedAnswer = null;
      isAnswered = false;
    });
  }

  /// Restart quiz
  void _restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      isAnswered = false;
      selectedAnswer = null;
      _generateQuestions();
    });
  }
}

/// Quiz question types
enum QuizType {
  flagToCountry,
  countryToCapital,
  countryToPopulation,
  countryToCurrency,
  countryToRegion,
}

/// Quiz question model
class QuizQuestion {
  final QuizType type;
  final Country correctCountry;
  final List<Country> wrongAnswers;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.type,
    required this.correctCountry,
    required this.wrongAnswers,
    required this.correctAnswerIndex,
  });

  /// Get question text based on type
  String getQuestionText() {
    switch (type) {
      case QuizType.flagToCountry:
        return 'Which country does this flag belong to?';
      case QuizType.countryToCapital:
        return 'What is the capital of ${correctCountry.name.common}?';
      case QuizType.countryToPopulation:
        return 'What is the approximate population of ${correctCountry.name.common}?';
      case QuizType.countryToCurrency:
        return 'What is the main currency of ${correctCountry.name.common}?';
      case QuizType.countryToRegion:
        return 'Which region does ${correctCountry.name.common} belong to?';
    }
  }

  /// Get correct answer based on type
  String getCorrectAnswer() {
    switch (type) {
      case QuizType.flagToCountry:
        return correctCountry.name.common;
      case QuizType.countryToCapital:
        return correctCountry.capital.isNotEmpty ? correctCountry.capital.first : 'No capital';
      case QuizType.countryToPopulation:
        return correctCountry.formattedPopulation;
      case QuizType.countryToCurrency:
        return correctCountry.currencies.isNotEmpty
            ? correctCountry.currencies.values.first.name
            : 'No currency';
      case QuizType.countryToRegion:
        return correctCountry.region;
    }
  }

  /// Get shuffled answers for multiple choice
  List<String> getShuffledAnswers() {
    final answers = <String>[];
    
    // Add wrong answers
    for (final country in wrongAnswers) {
      switch (type) {
        case QuizType.flagToCountry:
          answers.add(country.name.common);
          break;
        case QuizType.countryToCapital:
          answers.add(country.capital.isNotEmpty ? country.capital.first : 'No capital');
          break;
        case QuizType.countryToPopulation:
          answers.add(country.formattedPopulation);
          break;
        case QuizType.countryToCurrency:
          answers.add(country.currencies.isNotEmpty
              ? country.currencies.values.first.name
              : 'No currency');
          break;
        case QuizType.countryToRegion:
          answers.add(country.region);
          break;
      }
    }
    
    // Insert correct answer at the specified index
    answers.insert(correctAnswerIndex, getCorrectAnswer());
    
    return answers;
  }
}
