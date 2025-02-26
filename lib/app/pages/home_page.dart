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

  final listaData = [
    'Rio de Janeiro',
    'São Paulo',
    'Rio Grande do Sul',
    'Santa Catarina',
    'Paraná',
    'Minas Gerais',
    'Espírito Santo',
    'Bahia',
  ];

  searchCep(String cep) async {
    try {
      ViaCepModel data = await viaCepController.searchCep(cep);
      debugPrint('Localidade: ${data.toJson().toString()}');
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Lista de CEP"),
              actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
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
                            onPressed: () {
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
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          itemCount: listaData.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CEP: 00000-000',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Rua: Rua 1'),
                                    Text('Bairro: Bairro 2'),
                                    Text('Cidade: Cidade'),
                                    Text('Estado: Estado 2'),
                                  ],
                                ),
                              ),
                            );
                          },
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
          if (viaCepController.getState == ViaCepState.loading) {
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
