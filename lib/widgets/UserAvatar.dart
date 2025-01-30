import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.radius,
    required this.imageUrl,
  });

  final double radius;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(child: CircleAvatar(radius: radius,child: imageUrl!=null ? Image.network(imageUrl!,fit: BoxFit.cover,width: double.infinity,
      height: double.infinity,errorBuilder: (context, error, stackTrace) => Icon(Icons.error),loadingBuilder: (context, child, loadingProgress) => loadingProgress==null ? child : LinearProgressIndicator(),) : Icon(FontAwesomeIcons.user),),);
  }
}