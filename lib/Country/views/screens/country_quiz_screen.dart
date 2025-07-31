import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/country_controller.dart';
import '../../models/country_model.dart';
import 'dart:math';

/// Modern quiz game screen for testing country knowledge
class CountryQuizScreen extends StatefulWidget {
  const CountryQuizScreen({Key? key}) : super(key: key);

  @override
  State<CountryQuizScreen> createState() => _CountryQuizScreenState();
}

class _CountryQuizScreenState extends State<CountryQuizScreen>
    with TickerProviderStateMixin {
  final controller = Get.find<CountryController>();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
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
    
    /// Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _generateQuestions();
    
    /// Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: currentQuestion >= questions.length
              ? _buildResultsScreen()
              : _buildQuizScreen(),
        ),
      ),
    );
  }

  /// Modern loading screen with glass-morphism effect
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Preparing Quiz...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Loading questions for you',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern quiz screen with enhanced animations
  Widget _buildQuizScreen() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            /// Modern header with progress
            _buildModernHeader(),
            
            /// Question content
            Expanded(
              child: _buildQuestionContent(),
            ),
            
            /// Answer options
            _buildAnswerOptions(),
            
            /// Next button
            if (isAnswered) _buildNextButton(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Modern header with glass-morphism effect
  Widget _buildModernHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Progress bar
          Row(
            children: [
              const Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (currentQuestion + 1) / questions.length,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${currentQuestion + 1}/${questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          /// Score display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getQuestionTypeText(questions[currentQuestion].type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Question content with modern styling
  Widget _buildQuestionContent() {
    final question = questions[currentQuestion];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildQuestionTypeContent(question),
    );
  }

  /// Build content based on question type
  Widget _buildQuestionTypeContent(QuizQuestion question) {
    switch (question.type) {
      case QuizType.flagToCountry:
        return Column(
          children: [
            const Text(
              'Which country does this flag belong to?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              height: 160,
              width: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: question.correctCountry.flags.png,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(
                      Icons.flag_rounded,
                      size: 48,
                      color: Color(0xFF64748B),
                    ),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                question.correctCountry.name.common,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '?',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Color(0xFF667EEA),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
        
      default:
        return Text(
          question.getQuestionText(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  /// Modern answer options with enhanced styling
  Widget _buildAnswerOptions() {
    final question = questions[currentQuestion];
    final answers = question.getShuffledAnswers();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          answers.length,
          (index) => _buildAnswerOption(answers[index], index),
        ),
      ),
    );
  }

  /// Modern answer option
  Widget _buildAnswerOption(String answer, int index) {
    final question = questions[currentQuestion];
    final isCorrect = answer == question.getCorrectAnswer();
    final isSelected = selectedAnswer == index;
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;
    
    if (isAnswered) {
      if (isCorrect) {
        backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
        icon = Icons.cancel_rounded;
      } else {
        backgroundColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF64748B);
      }
    } else {
      if (isSelected) {
        backgroundColor = Colors.white.withOpacity(0.2);
        borderColor = Colors.white;
        textColor = Colors.white;
      } else {
        backgroundColor = Colors.white.withOpacity(0.1);
        borderColor = Colors.white.withOpacity(0.3);
        textColor = Colors.white;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : () => _selectAnswer(index, isCorrect),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: isSelected && !isAnswered
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                /// Option indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: icon != null
                        ? Icon(icon, color: Colors.white, size: 18)
                        : Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                /// Answer text
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern next button
  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _nextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF667EEA),
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            currentQuestion + 1 >= questions.length ? 'Finish Quiz' : 'Next Question',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// Modern results screen
  Widget _buildResultsScreen() {
    final percentage = (score / questions.length * 100).round();
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You scored $score out of ${questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResultButton(
                  'Try Again',
                  Icons.refresh_rounded,
                  _restartQuiz,
                ),
                _buildResultButton(
                  'Home',
                  Icons.home_rounded,
                  () => Get.back(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Modern result button
  Widget _buildResultButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF667EEA),
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
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

  /// Select answer
  void _selectAnswer(int answerIndex, bool isCorrect) {
    setState(() {
      selectedAnswer = answerIndex;
      isAnswered = true;
      if (isCorrect) {
        score++;
      }
    });
  }

  /// Move to next question
  void _nextQuestion() {
    if (currentQuestion + 1 >= questions.length) {
      // Quiz finished
      return;
    }
    
    setState(() {
      currentQuestion++;
      isAnswered = false;
      selectedAnswer = null;
    });
    
    // Reset and restart animations
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  /// Restart quiz
  void _restartQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      isAnswered = false;
      selectedAnswer = null;
    });
    
    _generateQuestions();
    
    // Reset animations
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  /// Get question type text
  String _getQuestionTypeText(QuizType type) {
    switch (type) {
      case QuizType.flagToCountry:
        return 'FLAG QUIZ';
      case QuizType.countryToCapital:
        return 'CAPITAL QUIZ';
      case QuizType.countryToPopulation:
        return 'POPULATION QUIZ';
      case QuizType.countryToCurrency:
        return 'CURRENCY QUIZ';
      case QuizType.countryToRegion:
        return 'REGION QUIZ';
    }
  }
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
        return 'What is the population of ${correctCountry.name.common}?';
      case QuizType.countryToCurrency:
        return 'What is the currency of ${correctCountry.name.common}?';
      case QuizType.countryToRegion:
        return 'Which region is ${correctCountry.name.common} in?';
    }
  }

  /// Get correct answer based on type
  String getCorrectAnswer() {
    switch (type) {
      case QuizType.flagToCountry:
        return correctCountry.name.common;
      case QuizType.countryToCapital:
        return correctCountry.capital.isNotEmpty 
            ? correctCountry.capital.first 
            : 'No capital';
      case QuizType.countryToPopulation:
        return correctCountry.population.toString();
      case QuizType.countryToCurrency:
        return correctCountry.currencies.isNotEmpty
            ? correctCountry.currencies.values.first.name
            : 'No currency';
      case QuizType.countryToRegion:
        return correctCountry.region;
    }
  }

  /// Get shuffled answers
  List<String> getShuffledAnswers() {
    final wrongAnswersStrings = <String>[];
    
    // Generate wrong answers based on type
    for (final country in wrongAnswers) {
      String wrongAnswer;
      switch (type) {
        case QuizType.flagToCountry:
          wrongAnswer = country.name.common;
          break;
        case QuizType.countryToCapital:
          wrongAnswer = country.capital.isNotEmpty 
              ? country.capital.first 
              : 'No capital';
          break;
        case QuizType.countryToPopulation:
          wrongAnswer = country.population.toString();
          break;
        case QuizType.countryToCurrency:
          wrongAnswer = country.currencies.isNotEmpty
              ? country.currencies.values.first.name
              : 'No currency';
          break;
        case QuizType.countryToRegion:
          wrongAnswer = country.region;
          break;
      }
      wrongAnswersStrings.add(wrongAnswer);
    }
    
    // Add correct answer at specified index
    wrongAnswersStrings.insert(correctAnswerIndex, getCorrectAnswer());
    
    return wrongAnswersStrings;
  }
}

/// Quiz types enum
enum QuizType {
  flagToCountry,
  countryToCapital,
  countryToPopulation,
  countryToCurrency,
  countryToRegion,
}
