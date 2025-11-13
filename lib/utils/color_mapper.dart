import 'package:flutter/material.dart';

String colorToName(Color color) {
  if (color == Colors.orange) return 'orange';
  if (color == Colors.pink) return 'pink';
  if (color == Colors.cyan) return 'cyan';
  if (color == Colors.blueGrey) return 'blueGrey';
  if (color == Colors.deepPurple) return 'deepPurple';
  if (color == Colors.brown) return 'brown';
  if (color == Colors.green) return 'green';
  if (color == Colors.amber) return 'amber';
  if (color == Colors.teal) return 'teal';
  return 'unknown';
}

Color nameToColor(String name) {
  switch (name) {
    case 'orange': return Colors.orange;
    case 'pink': return Colors.pink;
    case 'cyan': return Colors.cyan;
    case 'blueGrey': return Colors.blueGrey;
    case 'deepPurple': return Colors.deepPurple;
    case 'brown': return Colors.brown;
    case 'green': return Colors.green;
    case 'amber': return Colors.amber;
    case 'teal': return Colors.teal;
    default: return Colors.grey;
  }
}
