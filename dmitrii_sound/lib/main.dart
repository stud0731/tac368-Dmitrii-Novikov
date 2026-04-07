// Barrett Koster 2025
// 
// using record and just_audio:
// > flutter pub add record
// > flutter pub add just_audio

// You also need to add to macos/Runner/*.entitlements:
//    <key>com.apple.security.device.audio-input</key>
//    <true/>


// Run this file to do the demo.  All of the interesting stuff
// is in sound_state.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sound_state.dart';

void main()
{ runApp(const SayWhat());
}

class SayWhat extends StatelessWidget
{ const SayWhat({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)
  { const title = "Dmitrii sound board";
    return MaterialApp
    ( title: title,
      debugShowCheckedModeBanner: false,
      home: BlocProvider<SoundCubit>
      ( create: (context) => SoundCubit(),
        child: BlocBuilder<SoundCubit,SoundState>
        ( builder: (context,state)
          { return SayWhat1(title:title);
          },
        )
      )
    );
  }
}

class SayWhat1 extends StatelessWidget
{ final String title;
  const SayWhat1({super.key, required this.title});

  @override
  Widget build(BuildContext context)
  { SoundCubit sc = BlocProvider.of<SoundCubit>(context);
    SoundState st = context.watch<SoundCubit>().state;

    return Scaffold
    ( appBar: AppBar(title: Text(title)),
      body: Padding
      ( padding: const EdgeInsets.all(16),
        child: Column
        ( children:
          [
            Text(st.statusText,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            Expanded
            ( child: ListView
              ( children:
                [
                  soundRow(context, sc, st, 0),
                  soundRow(context, sc, st, 1),
                  soundRow(context, sc, st, 2),
                ],
              ),
            ),

            Row
            ( mainAxisAlignment: MainAxisAlignment.center,
              children:
              [
                ElevatedButton
                ( onPressed: st.isRecording
                    ? (){ sc.stopRecording(); }
                    : null,
                  child: Text("stop rec"),
                ),
                const SizedBox(width: 16),
                ElevatedButton
                ( onPressed: (){ sc.stopPlaying(); },
                  child: Text("stop play"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget soundRow(BuildContext context, SoundCubit sc, SoundState st, int index)
  { bool hasSound = st.filePaths[index] != null;

    return Card
    ( margin: const EdgeInsets.only(bottom: 16),
      child: Padding
      ( padding: const EdgeInsets.all(16),
        child: Row
        ( children:
          [
            SizedBox
            ( width: 90,
              child: Text("sound ${index + 1}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton
            ( onPressed: st.isRecording
                ? null
                : (){ sc.startRecording(index); },
              child: Text("record"),
            ),
            const SizedBox(width: 12),
            ElevatedButton
            ( onPressed: hasSound
                ? (){ sc.playRecording(index); }
                : null,
              child: Text("play"),
            ),
          ],
        ),
      ),
    );
  }

}