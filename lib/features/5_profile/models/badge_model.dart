import 'package:flutter/material.dart';

class BadgeInfo {
  final String name;
  final IconData icon;
  final Color color;
  final int minPoints;

  const BadgeInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.minPoints,
  });
}

class BadgeService {
  static const List<BadgeInfo> allBadges = [
    BadgeInfo(name: 'Beginner', icon: Icons.star_border, color: Colors.grey, minPoints: 0),
    BadgeInfo(name: 'Event Goer', icon: Icons.star_half, color: Colors.blue, minPoints: 30),
    BadgeInfo(name: 'Event Pro', icon: Icons.star, color: Colors.purple, minPoints: 100),
    BadgeInfo(name: 'Event Master', icon: Icons.verified, color: Colors.amber, minPoints: 250),
  ];

  static BadgeInfo getBadgeForPoints(int points) {
    return allBadges.lastWhere(
      (badge) => points >= badge.minPoints,
      orElse: () => allBadges.first,
    );
  }
}