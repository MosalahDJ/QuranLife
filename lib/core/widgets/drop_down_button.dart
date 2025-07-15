import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/Utils/constants.dart';
import 'package:project/features/controller/settings%20controllers/language_controller.dart';

class DropDownButton extends StatefulWidget {
  const DropDownButton({
    super.key,
    required this.ontap,
    required this.buttontext,
    required this.color,
    required this.icon,
    this.ontap2,
    this.buttontext2,
    this.icon2,
    this.scrollController,
  });

  final VoidCallback ontap;
  final String buttontext;
  final Color color;
  final IconData icon;
  final VoidCallback? ontap2;
  final String? buttontext2;
  final IconData? icon2;

  // Optional scroll controller for auto-dismiss on scroll
  final ScrollController? scrollController;

  @override
  State<DropDownButton> createState() => _DropDownButtonState();
}

class _DropDownButtonState extends State<DropDownButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final LanguageController langctrl = Get.find();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
            child: Stack(
              children: [
                Positioned(
                  left: offset.dx,
                  top: offset.dy + size.height,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset:
                        langctrl.language.value == "ar"
                            ? Offset(10, 10)
                            : Offset(-50, 10),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 10,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Get.isDarkMode
                                  ? kmaincolor2dark
                                  : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                _removeOverlay();
                                widget.ontap();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
                                    Icon(
                                      widget.icon,
                                      size: 20,
                                      color: widget.color,
                                    ),
                                    const SizedBox(width: 8, height: 20),
                                    Text(widget.buttontext),
                                  ],
                                ),
                              ),
                            ),
                            if (widget.buttontext2 != null)
                              InkWell(
                                onTap: () {
                                  _removeOverlay();
                                  widget.ontap2?.call();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.icon2,
                                        size: 20,
                                        color: widget.color,
                                      ),
                                      const SizedBox(width: 8, height: 20),
                                      Text(widget.buttontext2!),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Optional: auto-dismiss on scroll
    widget.scrollController?.addListener(_removeOverlay);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;

      widget.scrollController?.removeListener(_removeOverlay);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.white, size: 30),
        onPressed: _toggleOverlay,
      ),
    );
  }
}
