import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:chirp_flutter/chirp_flutter.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:random_string/random_string.dart';

/// Enter Chirp application credentials below
String _appKey = '75A98FaA9F6b805f9C63575ac';
String _appSecret = 'Ee1Ac5aAb7573C1Fadbe5fd3C5Bc38B671e66C69d1c4CfeE1C';
String _appConfig =
    'E9GAgeuDEhEnZCupcK+skCIw75NIaobpu+N+mMMQSkdLh84WRZsDA3rg8snfB+YC7rcBJHDeLSF+OLifzFllUsyHbuXc7WA3/stOvKDT49YQTtLiIcrTWydsgqNLKjjb+7aJYu4xrdAnkBBLMGjP3tVsnknCN7JoUyKcWnuB/jv/yCeZ36MREwmps2STCpYNiEMf1mWuGb9DRsvjRVupHijdS4GzUS+bhLKm11W16zScvsaBGgrxRAE8LfghF3QMzqUBHDiPG3PV6DkmIVhZGy/dwkyF7ocdUICjPeu3i66VepudwvQensgLlyGEsJ1uzm0My/s5Q0eWzlGXhXcswkU5AtjlCviddwnRpZbB9B9oRYqhaQXFrdfsRmlOaiSgK9GGaVMxX6uns4bV2vP1mEw+oq8AGf8ViLoLSDmT42DzI6VQlPWHHh4uz0wachvcyp73VbdkBE1DHeQ8IEGeeWEwT1xR/fEjakRHHD/E70Ho1fwQRRWtIQsm2loEs+MbdxYcokQbk2kHlRxWdSHDYGQ/n4puvRf5/z1V8PmhRxcpksCC3mIrMukM2/5Q54jFBRU6DTfBR9NJw4f7zta2gTKIg7azfrYlEophi/L0RDDlPoUW9uMfWPtyRQDBw8a4FWaRGyTnPqIzsoC/IIOYQ26F8PDCXSLBzQrTfP9qTRVBhMcOhX4Fe5t0e6acGPg1sv1SNS2B8FmrmmdOcUTmH19Iq7btxbl0QMSsVuqFIyGJE9SouuzGpChe5ofh8POeS2Funy3flOoV2tQbCCYOGrC4um0Ruhm9P5JLYq5i6XsD9t4sjcl3UHaNtqR6y6q3OQwwbXUJYrh7nRzrKJjXUA18j5pfV+bqJ6lxeHbLP7Y9DGGGjzDXn1GSoRc2HEa/29AivcUQqBQQyppu+aPKNO5l9PGRJhsWRoapotWw5V3MxGdwD69fGssFSFkZ9nRowC5ZFuAU+P4yAj+xx+7fq3RS+ku4jHOgJ4r1wABiKXYb0YAffccl2FbmmOwAskE0IpmgoK4kuyKRxeiLUNg81DhTdyKe7eUw7Z/z6IFtkE2sUnS9jb0c1LZzOVNuHuPwO72119fDtUN9om9AOjiomIinxtD6ZEJhHDMcdlojzBhMQJPzapgBq0UCNNqVgMY5IoGPe5jTZ4qEFYC4O0n0Gg==';

void main() => runApp(ChirpApp());

class ChirpApp extends StatefulWidget {
  @override
  _ChirpAppState createState() => _ChirpAppState();
}

class _ChirpAppState extends State<ChirpApp> with WidgetsBindingObserver {
  final chirpYellow = const Color(0xffffd659);

  ChirpState _chirpState = ChirpState.not_created;
  String _chirpErrors = '';
  String _chirpVersion = 'Unknown';
  String _startStopBtnText = 'START';
  String _chirpData = '';

  void setPayload(String payload) {
    setState(() {
      _chirpData = payload;
    });
  }

  void setErrorMessage(String error) {
    setState(() {
      _chirpErrors = error;
    });
  }

  Future<void> _initChirp() async {
    try {
      // Init ChirpSDK
      await ChirpSDK.init(_appKey, _appSecret);

      // Get and print SDK version
      final String chirpVersion = await ChirpSDK.version;
      setState(() {
        _chirpVersion = "$chirpVersion";
      });

      // Set SDK config
      await ChirpSDK.setConfig(_appConfig);
      _setChirpCallbacks();
    } catch (err) {
      setErrorMessage("Error initialising Chirp.\n${err.message}");
    }
  }

  void _startStopSDK() async {
    try {
      var state = await ChirpSDK.state;
      if (state == ChirpState.stopped) {
        _startSDK();
      } else {
        _stopSDK();
      }
    } catch (err) {
      setErrorMessage("${err.message}");
    }
  }

  void _startSDK() async {
    try {
      await ChirpSDK.start();
      setState(() {
        _startStopBtnText = "STOP";
      });
    } catch (err) {
      setErrorMessage("Error starting the SDK.\n${err.message};");
    }
  }

  void _stopSDK() async {
    try {
      await ChirpSDK.stop();
      setState(() {
        _startStopBtnText = "START";
      });
    } catch (err) {
      setErrorMessage("Error stopping the SDK.\n${err.message};");
    }
  }

  void _sendRandomPayload() async {
    try {
      String payload = randomString(3);
      setPayload(payload);
      var encodedPayload = Uint8List.fromList(jsonEncode(payload).codeUnits);
      await ChirpSDK.send(encodedPayload);
    } catch (err) {
      setErrorMessage("Error sending random payload: ${err.message};");
    }
  }

  Future<void> _setChirpCallbacks() async {
    ChirpSDK.onStateChanged.listen((e) {
      setState(() {
        _chirpState = e.current;
      });
    });
    ChirpSDK.onSending.listen((e) {
      setState(() {
        var decodedPayload = jsonDecode(String.fromCharCodes(e.payload));
        _chirpData = decodedPayload;
      });
    });
    ChirpSDK.onSent.listen((e) {
      setState(() {
        var decodedPayload = jsonDecode(String.fromCharCodes(e.payload));
        _chirpData = decodedPayload;
      });
    });
    ChirpSDK.onReceived.listen((e) {
      setState(() {
        var decodedPayload = jsonDecode(String.fromCharCodes(e.payload));
        _chirpData = decodedPayload;
      });
    });
  }

  Future<void> _requestPermissions() async {
    bool permission =
        await SimplePermissions.checkPermission(Permission.RecordAudio);
    if (!permission) {
      await SimplePermissions.requestPermission(Permission.RecordAudio);
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      _requestPermissions();
      _initChirp();
    } catch (e) {
      _chirpErrors = e.toString();
    }
  }

  @override
  void dispose() {
    _stopSDK();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopSDK();
    } else if (state == AppLifecycleState.resumed) {
      _startSDK();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Calibre',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sound data transfer',
              style: TextStyle(fontFamily: 'MarkPro')),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Text('1. Press start on both devices'),
                Text('1. Press send to send sample data'),
                SizedBox(
                  height: 20,
                ),
                Text('$_chirpData\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                RaisedButton(
                  child: Text('SEND', style: TextStyle(fontFamily: 'MarkPro')),
                  color: chirpYellow,
                  onPressed: _sendRandomPayload,
                ),
                RaisedButton(
                  child: Text(_startStopBtnText,
                      style: TextStyle(fontFamily: 'MarkPro')),
                  color: chirpYellow,
                  onPressed: _startStopSDK,
                ),
                SizedBox(
                  height: 50,
                ),
                Text('by @prasadsunny1'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
