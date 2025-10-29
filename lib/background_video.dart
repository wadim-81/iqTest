import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundVideo extends StatefulWidget {
  final Widget child;
  final bool withSound;

  const BackgroundVideo({
    super.key, // Исправлено: используем super.key
    required this.child,
    this.withSound = false,
  });

  @override
  State<BackgroundVideo> createState() => __BackgroundVideoState();
}

class __BackgroundVideoState extends State<BackgroundVideo> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _wasPlaying = false;
  bool _soundCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/background.mp4');
      await _controller.initialize();
      
      if (!mounted) return;
      
      setState(() {
        _isInitialized = true;
      });
      
      _controller.setLooping(true);
      
      // Устанавливаем громкость в зависимости от параметра
      if (widget.withSound) {
        _controller.setVolume(1.0);
        _soundCompleted = false;
      } else {
        _controller.setVolume(0.0);
        _soundCompleted = true;
      }
      
      _controller.play();
      _wasPlaying = true;

      // Добавляем слушатель для отслеживания завершения первого проигрыша
      if (widget.withSound) {
        _controller.addListener(() {
          if (!mounted || _isDisposed) return;
          
          // Исправлено: убрана избыточная проверка на null
          if (_controller.value.position >= _controller.value.duration - const Duration(milliseconds: 100)) {
            
            if (!_soundCompleted) {
              setState(() {
                _soundCompleted = true;
              });
              // Отключаем звук после первого проигрыша
              _controller.setVolume(0.0);
            }
          }
        });
      }
    } catch (e) {
      // Исправлено: заменили print на debugPrint
      debugPrint('Error initializing video: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed || !_isInitialized) return;
    
    if (state == AppLifecycleState.resumed) {
      // Восстанавливаем предыдущее состояние воспроизведения
      if (_wasPlaying) {
        _controller.play();
      }
    } else if (state == AppLifecycleState.paused) {
      // Сохраняем состояние перед паузой
      _wasPlaying = _controller.value.isPlaying;
      _controller.pause();
    }
  }

  @override
  void didUpdateWidget(BackgroundVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Если изменился параметр withSound, обновляем громкость
    if (oldWidget.withSound != widget.withSound && _isInitialized) {
      if (widget.withSound && !_soundCompleted) {
        // Включаем звук и сбрасываем флаг завершения
        _controller.setVolume(1.0);
        _soundCompleted = false;
      } else {
        // Выключаем звук
        _controller.setVolume(0.0);
        _soundCompleted = true;
      }
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
              child: const Center(child: CircularProgressIndicator()),
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
        
        Positioned.fill(
          child: Container(
            // Исправлено: заменили withOpacity на Color.fromRGBO
            color: const Color.fromRGBO(0, 0, 0, 0.3),
          ),
        ),
        
        widget.child,
      ],
    );
  }
}