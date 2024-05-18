import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:notes_app/common/conts_text.dart';

class ConnectivityService {
  late List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  void startMonitoring(BuildContext context) {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(context, result);
    });
  }

  Future<void> _updateConnectionStatus(BuildContext context, List<ConnectivityResult> result) async {
    _connectionStatus = result;
    if (_connectionStatus.contains(ConnectivityResult.none)) {
      _showNoInternetDialog(context);
    }
  }

  Future<void> _showNoInternetDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(noInternetConnection),
          content: const Text(pleaseConnectToInternet),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(ok),
            ),
          ],
        );
      },
    );
  }

  void stopMonitoring() {
    _connectivitySubscription.cancel();
  }
}
