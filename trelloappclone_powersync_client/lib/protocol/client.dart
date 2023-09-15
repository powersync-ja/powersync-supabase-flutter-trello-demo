library powersync_client;

import 'package:powersync/powersync.dart';

import "../models/models.dart";
import 'powersync.dart';

export "../models/models.dart";

class _Repository {
  Client client;

  _Repository(this.client);

  int boolAsInt(bool? value) {
    if (value == null) {
      return 0;
    }
    return value ? 1 : 0;
  }
}

class _ActivityRepository extends _Repository {
  _ActivityRepository(Client client) : super(client);

  Future<bool> createActivity(Activity activity) async {
    final results = await client.getDBExecutor().execute('''INSERT INTO
           activity(id, workspaceId, boardId, userId, cardId, description, dateCreated)
           VALUES(?, ?, ?, ?, ?, ?, datetime())
           RETURNING *''', [
      activity.id,
      activity.workspaceId,
      activity.boardId,
      activity.userId,
      activity.cardId,
      activity.description
    ]);
    return results.isNotEmpty;
  }

  Future<List<Activity>> getActivities(Cardlist cardlist) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM activity WHERE cardId = ? ORDER BY dateCreated DESC
           ''', [cardlist.id]);
    return results.map((row) => Activity.fromRow(row)).toList();
  }
}

class _AttachmentRepository extends _Repository {
  _AttachmentRepository(Client client) : super(client);

  Future<Attachment> addAttachment(Attachment attachment) async {
    final results = await client.getDBExecutor().execute('''INSERT INTO
           attachment(id, workspaceId, userId, cardId, attachment)
           VALUES(?, ?, ?, ?, ?)
           RETURNING *''', [
      attachment.id,
      attachment.workspaceId,
      attachment.userId,
      attachment.cardId,
      attachment.attachment
    ]);
    if (results.isEmpty) {
      throw Exception("Failed to add attachment");
    } else {
      return Attachment.fromRow(results.first);
    }
  }

  //TODO: need to replace with file upload service calls to Supabase
  Future<String?> getUploadDescription(String path) =>
      Future.value('TODO: implement getUploadDescription');

  Future<bool> verifyUpload(String path) => Future.value(false);
}

class _BoardRepository extends _Repository {
  _BoardRepository(Client client) : super(client);

  String get insertQuery => '''
  INSERT INTO
           board(id, userId, workspaceId, name, description, visibility, background, starred, enableCover, watch, availableOffline, label, emailAddress, commenting, memberType, pinned, selfJoin, close)
           VALUES(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18)
  ''';

  String get updateQuery => '''
  UPDATE board
          set userId = ?1, workspaceId = ?2, name = ?3, description = ?4, visibility = ?5, background = ?6, starred = ?7, enableCover = ?8, watch = ?9, availableOffline = ?10, label = ?11, emailAddress = ?12, commenting = ?13, memberType = ?14, pinned = ?15, selfJoin = ?16, close = ?17
          WHERE id = ?18
  ''';

  Future<Board> createBoard(Board board) async {
    final results = await client.getDBExecutor().execute('''
          $insertQuery RETURNING *''', [
      board.id,
      board.userId,
      board.workspaceId,
      board.name,
      board.description,
      board.visibility,
      board.background,
      boolAsInt(board.starred),
      boolAsInt(board.enableCover),
      boolAsInt(board.watch),
      boolAsInt(board.availableOffline),
      board.label,
      board.emailAddress,
      board.commenting,
      board.memberType,
      boolAsInt(board.pinned),
      boolAsInt(board.selfJoin),
      boolAsInt(board.close)
    ]);
    if (results.isEmpty) {
      throw Exception("Failed to add Board");
    } else {
      return Board.fromRow(results.first);
    }
  }

  Future<bool> updateBoard(Board board) async {
    await client.getDBExecutor().execute(updateQuery, [
      board.userId,
      board.workspaceId,
      board.name,
      board.description,
      board.visibility,
      board.background,
      boolAsInt(board.starred),
      boolAsInt(board.enableCover),
      boolAsInt(board.watch),
      boolAsInt(board.availableOffline),
      board.label,
      board.emailAddress,
      board.commenting,
      board.memberType,
      boolAsInt(board.pinned),
      boolAsInt(board.selfJoin),
      boolAsInt(board.close),
      board.id
    ]);
    return true;
  }

  Future<bool> deleteBoard(Board board) async {
    await client
        .getDBExecutor()
        .execute('DELETE FROM board WHERE id = ?', [board.id]);
    return true;
  }

  Future<Workspace?> getWorkspaceForBoard(Board board) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM workspace WHERE id = ?
           ''', [board.workspaceId]);
    return results.map((row) => Workspace.fromRow(row)).firstOrNull;
  }

  Future<List<Board>> getAllBoards() async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM board
           ''');
    return results.map((row) => Board.fromRow(row)).toList();
  }
}

class _CardlistRepository extends _Repository {
  _CardlistRepository(Client client) : super(client);

  String get insertQuery => '''
  INSERT INTO
           card(id, workspaceId, listId, userId, name, description, startDate, dueDate, attachment, archived, checklist, comments)
           VALUES(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12)
  ''';

  Future<Cardlist> createCard(Cardlist cardlist) async {
    final results =
        await client.getDBExecutor().execute('$insertQuery RETURNING *', [
      cardlist.id,
      cardlist.workspaceId,
      cardlist.listId,
      cardlist.userId,
      cardlist.name,
      cardlist.description,
      cardlist.startDate,
      cardlist.dueDate,
      boolAsInt(cardlist.attachment),
      boolAsInt(cardlist.archived),
      boolAsInt(cardlist.checklist),
      boolAsInt(cardlist.comments)
    ]);
    if (results.isEmpty) {
      throw Exception("Failed to add Cardlist");
    } else {
      return Cardlist.fromRow(results.first);
    }
  }

  String get updateQuery => '''
  UPDATE card
          set listId = ?1, userId = ?2, name = ?3, description = ?4, startDate = ?5, dueDate = ?6, attachment = ?7, archived = ?8, checklist = ?9, comments = ?10
          WHERE id = ?11
  ''';

  Future<bool> updateCard(Cardlist cardlist) async {
    await client.getDBExecutor().execute(updateQuery, [
      cardlist.listId,
      cardlist.userId,
      cardlist.name,
      cardlist.description,
      cardlist.startDate,
      cardlist.dueDate,
      boolAsInt(cardlist.attachment),
      boolAsInt(cardlist.archived),
      boolAsInt(cardlist.checklist),
      boolAsInt(cardlist.comments),
      cardlist.id
    ]);
    return true;
  }

  Future<List<Cardlist>> getCardsforList(String listId) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM card WHERE listId = ?
           ''', [listId]);
    return results.map((row) => Cardlist.fromRow(row)).toList();
  }
}

class _CheckListRepository extends _Repository {
  _CheckListRepository(Client client) : super(client);

  String get insertQuery => '''
  INSERT INTO
           checklist(id, workspaceId, cardId, name, status)
           VALUES(?1, ?2, ?3, ?4, ?5)
  ''';

  Future<Checklist> createChecklist(Checklist checklist) async {
    final results = await client.getDBExecutor().execute(
        '$insertQuery RETURNING *', [
      checklist.id,
      checklist.workspaceId,
      checklist.cardId,
      checklist.name,
      boolAsInt(checklist.status)
    ]);
    if (results.isEmpty) {
      throw Exception("Failed to add Checklist");
    } else {
      return Checklist.fromRow(results.first);
    }
  }

  String get updateQuery => '''
  UPDATE checklist
          set cardId = ?1, name = ?2, status = ?3
          WHERE id = ?4
  ''';

  Future<bool> updateChecklist(Checklist checklist) async {
    await client.getDBExecutor().execute(updateQuery, [
      checklist.cardId,
      checklist.name,
      boolAsInt(checklist.status),
      checklist.id
    ]);
    return true;
  }

  Future<bool> deleteChecklistItem(Checklist checklist) async {
    await client
        .getDBExecutor()
        .execute('DELETE FROM checklist WHERE id = ?', [checklist.id]);
    return true;
  }

  Future<List<Checklist>> getChecklists(Cardlist crd) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM checklist WHERE cardId = ?
           ''', [crd.id]);
    return results.map((row) => Checklist.fromRow(row)).toList();
  }

  Future<int> deleteChecklist(Cardlist crd) async {
    final results = await client.getDBExecutor().execute('''
          SELECT COUNT(*) FROM checklist WHERE cardId = ?
           ''', [crd.id]);
    await client
        .getDBExecutor()
        .execute('DELETE FROM checklist WHERE cardId = ?', [crd.id]);
    return results.first['count'];
  }
}

class _CommentRepository extends _Repository {
  _CommentRepository(Client client) : super(client);

  String get insertQuery => '''
  INSERT INTO
           comment(id, workspaceId, cardId, userId, description)
           VALUES(?1, ?2, ?3, ?4, ?5)
  ''';

  Future<Comment> createComment(Comment comment) async {
    final results = await client.getDBExecutor().execute(
        '$insertQuery RETURNING *',
        [comment.id, comment.workspaceId, comment.cardId, comment.userId, comment.description]);
    if (results.isEmpty) {
      throw Exception("Failed to add Comment");
    } else {
      return Comment.fromRow(results.first);
    }
  }

  String get updateQuery => '''
  UPDATE comment
          set cardId = ?1, userId = ?2, description = ?3
          WHERE id = ?4
  ''';

  Future<bool> updateComment(Comment comment) async {
    await client.getDBExecutor().execute(updateQuery,
        [comment.cardId, comment.userId, comment.description, comment.id]);
    return true;
  }
}

class _ListboardRepository extends _Repository {
  _ListboardRepository(Client client) : super(client);

  Future<List<Listboard>> getListsByBoard({required String boardId}) async {
    //first we get the listboards
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM listboard WHERE boardId = ?
           ''', [boardId]);
    List<Listboard> lists =
        results.map((row) => Listboard.fromRow(row)).toList();

    //then we set the cards for each listboard
    for (Listboard list in lists) {
      List<Cardlist> cards = await client.card.getCardsforList(list.id);
      list.cards = cards;
    }

    return lists;
  }

  String get insertQuery => '''
  INSERT INTO
           listboard(id, workspaceId, boardId, userId, name, archived)
           VALUES(?1, ?2, ?3, ?4, ?5, ?6)
  ''';

  Future<Listboard> createList(Listboard lst) async {
    final results = await client.getDBExecutor().execute(
        '$insertQuery RETURNING *',
        [lst.id, lst.workspaceId, lst.boardId, lst.userId, lst.name, boolAsInt(lst.archived)]);
    if (results.isEmpty) {
      throw Exception("Failed to add Listboard");
    } else {
      return Listboard.fromRow(results.first);
    }
  }
}

class _MemberRepository extends _Repository {
  _MemberRepository(Client client) : super(client);

  String get insertQuery => '''
  INSERT INTO
           member(id, workspaceId, userId, name, role)
           VALUES(?1, ?2, ?3, ?4, ?5)
  ''';

  Future<Member> addMember(Member member) async {
    final results = await client.getDBExecutor().execute(
        '$insertQuery RETURNING *', [
      member.id,
      member.workspaceId,
      member.userId,
      member.name,
      member.role
    ]);
    if (results.isEmpty) {
      throw Exception("Failed to add Member");
    } else {
      return Member.fromRow(results.first);
    }
  }

  Future<List<Member>> getMembersByWorkspace(
      {required String workspaceId}) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM member WHERE workspaceId = ?
           ''', [workspaceId]);
    return results.map((row) => Member.fromRow(row)).toList();
  }

  Future<List<TrelloUser>> getInformationOfMembers(List<Member> members) async {
    List<TrelloUser> users = [];
    for (Member member in members) {
      TrelloUser? user = await client.user.getUserById(userId: member.userId);
      if (user != null) {
        users.add(user);
      }
    }
    return users;
  }

  Future<Workspace> deleteMember(Member member, Workspace workspace) async {
    //delete member
    await client.getDBExecutor().execute(
        'DELETE FROM member WHERE workspaceId = ? AND id = ?',
        [workspace.id, member.id]);

    //update workspace list with new members
    List<Member> newMembersList =
        await getMembersByWorkspace(workspaceId: workspace.id);
    workspace.members = newMembersList;
    return workspace;
  }
}

class _UserRepository extends _Repository {
  _UserRepository(Client client) : super(client);

  String get insertQuery => '''
  INSERT INTO
           trellouser(id, name, email, password)
           VALUES(?1, ?2, ?3, ?4)
  ''';

  Future<TrelloUser> createUser(TrelloUser user) async {
    final results = await client.getDBExecutor().execute(
        '$insertQuery RETURNING *',
        [user.id, user.name, user.email, user.password]);
    if (results.isEmpty) {
      throw Exception("Failed to add User");
    } else {
      return TrelloUser.fromRow(results.first);
    }
  }

  Future<TrelloUser?> getUserById({required String userId}) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM trellouser WHERE id = ?
           ''', [userId]);
    return results.map((row) => TrelloUser.fromRow(row)).firstOrNull;
  }

  Future<TrelloUser?> checkUserExists(String email) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM trellouser WHERE email = ? 
           ''', [email]);
    return results.map((row) => TrelloUser.fromRow(row)).firstOrNull;
  }
}

class _WorkspaceRepository extends _Repository {
  _WorkspaceRepository(Client client) : super(client);

  String get insertQuery => '''
  INSERT INTO
           workspace(id, userId, name, description, visibility)
           VALUES(?1, ?2, ?3, ?4, ?5)
  ''';

  Future<Workspace> createWorkspace(Workspace workspace) async {
    final results =
        await client.getDBExecutor().execute('$insertQuery RETURNING *', [
      workspace.id,
      workspace.userId,
      workspace.name,
      workspace.description,
      workspace.visibility
    ]);
    return Workspace.fromRow(results.first);
  }

  Future<List<Workspace>> getWorkspacesByUser({required String userId}) async {
    //First we get the workspaces
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM workspace WHERE userId = ?
           ''', [userId]);
    List<Workspace> workspaces =
        results.map((row) => Workspace.fromRow(row)).toList();

    //Then we get the members for each workspace
    for (Workspace workspace in workspaces) {
      List<Member> members =
          await client.member.getMembersByWorkspace(workspaceId: workspace.id);
      workspace.members = members;
    }

    return workspaces;
  }

  Stream<List<Workspace>> watchWorkspacesByUser({required String userId}) {
    //First we get the workspaces
    return client.getDBExecutor().watch('''
          SELECT * FROM workspace WHERE userId = ?
           ''', parameters: [userId]).map((event){
      List<Workspace> workspaces = event.map((row) => Workspace.fromRow(row)).toList();
      //Then we get the members for each workspace
      for (Workspace workspace in workspaces) {
        client.member.getMembersByWorkspace(workspaceId: workspace.id).then((members) => workspace.members = members);
      }
      return workspaces;
    });
  }

  Future<Workspace?> getWorkspaceById({required String workspaceId}) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM workspace WHERE id = ?
           ''', [workspaceId]);
    Workspace workspace = Workspace.fromRow(results.first);
    List<Member> members =
        await client.member.getMembersByWorkspace(workspaceId: workspaceId);
    workspace.members = members;
    return workspace;
  }

  Future<List<Board>> getBoardsByWorkspace(
      {required String workspaceId}) async {
    final results = await client.getDBExecutor().execute('''
          SELECT * FROM board WHERE workspaceId = ?
           ''', [workspaceId]);
    return results.map((row) => Board.fromRow(row)).toList();
  }

  Stream<List<Board>> watchBoardsByWorkspace(
      {required String workspaceId}) {
    return client.getDBExecutor().watch('''
          SELECT * FROM board WHERE workspaceId = ?
           ''', parameters: [workspaceId]).map((event) {
      return event.map((row) => Board.fromRow(row)).toList();
    });
  }

  Future<bool> updateWorkspace(Workspace workspace) async {
    await client.getDBExecutor().execute('''
          UPDATE workspace
          set userId = ?1, name = ?2, description = ?3, visibility = ?4
          WHERE id = ?5
           ''', [
      workspace.userId,
      workspace.name,
      workspace.description,
      workspace.visibility,
      workspace.id
    ]);
    return true;
  }

  Future<bool> deleteWorkspace(Workspace workspace) async {
    await client
        .getDBExecutor()
        .execute('DELETE FROM workspace WHERE id = ?', [workspace.id]);
    return true;
  }
}

class Client {
  late final _ActivityRepository activity;
  late final _AttachmentRepository attachment;
  late final _BoardRepository board;
  late final _CardlistRepository card;
  late final _CheckListRepository checklist;
  late final _CommentRepository comment;
  late final _ListboardRepository listboard;
  late final _MemberRepository member;
  late final _UserRepository user;
  late final _WorkspaceRepository workspace;

  late PowerSyncClient _powerSyncClient;

  //TODO: refine appconfig handling
  Client() {
    activity = _ActivityRepository(this);
    attachment = _AttachmentRepository(this);
    board = _BoardRepository(this);
    card = _CardlistRepository(this);
    checklist = _CheckListRepository(this);
    comment = _CommentRepository(this);
    listboard = _ListboardRepository(this);
    member = _MemberRepository(this);
    user = _UserRepository(this);
    workspace = _WorkspaceRepository(this);
  }

  Future<void> initialize() async {
    _powerSyncClient = PowerSyncClient();
    await _powerSyncClient.initialize();
  }

  PowerSyncDatabase getDBExecutor() {
    return _powerSyncClient.getDBExecutor();
  }

  String? getUserId() {
    return _powerSyncClient.getUserId();
  }
  
  Future<void> logOut() async {
    await _powerSyncClient.logout();
  }

  Future<TrelloUser> loginWithEmail(String email, String password) async {
    String userId = await _powerSyncClient.loginWithEmail(email, password);

    TrelloUser? storedUser = await user.getUserById(userId: userId);
    if (storedUser == null) {
      storedUser = await user.createUser(TrelloUser(id: userId, name: email.split('@')[0],email: email, password: password));
    }
    return storedUser;
  }

  Future<TrelloUser> signupWithEmail(String name, String email, String password) async {
    TrelloUser? storedUser = await user.checkUserExists(email);
    if (storedUser != null){
      throw new Exception('User for email already exists. Use Login instead.');
    }
    return _powerSyncClient.signupWithEmail(name, email, password);
  }
}
