import 'package:flutter/material.dart';

import '../../../utils/config.dart';

class EditLabels extends StatefulWidget {
  const EditLabels({super.key});

  @override
  State<EditLabels> createState() => _EditLabelsState();
}

class _EditLabelsState extends State<EditLabels> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit labels"),
      content: SizedBox(
        height: 190,
        child: Column(children: buildWidget()),
      ),
    );
  }

  List<Widget> buildWidget() {
    List<Widget> labelContainers = [];
    for (int i = 0; i < labels.length; i++) {
      labelContainers.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Container(
          height: 35,
          decoration: BoxDecoration(
              color: labels[i], borderRadius: BorderRadius.circular(5)),
        ),
      ));
    }
    return labelContainers;
  }
}
