import 'package:flutter/material.dart';

class EnterBarcodePage extends StatefulWidget {
  const EnterBarcodePage({super.key});

  @override
  State<EnterBarcodePage> createState() => _EnterBarcodePageState();
}

class _EnterBarcodePageState extends State<EnterBarcodePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
            child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: _controller,
            )),
            Expanded(
                child: TextButton(
                    onPressed: () =>
                        {Navigator.pop(context, _controller.value.text)},
                    child: const Center(
                      child: Text("Submit"),
                    )))
          ],
        ))
      ],
    ));
  }
}
