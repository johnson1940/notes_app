import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
