import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:hive/hive.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool _isRecording = false;
  String _recordingTime = '00:00';
  Timer? _timer;
  int _secondsElapsed = 0;
  // Store the path to the recorded audio file to be processed later
  String? _recordedFilePath;

  // Audio recorder instance
  late final AudioRecorder _recorder;
  bool _isRecorderInitialized = false;
  String? _recordingDirectory;

  // For audio waveform visualization
  late RecorderController _recorderController;
  bool _isRecorderControllerInitialized = false;
  String? _waveformPath;
  
  // For transcription with speech_to_text
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isTranscribing = false;
  String? _transcriptionText;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
    _initRecorder();
    _initWaveformRecorder();
    _initSpeechToText();
  }
  
  // Initialize speech to text functionality
  Future<void> _initSpeechToText() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }
  
  // This is the callback for speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _transcriptionText = result.recognizedWords;
    });
  }

  Future<void> _initRecorder() async {
    try {
      // Create a directory for storing recordings
      final appDir = await getApplicationDocumentsDirectory();
      _recordingDirectory = '${appDir.path}/recordings';
      await Directory(_recordingDirectory!).create(recursive: true);
      print('Recording directory created: $_recordingDirectory');

      // Check if we have permission to record
      // The Record package automatically requests permission when needed

      _isRecorderInitialized = true;
    } catch (e) {
      print('Error initializing recorder: $e');
      _isRecorderInitialized = false;
    }
  }

  Future<void> _initWaveformRecorder() async {
    try {
      // Initialize the RecorderController for audio waveform visualization
      _recorderController =
          RecorderController()
            ..androidEncoder = AndroidEncoder.aac
            ..androidOutputFormat = AndroidOutputFormat.mpeg4
            ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
            ..sampleRate = 44100;

      _isRecorderControllerInitialized = true;
      print('Waveform recorder initialized successfully');
    } catch (e) {
      print('Error initializing waveform recorder: $e');
      _isRecorderControllerInitialized = false;
    }
  }

  @override
  void dispose() {
    _stopRecording();
    _timer?.cancel();
    if (_isRecorderControllerInitialized) {
      _recorderController.dispose();
    }
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _stopRecording() async {
    try {
      if (_isRecording) {
        String? path = await _recorder.stop();
        print('Recording stopped with path: $path');
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _toggleRecording() async {
    print('Toggle recording button pressed. Current state: ${_isRecording ? 'Recording' : 'Not recording'}');

    if (!_isRecorderInitialized) {
      await _initRecorder();
    }

    try {
      if (_isRecording) {
        // Already recording, stop it
        print('Stopping recording...');
        _recordedFilePath = await _recorder.stop();
        print('Recording stopped. File path: $_recordedFilePath');

        // Stop the waveform recorder
        if (_isRecorderControllerInitialized) {
          await _recorderController.stop();
          print('Waveform recording stopped');
        }

        setState(() {
          _isRecording = false;
        });

        _stopTimer();

        if (_recordedFilePath != null) {
          _showSaveDialog();
        }
      } else {
        // Check if we have permission
        bool hasPermission = await _recorder.hasPermission();
        if (!hasPermission) {
          print('No microphone permission');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission is required')));
          return;
        }

        // Create a unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '$_recordingDirectory/recording_$timestamp.m4a';
        print('Will record to: $filePath');

        // Configure the recorder
        final config = RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100);

        // Start recording with AudioRecorder
        print('Starting recording...');
        await _recorder.start(config, path: filePath);
        print('Recording started successfully');

        // Start the waveform recorder
        if (_isRecorderControllerInitialized) {
          _waveformPath = '$_recordingDirectory/waveform_$timestamp.m4a';
          await _recorderController.record(path: _waveformPath);
          print('Waveform recording started');
        }

        setState(() {
          _isRecording = true;
        });

        _startTimer();

        // Feedback
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording in progress...'), duration: Duration(seconds: 1)));
      }
    } catch (e) {
      print('Recording error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recording error: $e')));

      setState(() {
        _isRecording = false;
      });

      _stopTimer();
    }
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        _recordingTime = _formatDuration(_secondsElapsed);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  Future<void> _transcribeRecording() async {
    if (_recordedFilePath == null) return;
    
    setState(() {
      _isTranscribing = true;
    });
    
    try {
      // Show a snackbar to indicate transcription is in progress
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcribing audio... This may take a moment.'),
        duration: Duration(seconds: 5))
      );
      
      // Check if speech recognition is available and initialized
      if (!_speechEnabled) {
        await _initSpeechToText();
        if (!_speechEnabled) {
          throw Exception('Speech recognition not available on this device');
        }
      }
      
      // Start listening with speech_to_text
      // This will perform on-device speech recognition
      _transcriptionText = '';
      
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30), // Adjust as needed
        localeId: 'en_US',
        cancelOnError: true,
        partialResults: true,
      );
      
      // Let the user know we're listening
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please speak clearly to transcribe the recording.'),
        duration: Duration(seconds: 3))
      );
      
      // Wait for transcription to complete
      await Future.delayed(const Duration(seconds: 15)); // Adjust time as needed
      await _speechToText.stop();
      
      // Update the Hive box with the transcription
      final box = Hive.box('recordings');
      final recordingData = box.get(_recordedFilePath);
      if (recordingData != null) {
        recordingData['transcription'] = _transcriptionText;
        await box.put(_recordedFilePath, recordingData);
        print('Transcription saved to Hive: $_transcriptionText');
      }
      
      setState(() {
        _isTranscribing = false;
      });
      
      // Show completion notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription completed!'),
        duration: Duration(seconds: 2))
      );
      
    } catch (e) {
      print('Transcription error: $e');
      setState(() {
        _isTranscribing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription error: $e'))
      );
    }
  }
  
  void _saveRecordingToHive(String title) async {
    if (_recordedFilePath == null) return;
    
    try {
      final box = Hive.box('recordings');
      
      // Create a recording data object
      final recordingData = {
        'title': title,
        'path': _recordedFilePath,
        'date': DateTime.now().toString(),
        'duration': _secondsElapsed,
        'transcription': null, // Will be populated after transcription
      };
      
      // Save to Hive using the file path as the key
      await box.put(_recordedFilePath, recordingData);
      
      print('Recording saved to Hive: $_recordedFilePath with title: $title');
    } catch (e) {
      print('Error saving to Hive: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving recording: $e'))
      );
    }
  }

  void _showSaveDialog() {
    // Show dialog to save the recording with a title
    if (_recordedFilePath != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          String recordingTitle = 'Recording ${DateTime.now().toString().substring(0, 16)}';

          return AlertDialog(
            title: const Text('Save Recording'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your recording has been saved. Would you like to add a title?'),
                const SizedBox(height: 10),
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Recording Title', border: OutlineInputBorder()),
                  onChanged: (value) {
                    recordingTitle = value;
                  },
                  controller: TextEditingController(text: recordingTitle),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to home screen
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save recording to Hive
                  _saveRecordingToHive(recordingTitle);
                  
                  // Start transcription
                  _transcribeRecording();

                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to home screen
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } else {
      // If no file was recorded, just go back
      Navigator.pop(context);
    }
  }

  // This method is no longer used since we're using waveform visualization instead
  /* Widget _buildPulsatingCircle(double size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      height: _isRecording ? size : size * 0.8,
      width: _isRecording ? size : size * 0.8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _isRecording ? Colors.red.withOpacity(0.2) : Colors.transparent, border: Border.all(color: Colors.white, width: 2)),
      child: Center(child: Container(height: 30, width: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))),
    );
  } */

  Widget _buildWaveform() {
    if (!_isRecorderControllerInitialized) {
      return const Center(child: Text('Waveform not available', style: TextStyle(color: Colors.white)));
    }

    return AudioWaveforms(
      enableGesture: false,
      size: Size(MediaQuery.of(context).size.width - 80, 80),
      recorderController: _recorderController,
      waveStyle: WaveStyle(waveColor: Colors.white, extendWaveform: true, showMiddleLine: false, spacing: 5.0, waveThickness: 3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white.withOpacity(0.1)),
      padding: const EdgeInsets.only(left: 18, right: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE53935), // Red background
      appBar: AppBar(title: const Text('Recording'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual indicator for recording
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 150,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.white.withOpacity(0.1)),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child:
                      _isRecording
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Audio waveform visualization
                                SizedBox(height: 80, child: _buildWaveform()),
                                const SizedBox(height: 10),
                                const Text('Recording in progress...', style: TextStyle(color: Colors.white, fontSize: 14)),
                              ],
                            ),
                          )
                          : const Center(child: Text('Tap the mic button to start recording', style: TextStyle(color: Colors.white, fontSize: 18))),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(_recordingTime, style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(_isRecording ? 'Recording in progress...' : 'Ready to record', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(onPressed: _toggleRecording, backgroundColor: Colors.white, foregroundColor: const Color(0xFFE53935), elevation: 8.0, child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 30)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
