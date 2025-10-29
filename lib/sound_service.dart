import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _soundsEnabled = true;

  static Future<void> playStartSound() async {
    if (!_soundsEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/click.mp3')); // Для кнопки "Начать тест"
    } catch (e) {
      debugPrint('Error playing start sound: $e'); 
    }
  }

  static Future<void> playAnswerSound() async {
    if (!_soundsEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/answer_click.mp3')); // Для ответов на вопросы
    } catch (e) {
      debugPrint('Error playing answer sound: $e'); 
    }
  }

  static Future<void> playToggleSound() async {
    if (!_soundsEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/toggle.mp3')); // Для переключения
    } catch (e) {
      debugPrint('Error playing toggle sound: $e'); 
    }
  }

  static Future<void> playLanguageSelectSound() async {
    if (!_soundsEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/language_select.mp3')); // Для выбора языка
    } catch (e) {
      debugPrint('Error playing language select sound: $e');
    }
  }

  static Future<void> playBackSound() async {
    if (!_soundsEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/back.mp3')); // Для кнопки назад
    } catch (e) {
      debugPrint('Error playing back sound: $e'); 
    }
  }

  static Future<void> playRestartSound() async {
    if (!_soundsEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/restart.mp3')); // Для перезапуска
    } catch (e) {
      debugPrint('Error playing restart sound: $e'); 
    }
  }

  static void enableSounds() {
    _soundsEnabled = true;
  }

  static void disableSounds() {
    _soundsEnabled = false;
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}