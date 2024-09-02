import 'package:connections_taiwan/constants.dart';
import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final bool isSelected;
  final String word;
  final double fontSize;
  final void Function()? onTap;
  const WordCard(
      {super.key,
      this.word = '',
      this.fontSize = 25,
      this.isSelected = false,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            height: Constants.wordCardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            width: constraints.maxWidth / Constants.wordCardWidthDevisionFactor,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                word,
                style: TextStyle(
                    fontSize: fontSize,
                    color: isSelected ? Colors.white : Colors.black),
              ),
            ),
          );
        }),
      ),
    );
  }
}
