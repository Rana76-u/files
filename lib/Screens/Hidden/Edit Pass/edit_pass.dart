import 'package:files/APIs/hive_api.dart';
import 'package:flutter/material.dart';

import '../../../components/helpers/utils.dart';
import '../../calculator_screens/main/main_screen.dart';

class EditPass extends StatefulWidget {
  const EditPass({super.key});

  @override
  State<EditPass> createState() => _EditPassState();
}

class _EditPassState extends State<EditPass> {
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {


    final List<ButtonModel> buttons = [
      ButtonModel(operator: 'C', tooltip: 'Clear'),
      ButtonModel(operator: '()', tooltip: 'Brackets'),
      ButtonModel(operator: '%', tooltip: 'Percentage', isBold: true),
      ButtonModel(operator: '÷', tooltip: 'Division', size: 32.0, /*isBold: true*/),
      ButtonModel(operator: '7'),
      ButtonModel(operator: '8'),
      ButtonModel(operator: '9'),
      ButtonModel(
        operator: '×',
        tooltip: 'Multiplication',
        size: 32.0,
        //isBold: true,
      ),
      ButtonModel(operator: '4'),
      ButtonModel(operator: '5'),
      ButtonModel(operator: '6'),
      ButtonModel(operator: '-', tooltip: 'Minus', size: 32.0, isBold: true),
      ButtonModel(operator: '1'),
      ButtonModel(operator: '2'),
      ButtonModel(operator: '3'),
      ButtonModel(operator: '+', tooltip: 'Plus', size: 32.0, isBold: true),
      ButtonModel(operator: '+/-'),
      ButtonModel(operator: '0'),
      ButtonModel(operator: '.'),
      ButtonModel(operator: '＝', tooltip: 'Equal', size: 32.0, isBold: true),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 30,),
            textFieldWidget(passController, 'Enter New Password'),

            const Divider(thickness: 1, indent: 16, endIndent: 16,),

            //buttons
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 16.0,
              ),
              children: buttons
                  .map((e) => _ButtonItem(passController: passController,buttonModel: e))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget textFieldWidget(TextEditingController textEditingController, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            minHeight: 60,
            maxHeight: 150
        ),
        child: TextField(
          controller: textEditingController,
          autofocus: true,
          autocorrect: false,
          maxLines: null,
          readOnly: true, // Set readOnly to true to prevent the keyboard from showing up
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            prefixIcon: const Icon(
              Icons.short_text_rounded,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            hintText: hint,
          ),
          cursorColor: Colors.black,
        ),
      ),
    );
  }

}

class _ButtonItem extends StatefulWidget {
  const _ButtonItem({
    required this.buttonModel,
    required this.passController,
  });

  final ButtonModel buttonModel;
  final TextEditingController passController;

  @override
  State<_ButtonItem> createState() => __ButtonItemState();
}

class __ButtonItemState extends State<_ButtonItem> {
  String? _longPress;

  @override
  void initState() {
    widget.passController.text = getFromHive('password')!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final operator = widget.buttonModel.operator;
    final isHold = _longPress == operator;
    final tooltip = widget.buttonModel.tooltip ?? '';
    final isParentheses = operator == '()';
    final isClear = operator == 'C';
    final isEqual = operator == '＝';
    final color = isEqual
        ? Colors.white
        : isClear
        ? Colors.red
        : Utils.isNumber(operator) || operator == '+/-'
        ? Theme.of(context).textTheme.bodyMedium?.color
        :  const Color(0xFF799e03);//Theme.of(context).primaryColor;

    final backgroundColor = isEqual ? const Color(0xFF87b003)//Theme.of(context).primaryColor
        :
    isParentheses || isClear || (!Utils.isNumber(operator) && operator != '+/-' && operator != '.')
        ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.075)
        :
    Colors.white;
    //Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1);

    //final size = widget.buttonModel.size;
    //final isBold = widget.buttonModel.isBold;

    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTapUp: (details) {
            },
            onTapDown: (details) {
            },
            onTapCancel: () {
            },
            onTap: () async {

              if (isClear) {
                widget.passController.clear();
              }
              else if (isEqual) {

                if(widget.passController.text.isNotEmpty){
                  password = widget.passController.text;

                  updateHive('password', widget.passController.text);

                  widget.passController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password Updated')),
                  );
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password cannot be empty')),
                  );
                }

              }
              else{
                widget.passController.text += operator;
              }

              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: FittedBox(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 100),
                    style: TextStyle(
                        color: color,
                        fontSize: 30 - (isHold ? 5 : 0), ///size - (isHold ? 5 : 0)
                        letterSpacing: isParentheses ? 8 : null,
                        //fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                        fontWeight: isEqual ? FontWeight.bold : FontWeight.normal
                    ),
                    child: Text(operator),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}