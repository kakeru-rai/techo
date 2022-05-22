import 'package:test/test.dart';
import 'package:flutter_hello_world/screen/detail_screen.dart';

void main() {
  test("currentLineHeadPosition", () {
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

  test("currentLineHeadPosition throwException", () {
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

  test("addMdTag 見出し", () {
    expect(addMdTag("abc", "#", 1), "# abc");
    expect(addMdTag("# abc", "#", 1), "## abc");

    expect(addMdTag("a\nbc", "#", 1), "# a\nbc");
    expect(addMdTag("a\nbc", "#", 2), "a\n# bc");
    expect(addMdTag("a\nbc", "#", 3), "a\n# bc");

    expect(addMdTag("ab\nc", "#", 3), "ab\n# c");
  });

  test("addMdTag 箇条書き", () {
    // expect(addMdTag("abc", "-", 1), "- abc");
    expect(addMdTag("- abc", "-", 1), "  - abc");
  });
}
