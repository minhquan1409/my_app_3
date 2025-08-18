import 'package:flutter/material.dart';

IconData getIconData(String iconName) {
  switch (iconName) {
    case 'speaker':
      return Icons.speaker;
    case 'phone_iphone':
      return Icons.phone_iphone;
    case 'laptop_mac':
      return Icons.laptop_mac;
    case 'watch':
      return Icons.watch;
    case 'headphones':
      return Icons.headphones;
    case 'tablet_mac':
      return Icons.tablet_mac;
    case 'computer':
      return Icons.computer;
    case 'monitor':
      return Icons.monitor;
    default:
      return Icons.category;
  }
}
