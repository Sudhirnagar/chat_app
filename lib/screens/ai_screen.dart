import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../helper/dialogs.dart';
import '../main.dart';
import '../models/message.dart';
import '../widgets/ai_message_card.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _textC = TextEditingController();
  final _scrollC = ScrollController();

  final _list = <AiMessage>[
    AiMessage(msg: 'Hello, How can I help you?', msgType: MessageType.bot)
  ];

  Future<void> _askQuestion() async {
    final text = _textC.text.trim();
    if (text.isEmpty) {
      Dialogs.showSnackbar(context, 'Ask Something!');
      return;
    }

    // Add user's message and a bot placeholder to the list
    setState(() {
      _list.add(AiMessage(msg: text, msgType: MessageType.user));
      _list.add(AiMessage(msg: '', msgType: MessageType.bot));
    });
    _scrollDown();

    final prompt = text;
    _textC.text = '';

    // Check for keywords to decide if it's an image request
    final isImageRequest = prompt.toLowerCase().contains('generate image') ||
        prompt.toLowerCase().contains('create image') ||
        prompt.toLowerCase().contains('draw an image');

    // Get the answer from Gemini
    final result = await _getAnswer(prompt, isImageRequest: isImageRequest);

    // Update the bot's message in the list with the actual response
    setState(() {
      _list.removeLast(); // Remove the placeholder
      _list.add(AiMessage(msg: result, msgType: MessageType.bot));
    });
    _scrollDown();
  }

  void _scrollDown() {
    _scrollC.animateTo(_scrollC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  Future<String> _getAnswer(final String question,
      {bool isImageRequest = false}) async {
    try {
      // IMPORTANT: Never hardcode API keys in your app. Use environment variables.
      const apiKey = 'AIzaSyCzTUg-7obZj60DtwRVkFj71tHm4SWWE6Y'; // Replace with your actual key

      if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
        return 'Gemini API Key is not set!\nPlease update it in ai_screen.dart';
      }

      final model = GenerativeModel(
        model: 'gemini-2.5-pro',
        apiKey: apiKey,
      );

      // This is the special prompt for image generation
      final fullPrompt = isImageRequest
          ? 'Generate a high-quality, royalty-free image URL from a public source like Pexels or Unsplash for the following prompt. Respond with ONLY the direct image URL (ending in .png or .jpg) and nothing else. Prompt: "$question"'
          : question;

      final content = [Content.text(fullPrompt)];
      final res = await model.generateContent(content, safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      ]);

      log('res: ${res.text}');
      return res.text!.trim();
    } catch (e) {
      log('getAnswerGeminiE: $e');
      return 'Something went wrong (Please try again)';
    }
  }

  @override
  void dispose() {
    _textC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your AI Assistant'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          Expanded(
              child: TextFormField(
            controller: _textC,
            textAlign: TextAlign.center,
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                filled: true,
                isDense: true,
                hintText: 'Ask me anything...',
                hintStyle: const TextStyle(fontSize: 14),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)))),
          )),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            child: IconButton(
              onPressed: _askQuestion,
              icon: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 28),
            ),
          )
        ]),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _scrollC,
        padding:
            EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .1),
        itemCount: _list.length,
        itemBuilder: (ctx, i) => AiMessageCard(message: _list[i]),
      ),
    );
  }
}