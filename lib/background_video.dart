import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideo extends StatefulWidget {
  final Widget child;
  final bool withSound; // Новый параметр для управления звуком

  const BackgroundVideo({
    Key? key, 
    required this.child,
    this.withSound = false, // По умолчанию без звука
  }) : super(key: key);

  @override
  _BackgroundVideoState createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInitialized && !_isDisposed) {
      _restartVideo();
    } else if (state == AppLifecycleState.paused && _isInitialized && !_isDisposed) {
      _controller.pause();
    }
  }

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/background.mp4');
      await _controller.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        
        // Устанавливаем громкость в зависимости от параметра
        if (widget.withSound) {
          _controller.setVolume(1.0); // Полная громкость
        } else {
          _controller.setVolume(0.0); // Без звука
        }
        
        _controller.play();
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _restartVideo() {
    if (_isInitialized && !_isDisposed && mounted) {
      _controller.seekTo(Duration.zero);
      _controller.play();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фоновое видео или цветной фон
        if (_isInitialized && _controller.value.isInitialized)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
        else if (!_isInitialized)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade900, Colors.purple.shade900],
                ),
              ),
            ),
          ),
        
        // Затемняющий слой
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        
        // Основной контент
        widget.child,
      ],
    );
  }
}