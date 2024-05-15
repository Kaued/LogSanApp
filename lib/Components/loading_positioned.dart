import 'package:flutter/material.dart';

class LoadingPositioned extends StatelessWidget {
  const LoadingPositioned(
      {super.key,
      required this.loading,
      this.top,
      this.left,
      this.right,
      this.bottom});

  final bool loading;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    if (loading) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
          height: screen.height,
          width: screen.width,
          color: Colors.black38,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Container();
  }
}
