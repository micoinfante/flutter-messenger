import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class UserField {
  static final String lastMessageTime = 'lastMessageTime';
}

class User {
  final int id;
  final String name;
  final String photoURL;

  User({required this.id, required this.name, required this.photoURL});

  User.fromJson(Map<String, Object> json)
      : this(
          id: json['id']! as int,
          name: json['name']! as String,
          photoURL: json['photoURL']! as String,
        );

  Map<String, Object?> toJson() {
    return {'id': id, 'name': name, 'photoURL': photoURL};
  }
}

final User currentUser =
    User(id: 0, name: 'Current User', photoURL: 'assets/images/robot.jpg');

final User greg = User(id: 1, name: 'Greg', photoURL: 'assets/images/greg.jpg');

final User james =
    User(id: 2, name: 'James', photoURL: 'assets/images/james.jpg');

final User john = User(id: 3, name: 'John', photoURL: 'assets/images/john.jpg');

final User olivia =
    User(id: 4, name: 'Olivia', photoURL: 'assets/images/olivia.jpg');

final User steven =
    User(id: 5, name: 'Steven', photoURL: 'assets/images/steven.jpg');

final User sam = User(id: 6, name: 'Sam', photoURL: 'assets/images/sam.jpg');

final User sophia =
    User(id: 7, name: 'Sophia', photoURL: 'assets/images/sophia.jpg');

final List<User> users = [
  currentUser,
  greg,
  james,
  john,
  olivia,
  steven,
  sam,
  sophia
];
