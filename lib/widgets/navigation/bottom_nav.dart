import 'package:flutter/material.dart';

class GNav extends StatelessWidget {
  final List<GButton> tabs;
  final int selectedIndex;
  final Function(int) onTabChange;
  final Color activeColor;
  final Color tabBackgroundColor;
  final Color color;
  final double gap;
  final EdgeInsets padding;

  const GNav({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChange,
    required this.activeColor,
    required this.tabBackgroundColor,
    required this.color,
    this.gap = 0,
    this.padding = EdgeInsets.zero,
    Color? rippleColor,
    Color? hoverColor,
    double? iconSize,
    Duration? duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(tabs.length, (index) {
        final isActive = index == selectedIndex;
        return InkWell(
          onTap: () => onTabChange(index),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: padding,
            decoration: BoxDecoration(
              color: isActive ? tabBackgroundColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  tabs[index].icon,
                  color: isActive ? activeColor : color,
                ),
                if (isActive) ...[
                  SizedBox(width: gap),
                  Text(
                    tabs[index].text,
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class GButton {
  final IconData icon;
  final String text;

  const GButton({required this.icon, required this.text});
}
