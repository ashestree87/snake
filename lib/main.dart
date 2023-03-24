import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

void main() {
  runApp(MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      home: SnakeGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static final int rows = 30;
  static final int cols = 20;
  static final int foodCount = 3;
  static final int squareSize = 20;

  final List<Color> foodColors = [
    const Color.fromARGB(255, 204, 6, 211),
    const Color.fromARGB(255, 18, 228, 35),
    const Color.fromARGB(255, 235, 9, 9),
    const Color.fromARGB(255, 212, 250, 0),
  ];

  List<int> snake = [];
  late int startingIndex;

  List<int> food = [];
  Direction direction = Direction.up;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startingIndex = Random().nextInt(rows * cols - 3);
    snake = [startingIndex, startingIndex + 1, startingIndex + 2];
    generateFood();
  }

  void generateFood() {
    food = [];
    while (food.length < foodCount) {
      int index = Random().nextInt(rows * cols);
      if (!snake.contains(index) && !food.contains(index)) {
        food.add(index);
      }
    }
  }

  void move() {
    int head = snake.first;
    switch (direction) {
      case Direction.up:
        head -= cols;
        break;
      case Direction.down:
        head += cols;
        break;
      case Direction.left:
        head -= 1;
        break;
      case Direction.right:
        head += 1;
        break;
    }

    if (head < 0 || head >= rows * cols || snake.contains(head)) {
      showGameOverDialog();
    }

    snake.insert(0, head);

    if (food.contains(head)) {
      food.remove(head);
      generateFood();
    } else {
      snake.removeLast();
    }
  }

  void showGameOverDialog() {
    stopTimer();
    int score = (snake.length - 3) * 10;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Game Over',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('You collided with a wall or your own body.'),
              const SizedBox(height: 16),
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Restarting in 5 seconds...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pop();
      setState(() {
        startingIndex = Random().nextInt(rows * cols - 3);
        snake = [startingIndex, startingIndex + 1, startingIndex + 2];
        direction = Direction.up;
        generateFood();
      });
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          move();
        });
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              childAspectRatio: 1.0,
              children: List.generate(rows * cols, (index) {
                if (snake.contains(index)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: index == snake.first
                          ? Color.fromARGB(255, 216, 216, 216)!
                          : Colors.white,
                    ),
                  );
                } else if (food.contains(index)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: foodColors[Random().nextInt(foodColors.length)],
                    ),
                  );
                } else {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 0, 1, 56),
                    ),
                  );
                }
              }),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 0, 0, 0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              'Score: ${snake.length - 3}',
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 12.0,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.0),
                  ),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text(''),
                      onPressed: () {
                        setDirection(Direction.up);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.0),
                  ),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text(''),
                      onPressed: () {
                        setDirection(Direction.left);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.0),
                  ),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(''),
                      onPressed: () {
                        setDirection(Direction.right);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.0),
                  ),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text(''),
                      onPressed: () {
                        setDirection(Direction.down);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void setDirection(Direction newDirection) {
    if (direction == Direction.up && newDirection == Direction.down ||
        direction == Direction.down && newDirection == Direction.up ||
        direction == Direction.left && newDirection == Direction.right ||
        direction == Direction.right && newDirection == Direction.left) {
      return;
    }
    if (_timer == null) {
      startTimer();
    }

    direction = newDirection;
  }
}
