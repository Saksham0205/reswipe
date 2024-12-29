import 'package:flutter/material.dart';

class AnimatedAppBar extends StatelessWidget {
  final bool hasItems;
  final VoidCallback onClearAll;
  final VoidCallback onBack;

  const AnimatedAppBar({
    Key? key,
    required this.hasItems,
    required this.onClearAll,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Matches'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        if (hasItems)
          IconButton(
            icon: const Icon(Icons.delete,),
            onPressed: onClearAll,
          ),
      ],
    );
  }
}