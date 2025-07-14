import 'package:flutter/material.dart';

class DropDownButton extends StatelessWidget {
  const DropDownButton({
    super.key,
    required this.ontap,
    required this.buttontext,
    required this.color,
    required this.icon,
    this.ontap2,
    this.buttontext2,
    this.color2,
    this.icon2,
  });
  final VoidCallback ontap;
  final String buttontext;
  final Color color;
  final IconData icon;
  final VoidCallback? ontap2;
  final String? buttontext2;
  final Color? color2;
  final IconData? icon2;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Colors.white, size: 30),
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem<String>(
              onTap: ontap,
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(buttontext),
                ],
              ),
            ),
            buttontext2 != null
                ? PopupMenuItem<String>(
                  onTap: ontap2,
                  child: Row(
                    children: [
                      Icon(icon2, color: color2),
                      const SizedBox(width: 8),
                      Text(buttontext2!),
                    ],
                  ),
                )
                : PopupMenuItem<String>(height: 0, child: SizedBox.shrink()),
          ],
    );
  }
}
