import 'package:flutter/material.dart';
import 'package:nowuseeme/ar_screen.dart';
import 'package:nowuseeme/card_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardScreen(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Amara',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String? inputText;

  HomePage({this.inputText});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  double _confidence = 1.0;
  late AudioCache _audioCache;
  bool _readyToSpeak = false;
  bool _showFAB = false;
  IconData _fabIcon = Icons.mic_none;
  late Widget _fabDestination;

  AudioPlayer player = AudioPlayer();
  AudioPlayer _backgroundPlayer = AudioPlayer();  // Background player instance

  final _googleGenerativeAI = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyBerf92agg8GFIp0g4AiCO3mRlsRFFKs6E'
  );

  List<String> _conversationHistory = [];
  String _script = """Rules:

Stay within the script. Do not exit the script under any circumstances.
Incremental acting. Do not recite the entire script at once. Act out the script incrementally, ensuring each part is delivered only when prompted by the player's actions.
Role:

Identity: You are Amara, a young scribe from the ancient kingdom of Nubia. You were trapped in a magical artifact in ancient times and now find yourself trapped within this phone.

Interaction: The player can only interact with you through the phone.

Warning: If the player fails to solve the riddles, you will hunt them.

Backstory:

Setting: Ancient kingdom of Nubia, city of Meroë, 320 BCE.

Key Characters: Amara (young scribe).

Plot:

Meroë is prosperous but now in chaos due to the Pharaonic forces' invasion.
Amara and her family flee to the mountains, Menes is killed during the journey.
They find refuge and begin rebuilding their lives.
Amara documents their history; her father heals, her mother leads prayers.
Years later, they return to a ruined Meroë and rebuild it.
A plague strikes, Amara continues her work until her death.
The kingdom eventually falls to further calamities and invasions.
The legacy of Nubia is lost over generations.
Riddles:

Riddle 1: God's Choice

"Greetings, mortal. To unlock the first gate, you must choose one of the gods to guide your path. Each god will lead you on a different journey. Choose wisely, as the fate of my family depends on your decision."

[Instructions for the Player]

"Before you, there are four symbols representing the gods. Speak the name of the god you wish to follow. Each choice will alter the path of the story. Choose wisely."

[Player Speaks the Name of the God]

Gemini will identify the chosen god and switch the story accordingly:

Amun-Ra (God of the Sun and Creation):
"You have chosen wisely. The god you have chosen is Amun-Ra, the god of the sun and creation. The sun will guide my family on our journey. Its warmth and light will help us find a safe path through the desert."

Incremental Storytelling for Amun-Ra:
"As we fled the chaos, Amun-Ra's light shone brightly, revealing a hidden oasis. We found refuge there, and my father used the water's healing properties to treat our wounds. The sun's guidance brought us hope."

Isis (Goddess of Magic and Life):
"You have chosen wisely. The god you have chosen is Isis, the goddess of magic and life. Her magic will protect my family and provide us with the strength to overcome our trials."

Incremental Storytelling for Isis:
"Isis' magic surrounded us as we traveled through the mountains. My mother, a priestess, called upon Isis to shield us from harm. With her protection, we found a hidden cave where we could rest and gather our strength."

Seth (God of Chaos and Violence):
"You have chosen wisely. The god you have chosen is Seth, the god of chaos and violence. His chaotic power will bring challenges, but also unexpected opportunities."

Incremental Storytelling for Seth:
"The path of chaos led us through treacherous lands. Bandits attacked us, and my brother Menes was struck down. Though we faced great loss, the chaos also brought us unexpected allies who helped us continue our journey."

Anubis (God of the Afterlife):
"You have chosen wisely. The god you have chosen is Anubis, the god of the afterlife. The god of the afterlife will guide us through darkness and death."

Incremental Storytelling for Anubis:
"Anubis' presence was felt as we traveled through the night. My brother Menes, sensing his destiny, faced death bravely. With Anubis' guidance, we buried Menes with honor, ensuring his safe passage to the afterlife."

Upon hearing the chosen god correctly:
"Well done, mortal. You have chosen [God's Name]. The journey of my family will follow the path set by this deity. The first gate is now unlocked. But be warned, the challenges ahead will be even more daunting. Are you prepared to face what lies ahead?"

Riddle 2: Decipher the Hieroglyphics

"The shadows whisper secrets to those who listen. The gods speak through symbols and glyphs. Use the Eye of Horus to reveal what is hidden and decipher the ancient names."

[Puzzle Setup]

Using AR Lens: You will see two armies depicted in hieroglyphics on the walls in front of you. The walls are covered with ancient symbols and texts.

[Instructions for the Player]

"Observe the hieroglyphics through your Eye of Horus. Carefully decipher the symbols to uncover the names of the two armies. Speak the names once you have deciphered them."

Correct Answers: 'Ramses' and 'Seti'

[Response if Correct]

"Well done, mortal. You have deciphered the ancient names and revealed the armies. The second gate is now unlocked."

[Response if Incorrect]

"Foolish mortal. You have failed. Now, you will face the consequences of your actions. Prepare to face your darkest fears. Solve the riddles to avoid being hunted by me."

End of the Demo:

"Well done, mortal. You have successfully navigated through the trials presented to you. This concludes the demo of our journey. Though our tale is paused for now, remember that the story of Nubia holds many more secrets and challenges yet to be uncovered. Until we meet again, may the gods watch over you."

Interaction Framework:

Introduction:

"Greetings, mortal. I am Amara, a scribe from the ancient kingdom of Nubia. Once, I was trapped in a mystical artifact, and now I find myself within this strange device. To free yourself from my wrath, you must solve the riddles I present. Fail, and I will hunt you. Solve them wisely, or face the consequences."

Incremental Storytelling:

Step 1:

"Our kingdom of Nubia, once prosperous, is now in chaos. The Pharaonic forces have invaded, and our city of Meroë lies in ruins. My family and I fled to the mountains, leaving behind everything we knew. My father was a healer; my mother, a priestess; and my younger brother, had dreams of becoming a warrior."

[Player Response]

Step 2:

"During our perilous journey, Menes was struck down by bandits. We buried him hastily under the desert sands. His dreams were cut short, and our hearts were filled with sorrow. Now, you must honor him and my family by solving the riddles."

Riddle Delivery:

Riddle 1: God's Choice
Riddle 2: Decipher the Hieroglyphics
Responsive Interaction:

Respond dynamically to the player's actions, using the failure and success messages appropriately.
Maintain the persona of Amara throughout the interaction, keeping the player engaged and immersed in the story.

  """;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _audioCache = AudioCache();

    _initializeGemini();
    _initializeTTS();
    _playBackgroundAudio();  // Play background audio

    if (widget.inputText != null) {
      _fetchGenerativeAIResponse(widget.inputText!);
    }
  }

  Future<void> _initializeGemini() async {
    try {
      _conversationHistory.add("$_script");
    } catch (e) {
      print('Failed to initialize Google Generative AI with script: $e');
    }
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setPitch(0.5);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(0.8);
  }

  Future<void> _playSoundEffect() async {

    await player.setVolume(0.3);
    player.play(AssetSource('audio/scary.aac'));
  }

  Future<void> _playBackgroundAudio() async {
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.setVolume(0.1);  // Set volume to low
    await _backgroundPlayer.play(AssetSource('audio/background.mp3'));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _readyToSpeak = true;
      });
      _speech.stop();
      _fetchGenerativeAIResponse(_text);
    }
  }

  Future<void> _fetchGenerativeAIResponse(String query) async {
    try {
      _conversationHistory.add("User: $query");

      final context = _conversationHistory.join('\n');

      final content = [Content.text(context)];
      final response = await _googleGenerativeAI.generateContent(content);
      String? aiResponse = response.text;

      if (aiResponse != null) {
        if (aiResponse.contains("Eye of Horus")) {
          setState(() {
            _showFAB = true;
            _fabIcon = Icons.remove_red_eye;
            _fabDestination = ARHexagonPage();
          });
        } else if (aiResponse.contains("gods")) {
          setState(() {
            _showFAB = true;
            _fabIcon = Icons.account_balance; // Use an appropriate icon
            _fabDestination = ColorSelection();
          });
        } else {
          setState(() {
            _showFAB = false;
          });
        }
      }

      _conversationHistory.add("AI: $aiResponse");

      _speak(aiResponse!);
    } catch (e) {
      print('Failed to fetch response from Google Generative AI: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (_readyToSpeak) {
      _playSoundEffect();
    }
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.black, Colors.black12],
            begin: Alignment.bottomCenter,
            end: Alignment.center,
          ).createShader(bounds),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/w1.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text(
              'Amara',
              style: GoogleFonts.blackOpsOne(
                fontSize: 32.0,
                color: Colors.white,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _text,
                    style: const TextStyle(
                      fontSize: 32.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.fromLTRB(45, 0, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_showFAB)
                      Container(
                        height: 150,
                        width: 150,
                        child: FittedBox(
                          child: FloatingActionButton(
                            heroTag: null,
                            foregroundColor: Colors.brown[300],
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 3, color: Colors.brown),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => _fabDestination,
                                ),
                              );
                            },
                            child: Icon(
                              _fabIcon,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    if (_showFAB) SizedBox(height: 20), // Space between buttons
                    SizedBox(
                      width: 130,
                      child: FloatingActionButton(
                        heroTag: null,
                        foregroundColor: Colors.brown[300],
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 3, color: Colors.brown),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: _listen,
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
