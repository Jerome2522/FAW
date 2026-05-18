import 'package:flutter/material.dart';

class LazyIndexedStackChild extends StatefulWidget {
  final Widget child;
  final bool isActivated;

  const LazyIndexedStackChild({
    super.key,
    required this.child,
    required this.isActivated,
  });

  @override
  State<LazyIndexedStackChild> createState() => _LazyIndexedStackChildState();
}

class _LazyIndexedStackChildState extends State<LazyIndexedStackChild> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActivated) {
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStackChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActivated && !_initialized) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _initialized ? widget.child : const SizedBox.shrink();
  }
}
