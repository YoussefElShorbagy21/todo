import 'package:flutter/material.dart';
import 'package:todo/ui/theme.dart';

import '../size_config.dart';

class InputField extends StatelessWidget {
  const InputField({Key? key,
    required this.title,
    required this.note,
    this.controller,
    this.widget,}) : super(key: key);

  final String title ;
  final String note ;
  final TextEditingController? controller ;
  final Widget? widget ;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin:  const EdgeInsets.only(top : 16),
    child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
        style: Themes().titleStyle,),
        Container(
        padding: const EdgeInsets.only(left: 14),
        margin:  const EdgeInsets.only(top: 8),
        width: SizeConfig.screenWidth,
        height: 52,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
        color: Colors.grey,
        )
        ),
        child: Row(
          children: [
            Expanded(child:
            TextFormField(
              controller: controller,
              autofocus: false,
              cursorColor: Colors.grey,
              readOnly: widget != null ? true : false,
              style: Themes().subtitleStyle,
              decoration: InputDecoration(
                hintText: note,
                hintStyle: Themes().subtitleStyle,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).backgroundColor,
                    width: 0,
                  )
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).backgroundColor,
                        width: 0,
                    )
                ),
              ),
            ),
            ),
            widget ?? Container(),
          ],
        )
        ),
      ],
    ),
    );
  }
}
