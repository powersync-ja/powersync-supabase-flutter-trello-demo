import 'package:powersync/sqlite3.dart' as sqlite;

class Cardlist {
  Cardlist({
    required this.id,
    required this.listId,
    required this.userId,
    required this.name,
    this.description,
    this.startDate,
    this.dueDate,
    this.attachment,
    this.archived,
    this.checklist,
    this.comments,
  });

  final String id;

  final String listId;

  final String userId;

  final String name;

  String? description;

  final DateTime? startDate;

  final DateTime? dueDate;

  final bool? attachment;

  final bool? archived;

  final bool? checklist;

  final bool? comments;

  factory Cardlist.fromRow(sqlite.Row row) {
    return Cardlist(
        id: row['id'],
        listId: row['listId'],
        userId: row['userId'],
        name: row['name'],
        description: row['description'],
        startDate: DateTime.parse(row['startDate']),
        dueDate: DateTime.parse(row['dueDate']),
        attachment: row['attachment'] == 1,
        archived: row['archived'] == 1,
        checklist: row['checklist'] == 1,
        comments: row['comments'] == 1);
  }
}
