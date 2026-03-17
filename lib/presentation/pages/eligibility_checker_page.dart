import 'package:flutter/material.dart';
import 'package:raktasetu/core/theme/app_theme.dart';

/// Eligibility Question Model
class EligibilityQuestion {
  final int id;
  final String question;
  final String? disclaimer;
  bool? answer;

  EligibilityQuestion({
    required this.id,
    required this.question,
    this.disclaimer,
    this.answer,
  });
}

/// Blood Donation Eligibility Checker Page
class EligibilityCheckerPage extends StatefulWidget {
  const EligibilityCheckerPage({Key? key}) : super(key: key);

  @override
  State<EligibilityCheckerPage> createState() => _EligibilityCheckerPageState();
}

class _EligibilityCheckerPageState extends State<EligibilityCheckerPage> {
  late List<EligibilityQuestion> questions;
  int _currentQuestionIndex = 0;
  bool _showFinalResult = false;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    questions = [
      EligibilityQuestion(
        id: 1,
        question: 'Are you between 18 and 65 years old?',
        disclaimer: 'Age requirement for blood donation',
      ),
      EligibilityQuestion(
        id: 2,
        question: 'Do you weigh at least 50 kg (110 lbs)?',
        disclaimer: 'Minimum body weight is required for safe donation',
      ),
      EligibilityQuestion(
        id: 3,
        question: 'Have you ever had hepatitis or jaundice?',
        disclaimer: 'These conditions make you ineligible to donate',
      ),
      EligibilityQuestion(
        id: 4,
        question: 'Have you been diagnosed with HIV or AIDS?',
        disclaimer: 'HIV-positive individuals cannot donate blood',
      ),
      EligibilityQuestion(
        id: 5,
        question: 'Have you had any surgery in the last 6 months?',
        disclaimer: 'You may need to wait 6 months after surgery',
      ),
      EligibilityQuestion(
        id: 6,
        question: 'Are you pregnant or breastfeeding?',
        disclaimer: 'Pregnant women should wait until 6 weeks after delivery',
      ),
      EligibilityQuestion(
        id: 7,
        question:
            'Have you received a tattoo or piercing in the last 12 months?',
        disclaimer: 'Recent tattoos/piercings require waiting period',
      ),
      EligibilityQuestion(
        id: 8,
        question: 'Do you have high blood pressure or heart disease?',
        disclaimer: 'Some conditions may affect eligibility',
      ),
      EligibilityQuestion(
        id: 9,
        question: 'Have you taken antibiotics in the last 48 hours?',
        disclaimer: 'Wait 48 hours after completing antibiotic course',
      ),
      EligibilityQuestion(
        id: 10,
        question: 'Are you feeling healthy today?',
        disclaimer: 'You should be in good health on the donation day',
      ),
    ];
  }

  void _answerQuestion(bool answer) {
    setState(() {
      questions[_currentQuestionIndex].answer = answer;
    });

    // After a short delay, move to next question or show results
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_currentQuestionIndex < questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        _calculateEligibility();
      }
    });
  }

  void _calculateEligibility() {
    setState(() {
      _showFinalResult = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _showFinalResult = false;
      for (var question in questions) {
        question.answer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eligibility Checker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: _showFinalResult ? _buildResultScreen() : _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    final currentQuestion = questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / questions.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Premium Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.bloodRed, AppTheme.bloodRed.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Can You Donate?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick eligibility assessment',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1}/${questions.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Question Card
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Text(
                  currentQuestion.question,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Disclaimer if available
                if (currentQuestion.disclaimer != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: Colors.blue[600],
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            currentQuestion.disclaimer!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else
                  const SizedBox(height: 40),

                // Answer Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF198754),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'No',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final allAnswered = questions.every((q) => q.answer != null);
    final disqualified = questions.any((q) {
      final answer = q.answer;
      if (answer == null) return false;
      // Questions 3-9 are disqualifying if YES
      return (q.id >= 3 && q.id <= 9 && answer == true) ||
          // Questions 1, 2, 10 are disqualifying if NO
          ((q.id == 1 || q.id == 2 || q.id == 10) && answer == false);
    });

    final isEligible = allAnswered && !disqualified;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Result Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEligible
                    ? [const Color(0xFF198754), const Color(0xFF155347)]
                    : [const Color(0xFFDC3545), const Color(0xFFC72C30)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEligible ? Icons.check_circle : Icons.cancel_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEligible ? 'You\'re Eligible!' : 'Not Eligible Now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEligible
                        ? 'You can donate blood. Schedule an appointment today!'
                        : 'You don\'t meet current requirements. Please consult a doctor.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assessment Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Summary Cards
                ...questions.map((q) {
                  final hasAnswer = q.answer != null;
                  final isPass = _isAnswerPass(q);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: !hasAnswer
                          ? Colors.grey[50]
                          : isPass
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !hasAnswer
                            ? Colors.grey[300]!
                            : isPass
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !hasAnswer
                              ? Icons.circle_outlined
                              : isPass
                              ? Icons.check_circle
                              : Icons.cancel_rounded,
                          color: !hasAnswer
                              ? Colors.grey[400]
                              : isPass
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.question,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasAnswer
                                    ? q.answer == true
                                          ? 'Yes'
                                          : 'No'
                                    : 'Skipped',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Action Buttons
                if (isEligible) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Appointment scheduled!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Schedule Donation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF198754),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC3545).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFDC3545).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: const Color(0xFFDC3545),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Consult with a healthcare provider for personalized advice.',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFDC3545),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resetQuiz,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Take Quiz Again'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isAnswerPass(EligibilityQuestion q) {
    final answer = q.answer;
    if (answer == null) return false;

    // Questions 3-9 are disqualifying if YES
    if (q.id >= 3 && q.id <= 9) {
      return answer == false;
    }
    // Questions 1, 2, 10 are disqualifying if NO
    return answer == true;
  }
}
