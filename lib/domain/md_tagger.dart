class MdTagger {
  final String _textOrg;
  final int _selectionStart;
  final int _selectionEnd;
  final MdTag _tag;

  late final int currentLineHeadPosition;
  late final String text;

  MdTagger(this._textOrg, this._tag, this._selectionStart, this._selectionEnd) {
    currentLineHeadPosition = _currentLineHeadPosition();
    text = _addMdTag();
  }

  int _currentLineHeadPosition() {
    if (_textOrg.length < _selectionStart || _selectionStart < 0) {
      throw Exception(
          "Invalid cursorPosition: cursorPosition=$_selectionStart, textLength=${_textOrg.length}");
    }
    // カーソル位置までに現れる最後の改行
    var textToCursorPosition = _textOrg.substring(0, _selectionStart);
    var match = RegExp(r"[\s\S]*\n").firstMatch(textToCursorPosition);
    if (match == null) {
      // 改行がなければ文字列の先頭
      return 0;
    }

    String matchText = match.group(0)!;
    int lineHeadPosition = matchText.length;
    var lines = textToCursorPosition.split("\n");
    String lineText = lines[lines.length - 1];
    int lineCount = lines.length;

    return lineHeadPosition;
  }

  String _addMdTag() {
    int addPosition = currentLineHeadPosition;

    var textToCursorPosition = _textOrg.substring(0, _selectionStart);
    var cursorLineCount = textToCursorPosition.split("\n").length - 1;
    String lineText = _textOrg.split("\n")[cursorLineCount];
    var addTagText = "";
    if (_tag == MdTag.header) {
      // 見出しタグ
      var match = RegExp(r"^\" + _tag.char + "+? ").firstMatch(lineText);
      addTagText = match == null ? _tag.char + " " : _tag.char;
    } else if (RegExp(r"^\" + _tag.char + " ").firstMatch(lineText) != null) {
      // 既に対象のタグがある
      addTagText = "  ";
    } else if (RegExp(r"^ {2,}\" + _tag.char + " ").firstMatch(lineText) !=
        null) {
      // 既に対象のタグがありインデントされている
      addTagText = "  ";
    } else {
      // 対象のタグがない
      addTagText = _tag.char + " ";
    }

    return _textOrg.substring(0, addPosition) +
        addTagText +
        _textOrg.substring(addPosition);
  }
}

enum MdTag {
  header,
  unorderedList,
  // orderedList,
  // link,
}

extension MdTagExt on MdTag {
  String get char {
    String char = "";
    switch (this) {
      case MdTag.header:
        char = "#";
        break;
      case MdTag.unorderedList:
        char = "-";
        break;
    }
    return char;
  }
}
