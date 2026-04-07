// Barrett Koster 2025

// This is the core of sound record and playback
// capability.

// This requires access to files on your computer, so
// those of your with file trouble ... sorry.

// This uses and AudioPlayer and an AudioRecorder from just_audio


// import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class SoundState
{
  AudioPlayer player;
  AudioRecorder recorder;
  bool isRecording;
  double currentPosition = 0;
  double totalDuration = 0;

  // now we keep 3 file paths, one for each sound button
  List<String?> filePaths;

  // if we are recording, remember which sound slot it is
  int? currentRecordingIndex;

  // little status line for the screen
  String statusText;

  // constructor.  We use this one when we emit() to change the
  // boold and double variables, NOT the recorder and player.
  SoundState
  ( { required this.player,
      required this.recorder,
      required this.isRecording,
      required this.filePaths,
      required this.currentRecordingIndex,
      required this.statusText,
    }
  );

  // constructor that creates the needed recorder and player.
  // Call this one to get started.
  SoundState.init()
  : player=AudioPlayer(),
    recorder = AudioRecorder(),
    isRecording = false,
    filePaths = [null, null, null],
    currentRecordingIndex = null,
    statusText = "Ready" ;

  void dispose()
  { player.dispose();
    recorder.dispose();
  }
}

class SoundCubit extends Cubit<SoundState>
{
  SoundCubit() :super( SoundState.init() );

  Future<void> startRecording(int which) async
  {
    final bool hasPermish = await state.recorder.hasPermission();
    if (!hasPermish)
    { print("no permission to record");
      emit( SoundState
            ( player:state.player,
              recorder: state.recorder,
              isRecording: false,
              filePaths: state.filePaths,
              currentRecordingIndex: null,
              statusText: "No microphone permission",
            ) );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filename = "sound_$which.m4a";

    // no, do not set it until it works, will be set after
    // recording.

    final path = "${dir.path}/$filename";

    // magic numbers much?
    const config = RecordConfig
    ( encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
    );

    await state.recorder.start(config,path: path);
    emit( SoundState
          ( player:state.player,
            recorder: state.recorder,
            isRecording: true,
            filePaths: state.filePaths,
            currentRecordingIndex: which,
            statusText: "Recording sound ${which + 1}...",
          ) );
  }

  void stopRecording() async
  {
    final path = await state.recorder.stop();
    print("sound file path = $path");

    List<String?> newPaths = List<String?>.from(state.filePaths);

    if (path != null && state.currentRecordingIndex != null)
    { newPaths[state.currentRecordingIndex!] = path;
    }

    emit( SoundState
          ( player:state.player,
            recorder: state.recorder,
            isRecording: false,
            filePaths: newPaths,
            currentRecordingIndex: null,
            statusText: "Saved sound",
          ) );
  }

  Future<void> playRecording(int which) async
  {
    if (state.filePaths[which] != null )
    {
      await state.player.setFilePath( state.filePaths[which]! );
      // we can get the duration here if we want
      state.player.play();
      // we can set the playback start point to something
      // other than zero if we want.

      emit( SoundState
            ( player:state.player,
              recorder: state.recorder,
              isRecording: state.isRecording,
              filePaths: state.filePaths,
              currentRecordingIndex: state.currentRecordingIndex,
              statusText: "Playing sound ${which + 1}",
            ) );
    }
    else
    { emit( SoundState
            ( player:state.player,
              recorder: state.recorder,
              isRecording: state.isRecording,
              filePaths: state.filePaths,
              currentRecordingIndex: state.currentRecordingIndex,
              statusText: "No sound saved there",
            ) );
    }
  }

  Future<void> stopPlaying() async
  {
    await state.player.stop();

    emit( SoundState
          ( player:state.player,
            recorder: state.recorder,
            isRecording: state.isRecording,
            filePaths: state.filePaths,
            currentRecordingIndex: state.currentRecordingIndex,
            statusText: "Stopped playback",
          ) );
  }

  @override
  Future<void> close()
  { state.dispose();
    return super.close();
  }

}