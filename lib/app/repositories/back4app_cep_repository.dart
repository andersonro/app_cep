import 'package:app_cep/app/config/network_acess.dart';
import 'package:app_cep/app/models/back4app_cep_model.dart';
import 'package:app_cep/app/repositories/dio_custom.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Back4appCepRepository {
  final service = DioCustom();
  final networkAcess = NetworkAcess();
  final msgNotNetworkAcess = "Verifique sua conexão com internet!";

  Back4appCepRepository() {
    initBack4app();
  }

  Future<void> initBack4app() async {
    WidgetsFlutterBinding.ensureInitialized();
    const keyApplicationId = '8zJAyqWnz84EamNn2srjH4waIEd64WO5K9kgYow4';
    const keyClientKey = '2Ez2NwH7EjCtfT9gScrqUAltH2foqMoDeP7EJWG0';
    const keyParseServerUrl = 'https://parseapi.back4app.com';

    await Parse().initialize(
      keyApplicationId,
      keyParseServerUrl,
      clientKey: keyClientKey,
      debug: true,
    );
  }

  Future<void> save(Back4appCepModel back4appCepModel) async {
    final cep =
        ParseObject('Ceps')
          ..set('cep', back4appCepModel.cep)
          ..set('logradouro', back4appCepModel.logradouro)
          ..set('complemento', back4appCepModel.complemento)
          ..set('bairro', back4appCepModel.bairro)
          ..set('localidade', back4appCepModel.localidade)
          ..set('uf', back4appCepModel.uf)
          ..set('ibge', int.parse(back4appCepModel.codIbge.toString()))
          ..set('cod_ibge', back4appCepModel.codIbge);
    var save = await cep.save();
    debugPrint('save: $save');
  }

  Future<List<Back4appCepModel>> getCep() async {
    await initBack4app();
    QueryBuilder<ParseObject> queryCeps = QueryBuilder<ParseObject>(
      ParseObject('Ceps'),
    );
    final ParseResponse apiResponse = await queryCeps.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results!
          .map((e) => Back4appCepModel.fromJson(e.toJson()))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> deleteCep(String id) async {
    var cep = ParseObject('Ceps')..objectId = id;
    await cep.delete();
  }

  Future<Back4appCepModel> fetchCep(String cep) async {
    await initBack4app();
    QueryBuilder<ParseObject> queryCeps = QueryBuilder<ParseObject>(
      ParseObject('Ceps'),
    );
    queryCeps.whereEqualTo('cep', cep);
    final ParseResponse apiResponse = await queryCeps.query();
    debugPrint('apiResponse fetch: ${apiResponse.results}');
    if (apiResponse.success && apiResponse.results != null) {
      return Back4appCepModel.fromJson(apiResponse.results!.first.toJson());
    } else {
      return Back4appCepModel();
    }
  }
}
