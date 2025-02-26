import 'package:app_cep/app/config/custom_exception.dart';
import 'package:app_cep/app/models/via_cep_model.dart';
import 'package:get/get.dart';

import '../repositories/via_cep_repository.dart';

class ViaCepController extends GetxController {
  ViaCepModel viaCepModel = ViaCepModel();
  ViaCepRepository viaCepRepository = ViaCepRepository();

  final _state = ViaCepState.start.obs;
  Rx<ViaCepState> get getState => _state.value.obs;

  searchCep(String cep) async {
    try {
      _state.value = ViaCepState.loading;
      var data = await viaCepRepository.consultaCep(cep);
      ViaCepModel viaCepModel = data;
      _state.value = ViaCepState.success;
      return viaCepModel;
    } catch (e) {
      _state.value = ViaCepState.error;
      throw CustomException(message: e.toString());
    }
  }
}

enum ViaCepState { start, loading, success, error }
