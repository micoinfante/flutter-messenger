import 'package:flutter/material.dart';
import 'package:messenger/model/user.dart';
import 'package:messenger/screens/chat_screen.dart';

class FavoriteContacts extends StatelessWidget {
  final List<User> favorites = users;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(children: <Widget>[
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
          child: ListView.builder(
            padding: EdgeInsets.only(left: 10.0),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatScreen(user: favorites[index]))),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(favorites[index].photoURL),
                      ),
                      SizedBox(height: 6),
                      Text(
                        favorites[index].name,
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: favorites.length,
          ),
        )
      ]),
    );
  }
}
