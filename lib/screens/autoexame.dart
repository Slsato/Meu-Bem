import 'package:flutter/material.dart';
import 'package:health_truck/widget/default_layout.dart';
import 'package:health_truck/widget/text_labels.dart';

class AutoexameScreen extends StatelessWidget {
  const AutoexameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Autoexame',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildText('Tipos de Autoexame'),
          const SizedBox(height: 10),
          _examTile(
            context,
            title: 'Autoexame das Mamas',
            description:
            'Verifique alterações no formato, cor ou presença de caroços nas mamas e axilas.',
            content:
            '1. Em frente ao espelho, observe alterações no formato ou cor.\n'
                '2. Com a ponta dos dedos, apalpe a mama em movimentos circulares.\n'
                '3. Faça o exame em pé e deitada.\n'
                '4. Realize uma vez por mês, preferencialmente 7 dias após a menstruação.',
          ),
          _examTile(
            context,
            title: 'Autoexame de Pele',
            description:
            'Verifique manchas ou pintas com alterações de cor, tamanho ou bordas irregulares.',
            content:
            '1. Observe todo o corpo usando dois espelhos.\n'
                '2. Verifique costas, couro cabeludo, pés, unhas, axilas e genitais.\n'
                '3. Consulte um médico se notar alterações.\n'
                '4. Realize uma vez por mês.',
          ),
          _examTile(
            context,
            title: 'Autoexame Testicular',
            description:
            'Ajuda na detecção precoce do câncer de testículo, especialmente em homens jovens.',
            content:
            '1. Após o banho quente, examine os testículos com as mãos.\n'
                '2. Procure por caroços, inchaços ou mudanças no tamanho.\n'
                '3. Realize o exame mensalmente.\n'
                '4. Se notar algo diferente, procure um urologista.',
          ),
          _examTile(
            context,
            title: 'Autoavaliação da Saúde Bucal',
            description:
            'Verifique feridas, caroços ou alterações na boca, gengiva e língua.',
            content:
            '1. Observe a boca em frente ao espelho.\n'
                '2. Procure por manchas brancas, feridas que não cicatrizam ou sangramentos.\n'
                '3. Verifique se há dor ao mastigar ou mobilidade dos dentes.\n'
                '4. Faça mensalmente e mantenha higiene bucal.',
          ),
          _examTile(
            context,
            title: 'Autoexame da Tireoide',
            description:
            'Pode indicar alterações como nódulos ou aumento da glândula.',
            content:
            '1. Em frente ao espelho, incline a cabeça para trás.\n'
                '2. Beba um gole de água e observe a parte inferior do pescoço.\n'
                '3. Procure por saliências ou assimetrias.\n'
                '4. Caso veja algo estranho, consulte um endocrinologista.',
          ),
        ],
      ),
    );
  }

  Widget _examTile(BuildContext context,
      {required String title,
        required String description,
        required String content}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.lightBlueAccent,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
