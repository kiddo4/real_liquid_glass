import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'glass_style.dart';

/// Embeds the native UIVisualEffectView that carries the glass material.
///
/// On iOS 26+ this is real UIGlassEffect Liquid Glass; on older iOS it is
/// a UIBlurEffect system material. Either way the effect samples the
/// content rendered beneath it — Flutter widgets included.
class NativeGlassView extends StatefulWidget {
  const NativeGlassView({
    super.key,
    required this.style,
    required this.shape,
    required this.interactive,
    this.tint,
  });

  final LiquidGlassStyle style;
  final LiquidGlassShape shape;
  final bool interactive;
  final Color? tint;

  @override
  State<NativeGlassView> createState() => _NativeGlassViewState();
}

class _NativeGlassViewState extends State<NativeGlassView> {
  MethodChannel? _viewChannel;

  Map<String, Object?> get _params => {
        'style': widget.style.name,
        'tint': widget.tint?.toARGB32(),
        'interactive': widget.interactive,
        'capsule': widget.shape.capsule,
        'cornerRadius': widget.shape.cornerRadius,
      };

  @override
  void didUpdateWidget(NativeGlassView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style != oldWidget.style ||
        widget.shape != oldWidget.shape ||
        widget.interactive != oldWidget.interactive ||
        widget.tint != oldWidget.tint) {
      _viewChannel?.invokeMethod<void>('update', _params);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.interactive,
      child: UiKitView(
        viewType: 'liquid_glass_container/glass_view',
        creationParams: _params,
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: widget.interactive
            ? PlatformViewHitTestBehavior.opaque
            : PlatformViewHitTestBehavior.transparent,
        onPlatformViewCreated: (id) {
          _viewChannel =
              MethodChannel('liquid_glass_container/glass_view_$id');
        },
      ),
    );
  }
}
