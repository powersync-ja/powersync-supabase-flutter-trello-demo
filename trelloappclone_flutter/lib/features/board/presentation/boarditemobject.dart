

import 'package:trelloappclone_powersync_client/trelloappclone_powersync_client.dart';

class BoardItemObject {
  String? title;
  bool? hasDescription;
  List<CardLabel>? cardLabels;

  BoardItemObject({this.title, this.hasDescription, this.cardLabels}) {
    title ??= "";
    hasDescription ??= false;
    cardLabels ??= [];
  }
}
