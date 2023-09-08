import 'package:flutter/material.dart';
import 'package:trelloappclone_flutter/utils/color.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
        centerTitle: false,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/invitemember');
              },
              child: const Text(
                "INVITE",
                style: TextStyle(color: whiteShade),
              ))
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Members (1)"),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: brandColor,
                    child: Text("J"),
                  ),
                  title: const Text("Jane Doe"),
                  subtitle: const Text("@janedoe"),
                  trailing: const Text(
                    "Admin",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: brandColor,
                                        child: Text("J"),
                                      ),
                                      title: Text("Jane Doe"),
                                      subtitle: Text("@janedoe"),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text("Admin"),
                                    ),
                                    const Text(
                                        "Can view, create and edit Workspace boards, and change settings for the workspace"),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        height: 50,
                                        child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: dangerColor),
                                            child:
                                                const Text("Leave workspace")),
                                      ),
                                    )
                                  ]),
                            ),
                          );
                        });
                  },
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
