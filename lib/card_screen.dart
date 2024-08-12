import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // Import the main.dart file to access the HomePage widget

class CardScreen extends ChangeNotifier {
  String? _selectedColor;

  String? get selectedColor => _selectedColor;

  void setSelectedColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }
}

class ColorSelection extends StatelessWidget {
  const ColorSelection({super.key});

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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Gods",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Choose your god to face your destiny",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Consumer<CardScreen>(
                builder: (context, cardScreen, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          colorButton(
                            g_color: "Anubis",
                            selected: cardScreen.selectedColor == 'Golden',
                            onPressed: () {
                            cardScreen.setSelectedColor('Golden');
                            },
                          ),
                      ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          colorButton(
                            g_color: "Isis ",
                            selected: cardScreen.selectedColor == 'Red',
                            onPressed: () {
                              cardScreen.setSelectedColor('Red');
                            },
                          ),
                          colorButton(
                            g_color: "Seth",
                            selected: cardScreen.selectedColor == 'Green',
                            onPressed: () {
                              cardScreen.setSelectedColor('Green');
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          colorButton(
                            g_color: "Amun",
                            selected: cardScreen.selectedColor == 'Black',
                            onPressed: () {
                              cardScreen.setSelectedColor('Black');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {
                          if (cardScreen.selectedColor != null) {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                inputText: cardScreen.selectedColor,
                              ),
                            ),
                            );
                          } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please select a color first.'),
                                ),
                              );
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget colorButton({
    required String g_color,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(
                width: 5,
                color: selected ? Colors.red : Colors.white,
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Container(
          width: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                g_color,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
