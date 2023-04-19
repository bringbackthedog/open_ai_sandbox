// http
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_ai_sandbox_app/response.dart';

class OpenAiClient {
  //
  static Future<String> req(String prompt) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}'
    };
    var request = http.Request(
        'POST', Uri.parse('https://api.openai.com/v1/chat/completions'));

    request.body = json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": prompt,
        }
      ],
      "temperature": 0.7
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString());

      var openAIresponse = OpenAIResponse.fromJson(data);
      debugPrint(openAIresponse.toString());

      return OpenAIResponse.fromJson(data).choices[0].message.content;
    } else {
      return response.reasonPhrase ?? 'Error';
    }
  }
}
