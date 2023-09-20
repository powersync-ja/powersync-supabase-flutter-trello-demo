import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';
import 'package:boardview/boardview.dart';
import 'package:boardview/boardview_controller.dart';
import 'package:flutter/material.dart';
import 'package:trelloappclone_flutter/features/carddetails/domain/card_detail_arguments.dart';
import 'package:trelloappclone_flutter/features/carddetails/presentation/index.dart';
import 'package:trelloappclone_flutter/utils/color.dart';
import 'package:trelloappclone_powersync_client/trelloappclone_powersync_client.dart';

import '../../../main.dart';
import '../../../utils/config.dart';
import '../../../utils/service.dart';
import '../domain/board_arguments.dart';
import 'boarditemobject.dart';
import 'boardlistobject.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();

  static const routeName = '/board';
}

class _BoardScreenState extends State<BoardScreen> with Service {
  BoardViewController boardViewController = BoardViewController();
  bool showCard = false;
  bool show = false;
  List<BoardList> lists = [];
  final TextEditingController nameController = TextEditingController();
  Map<int, TextEditingController> textEditingControllers = {};
  Map<int, bool> showtheCard = {};
  int selectedList = 0;
  int selectedCard = 0;
  late double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * 0.7;
    final args = ModalRoute.of(context)!.settings.arguments as BoardArguments;
    trello.setSelectedBoard(args.board);
    trello.setSelectedWorkspace(args.workspace);

    return WillPopScope(
        onWillPop: () async {
          Navigator.pushNamed(context, "/home");
          return false;
        },
        child: Scaffold(
          appBar: (!show && !showCard)
              ? AppBar(
                  backgroundColor: brandColor,
                  centerTitle: false,
                  title: Text(args.board.name),
                  actions: [
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.filter_list)),
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/notifications");
                        },
                        icon: const Icon(Icons.notifications_none)),
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/boardmenu');
                        },
                        icon: const Icon(Icons.more_horiz))
                  ],
                )
              : AppBar(
                  leading: IconButton(
                      onPressed: () {
                        setState(() {
                          (show) ? show = false : showCard = false;
                        });
                      },
                      icon: const Icon(Icons.close)),
                  title: Text((show) ? "Add list" : "Add card"),
                  centerTitle: false,
                  actions: [
                    IconButton(
                        onPressed: () {
                          if (show) {
                            addList(Listboard(
                                id: randomUuid(),
                                workspaceId: args.workspace.id,
                                boardId: args.board.id,
                                userId: trello.user.id,
                                name: nameController.text));
                            nameController.clear();
                            setState(() {
                              show = false;
                            });
                          } else {
                            addCard(Cardlist(
                                id: randomUuid(),
                                workspaceId: args.workspace.id,
                                listId: trello.lstbrd[selectedList].id,
                                userId: trello.user.id,
                                name: textEditingControllers[selectedList]!
                                    .text));
                            setState(() {
                              showCard = false;
                              showtheCard[selectedCard] = false;
                            });
                          }
                        },
                        icon: const Icon(Icons.check))
                  ],
                ),
          body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder(
                  stream: getListsByBoardStream(args.board),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Listboard>> snapshot) {

                    if (snapshot.hasData) {
                      List<Listboard> listBoards =
                          snapshot.data as List<Listboard>;
                      return BoardView(
                        lists: loadBoardView(listBoards),
                        boardViewController: boardViewController,
                      );
                    }
                    return const SizedBox.shrink();
                  })),
        ));
  }

  Widget buildBoardItem(
      BoardItemObject itemObject, List<BoardListObject> data) {
    return BoardItem(
        onStartDragItem: (listIndex, itemIndex, state) {},
        onDropItem: (listIndex, itemIndex, oldListIndex, oldItemIndex, state) {
          var item = data[oldListIndex!].items![oldItemIndex!];
          data[oldListIndex].items!.removeAt(oldItemIndex);
          data[listIndex!].items!.insert(itemIndex!, item);

          updateCard(Cardlist(
              id: trello.lstbrd[oldListIndex].cards![oldItemIndex].id,
              workspaceId: trello.selectedWorkspace.id,
              listId: trello.lstbrd[listIndex].id,
              userId: trello.user.id,
              name: item.title!));
        },
        onTapItem: (listIndex, itemIndex, state) {
          Navigator.pushNamed(context, CardDetails.routeName,
              arguments: CardDetailArguments(
                  trello.lstbrd[selectedList].cards![itemIndex!],
                  trello.selectedBoard,
                  trello.lstbrd[selectedList]));
        },
        item: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(itemObject.title!),
          ),
        ));
  }

  Widget _createBoardList(
      BoardListObject list, List<BoardListObject> data, int index) {
    List<BoardItem> items = [];
    for (int i = 0; i < list.items!.length; i++) {
      items.insert(i, buildBoardItem(list.items![i], data) as BoardItem);
    }

    textEditingControllers.putIfAbsent(index, () => TextEditingController());
    showtheCard.putIfAbsent(index, () => false);

    items.insert(
        list.items!.length,
        BoardItem(
          onTapItem: (listIndex, itemIndex, state) {
            setState(() {
              selectedList = listIndex!;
              selectedCard = index;
              showCard = true;
              showtheCard[index] = true;
            });
          },
          item: (!showtheCard[index]!)
              ? ListTile(
                  leading: const Text.rich(TextSpan(
                    children: <InlineSpan>[
                      WidgetSpan(
                          child: Icon(
                        Icons.add,
                        size: 19,
                        color: whiteShade,
                      )),
                      WidgetSpan(
                        child: SizedBox(
                          width: 5,
                        ),
                      ),
                      TextSpan(
                          text: "Add card",
                          style: TextStyle(color: whiteShade)),
                    ],
                  )),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.image,
                      color: whiteShade,
                    ),
                    onPressed: () {},
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: textEditingControllers[index],
                    decoration: const InputDecoration(hintText: "Card name"),
                  ),
                ),
        ));

    return BoardList(
      onStartDragList: (listIndex) {},
      onTapList: (listIndex) async {},
      onDropList: (listIndex, oldListIndex) {
        var list = data[oldListIndex!];
        data.removeAt(oldListIndex);
        data.insert(listIndex!, list);
      },
      headerBackgroundColor: brandColor,
      backgroundColor: brandColor,
      header: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: ListTile(
                  leading: SizedBox(
                    width: 180,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                      list.title!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                      child: const Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              child: ListTile(
                                title: Text(listMenu[1]),
                              ),
                            ),
                            PopupMenuItem<String>(
                              child: ListTile(
                                title: Text(listMenu[2]),
                              ),
                            ),
                            PopupMenuItem<String>(
                              child: ListTile(
                                title: Text(listMenu[3]),
                              ),
                            ),
                            const PopupMenuItem<String>(
                                child: Divider(
                              height: 1,
                              thickness: 1,
                            )),
                            PopupMenuItem<String>(
                              child: ListTile(
                                title: Text(listMenu[4]),
                                trailing:
                                    const Icon(Icons.keyboard_arrow_right),
                              ),
                            ),
                            const PopupMenuItem<String>(
                                child: Divider(
                              height: 1,
                              thickness: 1,
                            )),
                            PopupMenuItem<String>(
                              child: ListTile(
                                title: Text(listMenu[5]),
                              ),
                            ),
                            PopupMenuItem<String>(
                              child: ListTile(
                                title: Text(listMenu[6]),
                              ),
                            ),
                            PopupMenuItem<String>(
                              child: ListTile(
                                title: Text(listMenu[7]),
                              ),
                            ),
                          ]),
                ))),
      ],
      items: items,
    );
  }

  List<BoardListObject> generateBoardListObject(
      List<Listboard> lists) {
    final List<BoardListObject> listData = [];

    for (int i = 0; i < lists.length; i++) {
      listData.add(BoardListObject(
          title: lists[i].name,
          items: generateBoardItemObject(lists[i].cards!)));
    }

    return listData;
  }

  List<BoardItemObject> generateBoardItemObject(List<Cardlist> crds) {
    final List<BoardItemObject> items = [];
    for (int i = 0; i < crds.length; i++) {
      items.add(BoardItemObject(title: crds[i].name));
    }
    return items;
  }

  List<BoardList> loadBoardView(List<Listboard> Listboards) {
    List<BoardListObject> data = generateBoardListObject(Listboards);
    lists = [];

    for (int i = 0; i < data.length; i++) {
      lists.add(_createBoardList(data[i], data, i) as BoardList);
    }

    lists.insert(
        data.length,
        BoardList(
          items: [
            BoardItem(
                item: GestureDetector(
              onTap: () {
                setState(() {
                  show = true;
                });
              },
              child: Container(
                  alignment: Alignment.center,
                  width: width,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: brandColor,
                  ),
                  child: (!show)
                      ? const Text(
                          "Add list",
                          style: TextStyle(color: whiteShade),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(hintText: "List name"),
                          ),
                        )),
            ))
          ],
        ));
    return lists;
  }
}
