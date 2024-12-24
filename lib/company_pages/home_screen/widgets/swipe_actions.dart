import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeActions extends StatelessWidget {
  final CardSwiperController controller;

  const SwipeActions({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            onPressed: () => controller.swipe(CardSwiperDirection.left),
            icon: Icons.close,
            color: Colors.red,
            label: 'Skip',
          ),
          const SizedBox(width: 48),
          _buildActionButton(
            onPressed: () => controller.swipe(CardSwiperDirection.right),
            icon: Icons.favorite,
            color: Colors.green,
            label: 'Like',
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required String label,
    bool isLarge = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onPressed,
              child: Padding(
                padding: EdgeInsets.all(isLarge ? 20 : 16),
                child: Icon(
                  icon,
                  size: isLarge ? 40 : 32,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}