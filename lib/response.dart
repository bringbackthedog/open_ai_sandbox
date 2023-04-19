import 'package:flutter/foundation.dart';

/// decode
/// ```
/// {"id":"chatcmpl-75fIj9skGDUebTiCc56hf2knVOY0N","object":"chat.completion","created":1681584757,"model":"gpt-3.5-turbo-0301","usage":{"prompt_tokens":13,"completion_tokens":10,"total_tokens":23},"choices":[{"message":{"role":"assistant","content":"The square root of 36 is 6."},"finish_reason":"stop","index":0}]}
/// ```
class OpenAIResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final Usage usage;
  final List<Choice> choices;

  OpenAIResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.usage,
    required this.choices,
  });

  factory OpenAIResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      usage: Usage.fromJson(json['usage']),
      choices:
          List<Choice>.from(json['choices'].map((x) => Choice.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'model': model,
      'usage': usage.toJson(),
      'choices': List<dynamic>.from(choices.map((x) => x.toJson())),
    };
  }

  @override
  String toString() {
    return 'Response(id: $id, object: $object, created: $created, model: $model, usage: $usage, choices: $choices)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OpenAIResponse &&
        other.id == id &&
        other.object == object &&
        other.created == created &&
        other.model == model &&
        other.usage == usage &&
        listEquals(other.choices, choices);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        object.hashCode ^
        created.hashCode ^
        model.hashCode ^
        usage.hashCode ^
        choices.hashCode;
  }
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }

  @override
  String toString() {
    return 'Usage(promptTokens: $promptTokens, completionTokens: $completionTokens, totalTokens: $totalTokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Usage &&
        other.promptTokens == promptTokens &&
        other.completionTokens == completionTokens &&
        other.totalTokens == totalTokens;
  }

  @override
  int get hashCode {
    return promptTokens.hashCode ^
        completionTokens.hashCode ^
        totalTokens.hashCode;
  }
}

class Choice {
  final Message message;
  final String finishReason;
  final int index;

  Choice({
    required this.message,
    required this.finishReason,
    required this.index,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      message: Message.fromJson(json['message']),
      finishReason: json['finish_reason'],
      index: json['index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
      'finish_reason': finishReason,
      'index': index,
    };
  }

  @override
  String toString() {
    return 'Choice(message: $message, finishReason: $finishReason, index: $index)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Choice &&
        other.message == message &&
        other.finishReason == finishReason &&
        other.index == index;
  }

  @override
  int get hashCode {
    return message.hashCode ^ finishReason.hashCode ^ index.hashCode;
  }
}

class Message {
  final String role;
  final String content;

  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Message(role: $role, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.role == role && other.content == content;
  }

  @override
  int get hashCode {
    return role.hashCode ^ content.hashCode;
  }
}
