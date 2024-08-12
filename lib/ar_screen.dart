import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nowuseeme/main.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARHexagonPage extends StatefulWidget {
  @override
  _ARHexagonPageState createState() => _ARHexagonPageState();
}

class _ARHexagonPageState extends State<ARHexagonPage> {
  late ArCoreController arCoreController;
  int _remainingTime = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        Navigator.pop(context); // Close the page when the timer ends
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _remainingTime <= 10 ? Colors.red : Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Time remaining: $_remainingTime',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTextInputDialog(context);
        },
        child: Icon(Icons.keyboard),
      ),
    );
  }

  void _showTextInputDialog(BuildContext context) {
    final TextEditingController _textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Your Text'),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: 'Type your message here'),
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () {
                String inputText = _textController.text;
                Navigator.of(context).pop();
                _sendTextToHomePage(context, inputText);
              },
            ),
          ],
        );
      },
    );
  }

  void _sendTextToHomePage(BuildContext context, String inputText) {
    // Access HomePage's state and send text
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(inputText: inputText),
      ),
    );
    Navigator.pop(context);
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addWalls();
  }

  Future<void> _addWalls() async {
    List<String> wallImages = [
      'assets/images/wall.jpg',
      'assets/images/(ramses).jpg',
      'assets/images/(seti).jpg',
    ];

    List<vector.Vector3> positions = [
      vector.Vector3(0, 0, -1.5),   // Wall 1: In front of the user
      vector.Vector3(-1.5, 0, 0),   // Wall 2: Left of the user
      vector.Vector3(1.5, 0, 0),    // Wall 3: Right of the user
    ];

    List<vector.Vector4> rotations = [
      vector.Vector4(0, 0, 0, 1),       // Wall 1: Facing user
      vector.Vector4(0, 1, 0, 3.14 / 2), // Wall 2: Facing right
      vector.Vector4(0, 1, 0, -3.14 / 2), // Wall 3: Facing left
    ];

    for (int i = 0; i < 3; i++) {
      final ByteData data = await rootBundle.load(wallImages[i]);
      final Uint8List bytes = data.buffer.asUint8List();

      final material = ArCoreMaterial(
        color: Colors.white,
        textureBytes: bytes,
      );

      final wall = ArCoreNode(
        shape: ArCoreCube(
          materials: [material],
          size: vector.Vector3(1.0, 1.0, 0.1),
        ),
        position: positions[i],
        rotation: rotations[i],
      );

      arCoreController.addArCoreNode(wall);
    }
  }
}
