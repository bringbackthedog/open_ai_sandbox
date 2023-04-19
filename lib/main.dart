import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_ai_sandbox_app/open_ai_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

late FlutterTts flutterTts;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  flutterTts = FlutterTts();
  await flutterTts.awaitSpeakCompletion(true);
  await flutterTts.setLanguage("en-US");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

///
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();

  String _response = '';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: const Text('OpenAI Sandbox'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a prompt',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a prompt';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      bool formValid =
                          _formKey.currentState?.validate() ?? false;
                      if (!formValid) return;

                      final response =
                          await OpenAiClient.req(_promptController.text);

                      _response = response;
                      flutterTts.speak(_response);

                      setState(() {});
                    },
                    child: const Text('Submit'),
                  ),

                  const SizedBox(height: 20),

                  StreamBuilder<SpeechStatus>(
                    stream: SpeechListener.speechStatusStream,
                    initialData: SpeechStatus.done,
                    builder: (context, AsyncSnapshot<SpeechStatus> snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final SpeechStatus? status = snapshot.data;

                      switch (status) {
                        case SpeechStatus.done:
                          return IconButton(
                            icon: const Icon(Icons.multitrack_audio_sharp),
                            onPressed: () async {
                              if (status != SpeechStatus.listening) {
                                try {
                                  await SpeechListener.listen(
                                    controller: _promptController,
                                  );

                                  if (_promptController.text.isEmpty) {
                                    throw SpeechListenerNoSpeechError();
                                  }
                                } catch (e) {
                                  debugPrint('Error listening: $e');
                                }

                                if (_promptController.text.isEmpty) {
                                  return;
                                }

                                final response = await OpenAiClient.req(
                                    _promptController.text);
                                _response = response;

                                flutterTts.speak(_response);

                                setState(() {});
                              } else {
                                await SpeechListener.stop();
                              }
                            },
                          );

                        case SpeechStatus.listening:
                          return IconButton(
                            icon: const Icon(Icons.stop),
                            onPressed: () async {
                              await SpeechListener.stop();
                            },
                          );

                        case SpeechStatus.notListening:
                          // loading icon
                          return const CircularProgressIndicator();

                        default:
                          debugPrint('Unknown speech status: $status');
                          return const SizedBox.shrink();
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  //
                  // Open AI response
                  //
                  Text(
                    _response,
                    style: const TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 20),

                  //
                  // Clear button
                  //
                  Visibility(
                    visible: _response.isNotEmpty,
                    child: ElevatedButton(
                      onPressed: () {
                        _promptController.clear();
                        _response = '';
                        setState(() {});
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SpeechListenerError implements Exception {
  final String? message;

  SpeechListenerError(this.message);

  @override
  String toString() {
    return 'SpeechListenerError: ${message ?? ''}';
  }
}

class SpeechListenerNoSpeechError extends SpeechListenerError {
  SpeechListenerNoSpeechError([String? message]) : super(message);
}

class SpeechListenerPermissionError extends SpeechListenerError {
  SpeechListenerPermissionError([String? message]) : super(message);
}

enum SpeechStatus {
  listening,
  notListening,
  done,
}

class SpeechListener {
  stt.SpeechToText speech = stt.SpeechToText();

  SpeechListener._();
  static final SpeechListener _instance = SpeechListener._();
  static SpeechListener get instance => _instance;

  void onStatus(String status) {
    debugPrint('DEBUG: onStatus: $status');
    switch (status) {
      case 'notListening':
        _speechStatusController.add(SpeechStatus.notListening);
        break;
      case 'listening':
        _speechStatusController.add(SpeechStatus.listening);
        break;
      case 'done':
        _speechStatusController.add(SpeechStatus.done);
        break;
      default:
        _speechStatusController.add(SpeechStatus.notListening);
        break;
    }
  }

  final StreamController<SpeechStatus> _speechStatusController =
      StreamController.broadcast();

  static Stream<SpeechStatus> get speechStatusStream =>
      instance._speechStatusController.stream;

  static Future<bool> initialize() async {
    bool available = await instance.speech.initialize(
      onStatus: instance.onStatus,
      onError: (val) => debugPrint('onError: $val'),
    );

    return available;
  }

  /// Use the return value to get the input as a String when the user is done
  /// speaking or use the [controller] to get the input as the user is speaking.
  static Future<String> listen({
    TextEditingController? controller,
  }) async {
    bool available = await instance.speech.initialize(
      onStatus: instance.onStatus,
      onError: (val) => debugPrint('onError: $val'),
    );

    var input = '';

    if (available) {
      await instance.speech.listen(
        onResult: (result) {
          debugPrint("DEBUG onResult: ${result.recognizedWords}");

          input = result.recognizedWords;

          controller?.text = result.recognizedWords;
        },
        listenMode: stt.ListenMode.search,
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 2),
        cancelOnError: true,
      );

      await SpeechListener.onDone();

      debugPrint(
        'Done listening. Got result: '
        '$input',
      );

      return input;
    } else {
      String err = "The user has denied the use of speech recognition.";
      debugPrint(err);
      throw SpeechListenerPermissionError(err);
    }
  }

  /// Returns true if the speech is done, false otherwise.
  static Future<bool> onDone() async {
    await for (final status in speechStatusStream) {
      if (status == SpeechStatus.done) {
        return true;
      }
    }

    return false;
  }

  static Future<void> stop() async {
    await instance.speech.stop();
  }
}
