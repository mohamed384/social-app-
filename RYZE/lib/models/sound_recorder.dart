import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialised = false;

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone Permission denied');
    }
    await _audioRecorder!.openAudioSession();
    _isRecorderInitialised = true;
  }

  void dispose() {
    if (!_isRecorderInitialised) return;
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialised = false;
  }

  Future<String> _getTempPath(String path) async {
    var tempDir = await getTemporaryDirectory();
    var tempPath = tempDir.path;
    return tempPath + '/' + path;
  }

  Future _startRecord() async {
    if (!_isRecorderInitialised) return;
    final _mPath = await _getTempPath('voice.mp4');
    await _audioRecorder!.startRecorder(toFile: _mPath, codec: Codec.aacMP4);
  }

  Future stopRecord() async {
    if (!_isRecorderInitialised) return;
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording(String chatRoomId, bool uploadOrNo) async {
    if (_audioRecorder!.isStopped) {
      await _startRecord();
    } else {
      if (uploadOrNo) {
        await stopRecord();
        final _mPath = await _getTempPath('voice.mp4');
        return _mPath;
      } else {
        await stopRecord();
      }
    }
  }
}
