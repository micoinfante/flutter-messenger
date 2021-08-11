import 'package:flutter/material.dart';
import 'package:messenger/model/user.dart';

class FavoriteContacts extends StatelessWidget {
  static const List<User> favorites = users;
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Favorite Contacts',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz),
                iconSize: 30,
                color: Colors.blueGrey,
              )
            ],
          )),
      Container(
        height: 120,
        color: Colors.blue,
        child: ListView.builder(
          padding: EdgeInsets.only(left: 10.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return Text(favorites[index].name);
          },
          itemCount: favorites.length,
        ),
      )
    ]);
  }
}
