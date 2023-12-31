import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:status_alert/status_alert.dart';
import 'package:trelloappclone_flutter/features/home/presentation/custom_search.dart';
import 'package:trelloappclone_flutter/utils/color.dart';
import 'package:trelloappclone_powersync_client/trelloappclone_powersync_client.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';

var uuid = Uuid();

mixin Service {
  randomUuid() {
    return uuid.v4();
  }

  //sign up new user
  signUp(
      {required String name,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      TrelloUser user = await dataClient.signupWithEmail(name, email, password);
      await dataClient.user.createUser(user);

      if (context.mounted) {
        Navigator.pushNamed(context, '/');
        StatusAlert.show(context,
            duration: const Duration(seconds: 3),
            title: 'Account Created',
            subtitle: 'Log in with your new credentials',
            subtitleOptions: StatusAlertTextConfiguration(
                softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
            configuration:
                const IconConfiguration(icon: Icons.check, color: brandColor),
            maxWidth: 260);
      }
    } on Exception catch (e) {
      log('Error with signup: $e', error: e);
      StatusAlert.show(context,
          duration: const Duration(seconds: 5),
          title: 'Sign Up Error',
          subtitle: e.toString(),
          subtitleOptions: StatusAlertTextConfiguration(
              softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
          configuration:
              const IconConfiguration(icon: Icons.check, color: brandColor),
          maxWidth: 260);
    }
  }

  //log in existing user
  logIn(String email, String password, BuildContext context) async {
    try {
      TrelloUser user = await dataClient.loginWithEmail(email, password);
      trello.setUser(user);

      if (context.mounted) {
        Navigator.pushNamed(context, '/home');
        StatusAlert.show(context,
            duration: const Duration(seconds: 5),
            title: 'Syncing Workspaces...',
            configuration:
                const IconConfiguration(icon: Icons.sync, color: brandColor),
            maxWidth: 260);
      }
    } on Exception catch (e) {
      log('Error with login: $e', error: e);
      StatusAlert.show(context,
          duration: const Duration(seconds: 5),
          title: 'Login Error',
          subtitle: e.toString(),
          subtitleOptions: StatusAlertTextConfiguration(
              softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
          configuration:
              const IconConfiguration(icon: Icons.check, color: brandColor),
          maxWidth: 260);
    }
  }

  //log out user
  logOut(BuildContext context) async {
    try {
      await dataClient.logOut();
    } on Exception catch (e) {
      StatusAlert.show(context,
          duration: const Duration(seconds: 5),
          title: 'Logout Error',
          subtitle: e.toString(),
          subtitleOptions: StatusAlertTextConfiguration(
              softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
          configuration:
              const IconConfiguration(icon: Icons.check, color: brandColor),
          maxWidth: 260);
    }
  }

  switchToOfflineMode() async {
    dataClient.switchToOfflineMode();
  }

  switchToOnlineMode() async {
    dataClient.switchToOnlineMode();
  }

  //search for a board
  search(BuildContext context) async {
    List<Board> allboards = await dataClient.board.getAllBoards();

    if (context.mounted) {
      showSearch(context: context, delegate: CustomSearchDelegate(allboards));
    }
  }

  //encrypt password
  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  //create workspace
  createWorkspace(BuildContext context,
      {required String name,
      required String description,
      required String visibility}) async {
    Workspace workspace = Workspace(
        id: randomUuid(),
        userId: trello.user.id,
        name: name,
        description: description,
        visibility: visibility);

    try {
      Workspace addedWorkspace =
          await dataClient.workspace.createWorkspace(workspace);

      Member newMember = Member(
          id: randomUuid(),
          workspaceId: addedWorkspace.id,
          userId: trello.user.id,
          name: trello.user.name ?? trello.user.email,
          role: "Admin");

      await dataClient.member.addMember(newMember);

      if (context.mounted) {
        Navigator.pushNamed(context, "/home");
      }

      return addedWorkspace;
    } on Exception catch (e) {
      StatusAlert.show(context,
          duration: const Duration(seconds: 5),
          title: 'Trello Clone',
          subtitle: e.toString(),
          configuration:
              const IconConfiguration(icon: Icons.check, color: brandColor),
          maxWidth: 260);
    }
  }

  //get workspaces of a specific user using user ID
  Future<List<Workspace>> getWorkspaces() async {
    List<Workspace> workspaces =
        await dataClient.workspace.getWorkspacesByUser(userId: trello.user.id);
    trello.setWorkspaces(workspaces);
    return workspaces;
  }

  //get a stream of workspaces for user, so we can react on distributed changes to it
  Stream<List<Workspace>> getWorkspacesStream() {
    return dataClient.workspace
        .watchWorkspacesByUser(userId: trello.user.id)
        .map((workspaces) {
      trello.setWorkspaces(workspaces);
      return workspaces;
    });
  }

  //create board
  createBoard(BuildContext context, Board brd) async {
    try {
      
      var labelColors = [<String, String>{}];
      labelColors = [
        {"color": "fd6267", "name": "Bug"},
        {"color": "67ddf3", "name": "Feature"},
        {"color": "a282ff", "name": "Enhancement"},
        {"color": "f7b94a", "name": "Documentation"},
        {"color": "f8ff6e", "name": "Marketing"}
      ];

      await dataClient.board.createBoard(brd);
      // Add the default labels to the board
      for (var label in labelColors) {        
        await dataClient.boardLabel.createBoardLabel(BoardLabel(
            id: randomUuid(),
            boardId: brd.id,
            workspaceId: brd.workspaceId,
            title: label["name"] ?? "",
            color: label["color"] ?? "",
            dateCreated: DateTime.now()));
      }

      if (context.mounted) {
        Navigator.pushNamed(context, "/home");
      }
    } on Exception catch (e) {
      StatusAlert.show(context,
          duration: const Duration(seconds: 5),
          title: 'Trello Clone',
          subtitle: e.toString(),
          configuration:
              const IconConfiguration(icon: Icons.check, color: brandColor),
          maxWidth: 260);
    }
  }

  //get boards of a specific workspace by Workspace ID
  Future<List<Board>> getBoards(String workspaceId) async {
    List<Board> boards = await dataClient.workspace
        .getBoardsByWorkspace(workspaceId: workspaceId);
    trello.setBoards(boards);
    return boards;
  }

  //watch boards of a specific workspace by Workspace ID via a stream
  Stream<List<Board>> getBoardsStream(String workspaceId) {
    return dataClient.workspace
        .watchBoardsByWorkspace(workspaceId: workspaceId)
        .map((boards) {
      trello.setBoards(boards);
      return boards;
    });
  }

  //update workspace
  Future<bool> updateWorkspace(Workspace wkspc) async {
    return await dataClient.workspace.updateWorkspace(wkspc);
  }

  //get user by Id
  Future<TrelloUser?> getUserById(String userId) async {
    TrelloUser? user = await dataClient.user.getUserById(userId: userId);
    return user;
  }

  //get information of members
  Future<List<TrelloUser>> getMembersInformation(List<Member> mmbrs) async {
    List<TrelloUser> usrs =
        await dataClient.member.getInformationOfMembers(mmbrs);
    return usrs;
  }

  Future<bool> inviteUserToWorkspace(String email, Workspace workspace) async {
    TrelloUser? user = await dataClient.user.checkUserExists(email);
    if (user != null) {
      Member member = Member(
          id: randomUuid(),
          workspaceId: workspace.id,
          userId: user.id,
          name: user.name ?? user.email,
          role: "Admin");
      await dataClient.member.addMember(member);
      workspace.members?.add(member);
      return true;
    }
    return false;
  }

  //remove Member from Workspace
  Future<Workspace> removeMemberFromWorkspace(
      Member mmbr, Workspace wkspc) async {
    Workspace updatedWorkspace =
        await dataClient.member.deleteMember(mmbr, wkspc);
    return updatedWorkspace;
  }

  //update offline status
  Future<bool> updateOfflineStatus(Board brd) async {
    return await dataClient.board.updateBoard(brd);
  }

  //get lists by board
  Future<List<Listboard>> getListsByBoard(Board brd) async {
    List<Listboard> brdlist =
        await dataClient.listboard.getListsByBoard(boardId: brd.id);
    trello.setListBoard(brdlist);
    return brdlist;
  }

  //watch lists by board via Stream
  Stream<List<Listboard>> getListsByBoardStream(Board brd) {
    return dataClient.listboard.watchListsByBoard(boardId: brd.id).map((lists) {
      trello.setListBoard(lists);
      return lists;
    });
  }

  //add list
  Future<void> addList(Listboard lst) async {
    await dataClient.listboard.createList(lst);
    createActivity(
        workspaceId: lst.workspaceId,
        description: "${trello.user.name} added a new list ${lst.name}");
  }

  //add list
  Future<void> updateListOrder(String listId, int newOrder) async {
    await dataClient.listboard.updateListOrder(listId, newOrder);
  }

  //add card
  Future<void> addCard(Cardlist crd) async {
    Cardlist newcrd = await dataClient.card.createCard(crd);
    createActivity(
        card: newcrd.id,
        workspaceId: newcrd.workspaceId,
        description: "${trello.user.name} added a new card ${crd.name}");
  }

  //update card
  Future<void> updateCard(Cardlist crd) async {
    await dataClient.card.updateCard(crd);

    createActivity(
        card: crd.id,
        workspaceId: crd.workspaceId,
        description: "${trello.user.name} updated the card ${crd.name}");
  }

  //delete card
  Future<void> deleteCard(Cardlist crd) async {
    await dataClient.card.deleteCard(crd);

    createActivity(
        card: crd.id,
        workspaceId: crd.workspaceId,
        description: "${trello.user.name} deleted the card ${crd.name}");
  }

  Future<int> archiveCardsInList(Listboard list) async {
    return dataClient.listboard.archiveCardsInList(list);
  }

  //add card
  Future<CardLabel> addCardLabel(CardLabel crdlbl, BoardLabel brdlbl) async {
    final newCardLabel = await dataClient.cardLabel.createCardLabel(crdlbl);
    createActivity(
        card: crdlbl.cardId,
        workspaceId: brdlbl.workspaceId,
        description: "${trello.user.name} added a new label '${brdlbl.title}'");

    return newCardLabel;
  }

  //add card
  Future<void> deleteCardLabel(cardId, BoardLabel brdlbl) async {
    await dataClient.cardLabel.deleteCardLabel(brdlbl);
    createActivity(
        card: cardId,
        workspaceId: brdlbl.workspaceId,
        description: "${trello.user.name} deleted the label '${brdlbl.title}'");
  }

  //updateBoardLabel
  Future<void> updateBoardLabel(BoardLabel brdlbl) async {
    await dataClient.boardLabel.updateBoardLabel(brdlbl);
  }

  //create activity
  Future<void> createActivity(
      {required String workspaceId,
      String? boardId,
      required String description,
      String? card}) async {
    await dataClient.activity.createActivity(Activity(
        id: randomUuid(),
        workspaceId: workspaceId,
        boardId: boardId,
        userId: trello.user.id,
        cardId: card,
        description: description,
        dateCreated: DateTime.now()));
  }

  //get activities of a specific card
  Future<List<Activity>> getActivities(Cardlist crd) async {
    return dataClient.activity.getActivities(crd);
  }

  //create comment
  Future<void> createComment(Comment cmmt) async {
    await dataClient.comment.createComment(cmmt);
  }

  //create checklist
  Future<void> createChecklist(Checklist chcklst) async {
    await dataClient.checklist.createChecklist(chcklst);
  }

  Future<List<Checklist>> getChecklists(Cardlist crd) async {
    List<Checklist> chcklsts = await dataClient.checklist.getChecklists(crd);
    return chcklsts;
  }

  Future<void> updateChecklist(Checklist chcklst) async {
    await dataClient.checklist.updateChecklist(chcklst);
  }

  Future<void> deleteChecklist(Cardlist crd) async {
    await dataClient.checklist.deleteChecklist(crd);
  }

  Future<void> uploadFile(Cardlist crd) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      addAttachment(result.files[0].path ?? "", crd);
    }
  }

  Future<bool> addAttachment(String path, Cardlist crd) async {
    //TODO: fix uploads
    // var uploadDescription = await client.attachment.getUploadDescription(path);
    bool success = false;
    // if (uploadDescription != null) {
    //   var uploader = FileUploader(uploadDescription);
    //   await uploader.upload(
    //       File(path).readAsBytes().asStream(), File(path).lengthSync());
    //   success = await client.attachment.verifyUpload(path);
    // }
    // if (success) {
    //   insertAttachment(crd, path);
    // }
    return success;
  }

  Future<void> insertAttachment(Cardlist crd, String path) async {
    await dataClient.attachment.addAttachment(Attachment(
        id: randomUuid(),
        workspaceId: crd.workspaceId,
        userId: trello.user.id,
        cardId: crd.id,
        attachment: path));
  }
}
