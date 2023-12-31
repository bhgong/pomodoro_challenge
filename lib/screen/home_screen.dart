import 'dart:async';
// import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _animation;
  late final CurvedAnimation _curve;

  final double startValue = 0.005;
  List<int> minutes = [15, 20, 25, 30, 35];
  int totalSeconds = 0;
  int totalSecondsSel = 0;

  // static const breakFiveMinutes = 5 * 60;
  static const breakFiveMinutes = 5; // for Debug
  int finishedRound = 0;
  int indexMin = 0;
  int totalPomodoro = 0;
  List<bool> isSelected = List.filled(5, false);
  bool isRunning = false;
  bool isRestart = false;
  bool isInitState = true;
  bool isBreakTime = false;
  bool isPaused = false;
  bool isTimerInit = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalSeconds),
    );
    _curve =
        CurvedAnimation(parent: _animationController, curve: Curves.linear);
    _animation = Tween(
      begin: 0.005,
      end: 2.0,
    ).animate(_curve);

    // _animationController.addListener(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      if (totalSecondsSel != 0 && isBreakTime) {
        // 브레이크 타임 0이 되고 난 다음 + 초기상태
        totalSeconds = totalSecondsSel;
        isInitState = true;
        isBreakTime = false;
        _animationController.reverse(from: 0.005);
        _animationController.duration = Duration(seconds: totalSeconds);
      } else if (totalSecondsSel != 0 && !isBreakTime) {
        // 초기상태가 아니고 한바퀴 돌아왔을 때
        finishedRound++;
        if ((finishedRound % 4) == 0) {
          totalPomodoro++;
          finishedRound = 0;
        }
        totalSeconds = breakFiveMinutes;
        isBreakTime = true;
        isInitState = true;
        _animationController.reverse(from: 0.005);
        _animationController.duration = Duration(seconds: totalSeconds);
      } // 여기에 조건이 하나 더 붙어야해. 완료 후 5초로 설정될거냐 아니냐에 따라서.
      isRunning = false; // 다시 0이 되었으니까 Running false로 둬야지
      timer.cancel();
    } else {
      totalSeconds = totalSeconds - 1;
    }

    setState(() {});
  }

  void onMinuteSelPressed(int indexMin) {
    isSelected = List.filled(isSelected.length, false);
    isSelected[indexMin] = true;

    isInitState = true;
    setState(() {
      // totalSeconds = (minutes[indexMin] * 60);
      totalSeconds = (minutes[indexMin]);
      totalSecondsSel = totalSeconds;
      _animationController.duration = Duration(seconds: totalSeconds);
      isRunning = false;
    });
  }

  String format(int tSeconds) {
    var duration = Duration(seconds: tSeconds);
    String rtn = duration.toString();

    if (tSeconds < 3600) {
      rtn = rtn.split(".").first.substring(2, 7);
    } else if (tSeconds >= 3600) {
      rtn = rtn.split(".").first;
    }

    return rtn;
  }

  void onStartPressed() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );

    isTimerInit = true;
    setState(() {
      if (totalSeconds != 0) {
        isRunning = true;
        if (isInitState) {
          _animationController.forward(from: startValue);
          isInitState = false;
        }
      } else if (isBreakTime) {
        _animationController.reset();
      }
      if (isPaused) {
        _animationController.forward(); // 멈춘상태에서 바로시작하는 지 확인
        isPaused = false;
      }
    });
  }

  void onRestartPressed() {
    setState(() {
      totalSeconds = 0;
      finishedRound = 0;
      totalSecondsSel = 0;
      isRunning = false;
      totalPomodoro = 0;
      isSelected = List.filled(isSelected.length, false);
    });
    timer.cancel();
  }

  void onPausePressed() {
    _animationController.stop();
    timer.cancel();

    setState(() {
      isPaused = true;
      isRunning = false;
    });
  }

  void stopTick() {
    if (!isTimerInit) return;
    timer.cancel();
    _animationController.reverse(from: 0.005);
    if (!isBreakTime) {
      totalSeconds = totalSecondsSel;
    } else if (isBreakTime) {
      totalSeconds = breakFiveMinutes;
    }
    setState(() {
      isInitState = true;
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Flexible(
              flex: 2,
              child: Stack(
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: PomodoroPainter(
                            progress: _animation.value,
                          ),
                          size: const Size(250, 250),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          format(totalSeconds),
                          style: TextStyle(
                            color: Theme.of(context).cardColor,
                            fontSize: 50,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    // for (var idx = 0; idx < minutes.length; idx++)
                    timeButton(
                      context,
                      0,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    timeButton(
                      context,
                      1,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    timeButton(
                      context,
                      2,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    timeButton(
                      context,
                      3,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    timeButton(
                      context,
                      4,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: IconButton(
                      iconSize: 32,
                      color: Theme.of(context).cardColor,
                      onPressed: onRestartPressed,
                      icon: const Icon(Icons.restart_alt_outlined),
                    ),
                  ),
                  Center(
                    child: IconButton(
                      iconSize: 98,
                      color: Theme.of(context).cardColor,
                      onPressed: isRunning ? onPausePressed : onStartPressed,
                      icon: Icon(
                        isRunning
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                      ),
                    ),
                  ),
                  Center(
                    child: IconButton(
                      iconSize: 32,
                      color: Theme.of(context).cardColor,
                      onPressed: stopTick,
                      icon: const Icon(Icons.stop),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$finishedRound/4',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF4A39A),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'ROUND',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '$totalPomodoro/12',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF4A39A),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "GOAL",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonTheme timeButton(BuildContext context, int selIndex) {
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: () => onMinuteSelPressed(selIndex),
        style: ElevatedButton.styleFrom(
            backgroundColor: isSelected[selIndex]
                ? Colors.white.withOpacity(0.8)
                : Theme.of(context).primaryColor,
            shadowColor: Colors.grey,
            side: BorderSide(
              color: isSelected[selIndex] ? Colors.black : Colors.white,
              width: 5.0,
            ),
            padding: const EdgeInsets.all((15))),
        child: Text(
          '${minutes[selIndex]}',
          style: TextStyle(
            color: isSelected[selIndex]
                ? Colors.black.withOpacity(0.8)
                : Theme.of(context).cardColor,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class PomodoroPainter extends CustomPainter {
  final double progress;
  PomodoroPainter({
    required this.progress,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );
    const startingAngle = -0.5 * pi;
    // draw red
    final redCirclePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    final redCircleRadius = (size.width / 2) * 0.9;
    canvas.drawCircle(
      center,
      redCircleRadius,
      redCirclePaint,
    );
    // red arc
    final redArcRect = Rect.fromCircle(
      center: center,
      radius: redCircleRadius,
    );
    final redArcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;
    canvas.drawArc(
      redArcRect,
      startingAngle,
      progress * pi,
      false,
      redArcPaint,
    );

    // print(progress);
  }

  @override
  bool shouldRepaint(covariant PomodoroPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
