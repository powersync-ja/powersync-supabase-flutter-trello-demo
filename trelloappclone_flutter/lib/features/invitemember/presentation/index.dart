import 'package:flutter/material.dart';
import 'package:trelloappclone_flutter/utils/color.dart';

class InviteMember extends StatefulWidget {
  const InviteMember({super.key});

  @override
  State<InviteMember> createState() => _InviteMemberState();
}

class _InviteMemberState extends State<InviteMember> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, size: 30),
        ),
        title: const Text("Invite to Board 1"),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.contacts))
        ],
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Name, Email, Username",
                      prefix: Icon(Icons.search)),
                ),
              ),
              Card(
                child: ListTile(
                  textColor: brandColor,
                  title: Text("Create board invite link"),
                  subtitle: Text("Anyone with a link can join the board"),
                  trailing: Icon(
                    Icons.add_circle_outline,
                    color: brandColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 18.0, bottom: 18),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Board member (1)",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ListTile(
                leading: CircleAvatar(),
                title: Text("Jane Doe"),
                subtitle: Text("@janedoe"),
                trailing: Text("Admin"),
              ),
              Padding(
                padding: EdgeInsets.only(top: 28.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xffADD8E6),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xff89CFF0),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xff0000FF),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Work together on a board",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Text(
                "Use the search bar or invite link to share this board with others",
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
