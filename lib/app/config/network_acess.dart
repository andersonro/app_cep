import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkAcess {
  Future<bool> checkNetworkAcess() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }
}
