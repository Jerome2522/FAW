import 'package:flutter/material.dart';

/// A custom, high-performance tab-switching container that preserves page state
/// while providing an ultra-premium, buttery-smooth cross-fade and subtle scale-up transition.
class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        vsync: this,
        duration: widget.duration,
        value: index == widget.index ? 1.0 : 0.0,
      ),
    );
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      // Smoothly cross-fade tabs using ease-in-out cubic curve
      _controllers[oldWidget.index].reverse();
      _controllers[widget.index].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (index) {
        final animation = CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOutCubic,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: IgnorePointer(
              ignoring: index != widget.index,
              child: TickerMode(
                enabled: index == widget.index || _controllers[index].isAnimating,
                child: widget.children[index],
              ),
            ),
          ),
        );
      }),
    );
  }
}
