import 'package:powersync/powersync.dart';

const schema = Schema(([
  //class: Activity
  // table: activity
  // fields:
  //   boardId: int?, parent=board
  //   userId: int, parent=trellouser
  //   cardId: int?, parent=card
  //   description: String
  //   dateCreated: DateTime
  Table('activity', [
    Column.text('boardId'),
    Column.text('userId'),
    Column.text('cardId'),
    Column.text('description'),
    Column.text('dateCreated'),
  ], indexes: [
    Index('board', [IndexedColumn('boardId')]),
    Index('user', [IndexedColumn('userId')]),
    Index('card', [IndexedColumn('cardId')])
  ]),
  //class: Attachment
  // table: attachment
  // fields:
  //   userId: int, parent=trellouser
  //   cardId: int, parent=card
  //   attachment: String
  Table('attachment', [
    Column.text('userId'),
    Column.text('cardId'),
    Column.text('attachment'),
  ], indexes: [
    Index('user', [IndexedColumn('userId')]),
  ]),
  //class: Board
  // table: board
  // fields:
  //   workspaceId: int, parent=workspace
  //   userId: int, parent=trellouser
  //   name: String
  //   description: String?
  //   visibility: String
  //   background: String
  //   starred: bool?
  //   enableCover: bool?
  //   watch: bool?
  //   availableOffline: bool?
  //   label: String?
  //   emailAddress: String?
  //   commenting: int?
  //   memberType: int?
  //   pinned: bool?
  //   selfJoin: bool?
  //   close: bool?
  Table('board', [
    Column.text('workspaceId'),
    Column.text('userId'),
    Column.text('name'),
    Column.text('description'),
    Column.text('visibility'),
    Column.text('background'),
    Column.integer('starred'),
    Column.integer('enableCover'),
    Column.integer('watch'),
    Column.integer('availableOffline'),
    Column.text('label'),
    Column.text('emailAddress'),
    Column.integer('commenting'),
    Column.integer('memberType'),
    Column.integer('pinned'),
    Column.integer('selfJoin'),
    Column.integer('close'),
  ], indexes: [
    Index('workspace', [IndexedColumn('workspaceId')]),
    Index('user', [IndexedColumn('userId')]),
  ]),
  //class: Cardlist
  // table: card
  // fields:
  //   listId: int, parent=listboard
  //   userId: int, parent=trellouser
  //   name: String
  //   description: String?
  //   startDate: DateTime?
  //   dueDate: DateTime?
  //   attachment: bool?
  //   archived: bool?
  //   checklist: bool?
  //   comments: bool?
  Table('card', [
    Column.text('listId'),
    Column.text('userId'),
    Column.text('name'),
    Column.text('description'),
    Column.text('startDate'),
    Column.text('dueDate'),
    Column.integer('attachment'),
    Column.integer('archived'),
    Column.integer('checklist'),
    Column.integer('comments'),
  ], indexes: [
    Index('list', [IndexedColumn('listId')]),
    Index('user', [IndexedColumn('userId')]),
  ]),
  //class: Checklist
  // table: checklist
  // fields:
  //   cardId: int, parent=card
  //   name: String
  //   status: bool
  Table('checklist', [
    Column.text('cardId'),
    Column.text('name'),
    Column.integer('status'),
  ], indexes: [
    Index('card', [IndexedColumn('cardId')]),
  ]),
  //class: Comment
  // table: comment
  // fields:
  //   cardId: int, parent=card
  //   userId: int, parent=trellouser
  //   description: String
  Table('comment', [
    Column.text('cardId'),
    Column.text('userId'),
    Column.text('description'),
  ], indexes: [
    Index('card', [IndexedColumn('cardId')]),
    Index('user', [IndexedColumn('userId')]),
  ]),
  //class: Listboard
  // table: listboard
  // fields:
  //   boardId: int, parent=board
  //   userId: int, parent=trellouser
  //   name: String
  //   archived: bool?
  //   cards: List<Cardlist>?, api
  Table('listboard', [
    Column.text('boardId'),
    Column.text('userId'),
    Column.text('name'),
    Column.integer('archived'),
  ], indexes: [
    Index('board', [IndexedColumn('boardId')]),
    Index('user', [IndexedColumn('userId')]),
  ]),
  //class: Member
  // table: member
  // fields:
  //   workspaceId: int, parent=workspace
  //   userId: int, parent=trellouser
  //   name: String
  //   role: String
  Table('member', [
    Column.text('workspaceId'),
    Column.text('userId'),
    Column.text('name'),
    Column.text('role'),
  ], indexes: [
    Index('workspace', [IndexedColumn('workspaceId')]),
    Index('user', [IndexedColumn('userId')]),
  ]),
  //class: User
  // table: trellouser
  // fields:
  //   name: String?
  //   email: String
  //   password: String
  Table('trellouser', [
    Column.text('name'),
    Column.text('email'),
    Column.text('password'),
  ], indexes: [
    Index('email', [IndexedColumn('email')]),
  ]),
  //class: Workspace
  // table: workspace
  // fields:
  //   userId: int, parent=trellouser
  //   name: String
  //   description: String
  //   visibility: String
  //   members: List<Member>?, api
  Table('workspace', [
    Column.text('userId'),
    Column.text('name'),
    Column.text('description'),
    Column.text('visibility'),
  ], indexes: [
    Index('user', [IndexedColumn('userId')]),
  ])
]));
