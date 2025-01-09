class QuestionRequest {
  final String question;

  QuestionRequest({required this.question});

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'question': question,
    };
  }
}
class AnswerResponse {
  final String answer;

  AnswerResponse({required this.answer});

  // Convert from JSON
  factory AnswerResponse.fromJson(Map<String, dynamic> json) {
    return AnswerResponse(
      answer: json['answer'],
    );
  }
}
