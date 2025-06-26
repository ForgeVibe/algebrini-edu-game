import 'package:flutter/material.dart';

class AvatarSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onAvatarSelected;
  final int avatarCount;

  const AvatarSelector({
    super.key,
    required this.selectedIndex,
    required this.onAvatarSelected,
    this.avatarCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(avatarCount, (index) {
        return GestureDetector(
          onTap: () => onAvatarSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: selectedIndex == index ? 32 : 28,
              backgroundColor: selectedIndex == index ? Colors.deepPurple : Colors.grey[300],
              child: Text(
                String.fromCharCode(0x1F600 + index), // Emoji as placeholder
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
        );
      }),
    );
  }
} 