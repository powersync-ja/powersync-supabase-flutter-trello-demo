import 'package:flutter/material.dart';
import 'package:trelloappclone_powersync_client/trelloappclone_powersync_client.dart';

import 'config.dart';

class TrelloProvider extends ChangeNotifier {
  late TrelloUser _user;
  TrelloUser get user => _user;

  List<Workspace> _workspaces = [];
  List<Workspace> get workspaces => _workspaces;

  List<Board> _boards = [];
  List<Board> get boards => _boards;

  String _selectedBackground = backgrounds[0];
  String get selectedBackground => _selectedBackground;

  List<Listboard> _lstbrd = [];
  List<Listboard> get lstbrd => _lstbrd;

  late Board _brd;
  Board get brd => _brd;

  void setUser(TrelloUser user) {
    _user = user;
    notifyListeners();
  }

  void setWorkspaces(List<Workspace> wkspcs) {
    _workspaces = wkspcs;
    notifyListeners();
  }

  void setBoards(List<Board> brd) {
    _boards = brd;
    notifyListeners();
  }

  void setSelectedBg(String slctbg) {
    _selectedBackground = slctbg;
    notifyListeners();
  }

  void setListBoard(List<Listboard> lstbrd) {
    _lstbrd = lstbrd;
    notifyListeners();
  }

  void setSelectedBoard(Board brd) {
    _brd = brd;
    notifyListeners();
  }
}
