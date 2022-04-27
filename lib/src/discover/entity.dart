import 'package:flutter/cupertino.dart';

class Entity {

  final String name;
  final String address;
  final double distance;
  final List<String> tags;
  final String about;

  final NetworkImage primaryImage;
  final List<NetworkImage> images;

  Entity({
    required this.name,
    required this.address,
    required this.distance,
    required this.tags,
    required this.about,
    required this.primaryImage,
    required this.images,
  });

}