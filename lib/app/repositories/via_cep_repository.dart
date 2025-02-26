import 'package:app_cep/app/config/custom_exception.dart';
import 'package:app_cep/app/models/via_cep_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/network_acess.dart';

import 'dio_custom.dart';

class ViaCepRepository {
  final _service = DioCustom();
  final networkAcess = NetworkAcess();
  final msgNotNetworkAcess = "Verifique sua conexão com internet!";

  Future consultaCep(String cep) async {
    var isNetworkAcess = await networkAcess.checkNetworkAcess();

    if (isNetworkAcess != false) {
      String c = cep.replaceAll('-', '').replaceAll('.', '');
      var endPoint = "https://viacep.com.br/ws/$c/json/";

      try {
        var response = await _service.dio.get(endPoint);

        if (response.statusCode == 200) {
          return ViaCepModel.fromJson(response.data);
        }
      } catch (e) {
        if (e is DioException) {
          throw e.response!.data['message'];
        } else {
          throw CustomException(message: e.toString());
        }
      }
    } else {
      throw CustomException(message: msgNotNetworkAcess);
    }
  }
}
