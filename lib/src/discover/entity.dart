import 'package:flutter/cupertino.dart';

class Entity {
  final String userId;
  final bool isBusiness;
  final String username;
  final String address;
  final double distance;
  final List<String> tags;
  final String about;

  final NetworkImage primaryImage;

  Entity({
    required this.userId,
    required this.isBusiness,
    required this.username,
    required this.address,
    required this.distance,
    required this.tags,
    required this.about,
    required this.primaryImage,
    //this.images,
  });

}