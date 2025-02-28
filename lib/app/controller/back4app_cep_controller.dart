import 'package:app_cep/app/config/custom_exception.dart';
import 'package:app_cep/app/models/back4app_cep_model.dart';
import 'package:app_cep/app/models/via_cep_model.dart';
import 'package:app_cep/app/repositories/back4app_cep_repository.dart';
import 'package:get/get.dart';

class Back4appCepController extends GetxController {
  Back4appCepRepository back4appCepRepository = Back4appCepRepository();

  final _state = Back4AppCepState.start.obs;
  Rx<Back4AppCepState> get getState => _state.value.obs;

  final _listaCeps = <Back4appCepModel>[].obs;
  RxList<Back4appCepModel> get getListaCeps => _listaCeps;

  getCeps() async {
    try {
      _state.value = Back4AppCepState.loading;
      var data = await back4appCepRepository.getCep();
      _listaCeps.clear();
      if (data.isNotEmpty) {
        _listaCeps.addAll(data);
      }
      _listaCeps.refresh();
      _state.value = Back4AppCepState.success;
    } catch (e) {
      _state.value = Back4AppCepState.error;
      throw CustomException(message: e.toString());
    }
  }

  deleteCep(String id) async {
    try {
      _state.value = Back4AppCepState.loading;
      await back4appCepRepository.deleteCep(id);
      getCeps();
      _state.value = Back4AppCepState.success;
    } catch (e) {
      _state.value = Back4AppCepState.error;
      throw CustomException(message: e.toString());
    }
  }

  saveCep(ViaCepModel viaCepModel) async {
    try {
      _state.value = Back4AppCepState.loading;
      Back4appCepModel exists = await back4appCepRepository.fetchCep(
        viaCepModel.cep!,
      );

      if (exists.cep != null) {
        throw CustomException(message: 'CEP já cadastrado!');
      } else {
        Back4appCepModel back4appCepModel = Back4appCepModel(
          cep: viaCepModel.cep,
          logradouro: viaCepModel.logradouro,
          complemento: viaCepModel.complemento,
          bairro: viaCepModel.bairro,
          localidade: viaCepModel.localidade,
          uf: viaCepModel.uf,
          codIbge: viaCepModel.ibge,
        );
        await back4appCepRepository.save(back4appCepModel);
        getCeps();
        _state.value = Back4AppCepState.success;
      }
    } catch (e) {
      _state.value = Back4AppCepState.error;
      throw CustomException(message: e.toString());
    }
  }
}

enum Back4AppCepState { start, loading, success, error }
