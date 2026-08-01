import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Handles the "snap the collapsible header fully open/closed" scroll
/// behavior. Mix this into any State that owns a CustomScrollView and
/// wants this snapping effect, without polluting that State with the
/// timing/physics details.
mixin HomeScrollSnapMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();

  /// The full collapsible range of the header (content height only,
  /// not status bar). Override if a subclass needs a different value.
  double get snapRange => 95.0;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      _snap();
    } else if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle) {
      _snap();
    }
    return false; // let it bubble to RefreshIndicator
  }

  void _snap() {
    if (!scrollController.hasClients) return;

    // Slight delay so we don't fight Flutter's internal scroll momentum physics
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || !scrollController.hasClients) return;

      final double offset = scrollController.offset;
      if (offset <= 0.0 || offset >= snapRange) return;

      final double target = offset > (snapRange / 2.0) ? snapRange : 0.0;

      scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }
}
