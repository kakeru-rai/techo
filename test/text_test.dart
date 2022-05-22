import 'package:flutter_hello_world/domain/md_tagger.dart';
import 'package:test/test.dart';

void main() {
  int currentLineHeadPosition(String text, int cursorPosition) {
    var mt = MdTagger(text, MdTag.header, cursorPosition, cursorPosition);
    return mt.currentLineHeadPosition;
  }

  String addMdTag(String text, MdTag tag, int cursorPosition) {
    var mt = MdTagger(text, tag, cursorPosition, cursorPosition);
    return mt.text;
  }

  test("mt.currentLineHeadPosition", () {
    expect(currentLineHeadPosition("", 0), 0);
    expect(currentLineHeadPosition("ab", 0), 0);
    expect(currentLineHeadPosition("ab", 1), 0);
    expect(currentLineHeadPosition("ab", 2), 0);

    expect(currentLineHeadPosition("a\nb", 0), 0);
    expect(currentLineHeadPosition("a\nb", 1), 0);
    expect(currentLineHeadPosition("a\nb", 2), 2);
    expect(currentLineHeadPosition("a\nb", 3), 2);
    expect(currentLineHeadPosition("a\n\nb", 3), 3);

    expect(currentLineHeadPosition("ab\n", 2), 0);
    expect(currentLineHeadPosition("ab\n", 3), 3);
  });

  test("mt.currentLineHeadPosition throwException", () {
    try {
      currentLineHeadPosition("", -1);
      expect(true, false);
    } catch (e) {
      expect(true, true, reason: "カーソル位置が負数");
    }

    try {
      expect(currentLineHeadPosition("ab", 3), 0);
      expect(true, false);
    } catch (e) {
      expect(true, true, reason: "カーソル位置が文字列長を超えている");
    }

    expect(currentLineHeadPosition("\n", 1), 1, reason: "改行も文字列長に含まれる");
  });

  test("mt.addMdTag 見出し", () {
    expect(addMdTag("abc", MdTag.header, 1), "# abc");
    expect(addMdTag("# abc", MdTag.header, 1), "## abc");

    expect(addMdTag("a\nbc", MdTag.header, 1), "# a\nbc");
    expect(addMdTag("a\nbc", MdTag.header, 2), "a\n# bc");
    expect(addMdTag("a\nbc", MdTag.header, 3), "a\n# bc");

    expect(addMdTag("ab\nc", MdTag.header, 3), "ab\n# c");
  });

  test("mt.addMdTag 箇条書き", () {
    // expect(mt.addMdTag("abc", "-", 1), "- abc");
    expect(addMdTag("- abc", MdTag.unorderedList, 1), "  - abc");
  });
}
