import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

class LandingButton extends StatelessWidget {
  final String assetPath;
  final Function onTap;

  LandingButton({@required this.assetPath, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Container(
        child: GestureDetector(
          onTap: onTap,
          child: WebsafeSvg.asset(assetPath),
        ),
      ),
      clipper: ButtonClipper(),
    );
  }
}

class ButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final sw = size.width;
    final sh = size.height;
    path.lineTo(0, sh);
    path.lineTo(sw, sh * 0.53);
    path.lineTo(sw, 0);
    path.lineTo(0, sh * 0.47);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
