import 'package:flutter/material.dart';

class AvatarSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onAvatarSelected;

  const AvatarSelector({
    super.key,
    required this.selectedIndex,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Choose Your Avatar',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _avatars.length,
          itemBuilder: (context, index) {
            final avatar = _avatars[index];
            final isSelected = selectedIndex == index;
            
            return GestureDetector(
              onTap: () => onAvatarSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      avatar['icon'],
                      size: 32,
                      color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      avatar['name'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static const List<Map<String, dynamic>> _avatars = [
    {'icon': Icons.face, 'name': 'Happy'},
    {'icon': Icons.psychology, 'name': 'Brain'},
    {'icon': Icons.school, 'name': 'Student'},
    {'icon': Icons.science, 'name': 'Scientist'},
    {'icon': Icons.emoji_emotions, 'name': 'Smile'},
    {'icon': Icons.auto_awesome, 'name': 'Star'},
    {'icon': Icons.rocket_launch, 'name': 'Rocket'},
    {'icon': Icons.pets, 'name': 'Pet'},
    {'icon': Icons.sports_esports, 'name': 'Gamer'},
    {'icon': Icons.music_note, 'name': 'Music'},
    {'icon': Icons.sports_soccer, 'name': 'Soccer'},
    {'icon': Icons.brush, 'name': 'Artist'},
    {'icon': Icons.computer, 'name': 'Tech'},
    {'icon': Icons.nature, 'name': 'Nature'},
    {'icon': Icons.sports_basketball, 'name': 'Basketball'},
    {'icon': Icons.emoji_events, 'name': 'Champion'},
  ];
} 