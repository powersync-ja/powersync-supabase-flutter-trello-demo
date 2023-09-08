import 'package:powersync/sqlite3.dart' as sqlite;

class Attachment {
  Attachment({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.attachment,
  });

  final String id;

  final String userId;

  final String cardId;

  final String attachment;

  factory Attachment.fromRow(sqlite.Row row) {
    return Attachment(
        id: row['id'],
        userId: row['userId'],
        cardId: row['cardId'],
        attachment: row['attachment']);}
}
