import 'package:app_cep/app/config/custom_exception.dart';
import 'package:app_cep/app/controller/back4app_cep_controller.dart';
import 'package:app_cep/app/controller/via_cep_controller.dart';
import 'package:app_cep/app/models/via_cep_model.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController cepController = TextEditingController();
  late ViaCepController viaCepController = ViaCepController();
  late Back4appCepController back4appCepController = Back4appCepController();

  searchCep(String cep) async {
    try {
      ViaCepModel data = await viaCepController.searchCep(cep);
      if (data.cep != null) {
        infoCep(data);
      } else {
        throw CustomException(message: 'Nenhum CEP localizado!');
      }
    } on Exception catch (e) {
      debugPrint('Erro: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  infoCep(ViaCepModel viaCepModel) {
    debugPrint('cep: ${viaCepModel.cep}');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CEP: ${viaCepModel.cep}', textAlign: TextAlign.center),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CEP: ${viaCepModel.cep}', textAlign: TextAlign.start),
              Text(
                'Logradouro: ${viaCepModel.logradouro}',
                textAlign: TextAlign.start,
              ),
              Text('Bairro: ${viaCepModel.bairro}', textAlign: TextAlign.start),
              Text(
                'Cidade: ${viaCepModel.localidade}',
                textAlign: TextAlign.start,
              ),
              Text('Estado: ${viaCepModel.uf}', textAlign: TextAlign.start),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await saveCep(viaCepModel);
                    },
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  saveCep(ViaCepModel viaCepModel) async {
    try {
      await back4appCepController.saveCep(viaCepModel);
      setState(() => cepController.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cep cadastrado com sucesso!',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadCeps();
  }

  loadCeps() async {
    back4appCepController = Back4appCepController();
    await back4appCepController.getCeps();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Lista de CEP"),
              actions: [
                IconButton(
                  onPressed: () async {
                    await loadCeps();
                  },
                  icon: Icon(Icons.refresh),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    child: Form(
                      key: formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cepController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'CEP',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira sua CEP';
                                }

                                if (value.length < 10) {
                                  return 'CEP inválido';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CepInputFormatter(),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                searchCep(cepController.text);
                              }
                            },
                            icon: Icon(Icons.search),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),

                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Obx(
                        () =>
                            back4appCepController.getListaCeps.isNotEmpty
                                ? SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: ListView.builder(
                                    //shrinkWrap: true,
                                    //physics: const ClampingScrollPhysics(),
                                    itemCount:
                                        back4appCepController
                                            .getListaCeps
                                            .length,
                                    itemBuilder: (_, index) {
                                      var cep =
                                          back4appCepController
                                              .getListaCeps[index];
                                      return Dismissible(
                                        key: Key(cep.objectId.toString()),
                                        direction: DismissDirection.endToStart,
                                        confirmDismiss: (direction) {
                                          return showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Excluir'),
                                                content: Text(
                                                  'Deseja excluir o CEP ${cep.cep}?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await back4appCepController
                                                          .deleteCep(
                                                            cep.objectId!,
                                                          );
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text('Excluir'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        onDismissed: (direction) {
                                          debugPrint(
                                            'DIRECTION: ${direction.toString()}',
                                          );
                                        },
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'CEP: ${cep.cep}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text('${cep.logradouro}'),
                                                Text('${cep.bairro}'),
                                                Text('${cep.localidade}'),
                                                Text('${cep.uf}'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Container(
                                  alignment: Alignment.center,
                                  child: Text('Nenhum CEP cadastrado!'),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() {
          late Widget w;
          if ((viaCepController.getState.value == ViaCepState.loading) ||
              (back4appCepController.getState.value ==
                  Back4AppCepState.loading)) {
            w = Container(
              alignment: Alignment.center,
              color: Colors.black.withValues(alpha: 0.8),
              width: double.infinity,
              height: double.infinity,
              child: const CircularProgressIndicator(),
            );
          } else {
            w = SizedBox.shrink();
          }
          return w;
        }),
      ],
    );
  }
}
