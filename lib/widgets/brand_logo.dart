import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.variant = BrandLogoVariant.hero});

  final BrandLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'web/assets/branding/yinling-app-logo.png',
      semanticLabel: '银聆项目品牌标识',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    switch (variant) {
      case BrandLogoVariant.header:
        return SizedBox(
          height: 36,
          width: 120,
          child: image,
        );
      case BrandLogoVariant.hero:
        return SizedBox(
          width: 58,
          height: 58,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: image,
          ),
        );
    }
  }
}

enum BrandLogoVariant {
  header,
  hero,
}
