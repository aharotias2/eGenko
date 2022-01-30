int main(string[] args) {
    if (args.length < 2) {
        return 1;
    }
    set_print_handler((text) => stdout.puts(text));
    int arg = int.parse(args[1]);
    switch (arg) {
      case 1:
        return test_utf8_to_codepoint("a", 0x61);
      case 2:
        return test_utf8_to_codepoint("©", 0xA9);
      case 3:
        return test_utf8_to_codepoint("あ", 0x3042);
      case 4:
        return test_utf8_to_codepoint("夏", 0x590F);
      case 5:
        return test_utf8_to_codepoint("￮", 0xFFEE);
      case 6:
        return test_utf8_to_codepoint("コ", 0x30B3);
      case 7:
        return test_utf8_to_codepoint("🂠", 0x1F0A0);
      case 8:
        return test_codepoint_to_utf8(0x61, "a");
      case 9:
        return test_codepoint_to_utf8(0xA9, "©");
      case 10:
        return test_codepoint_to_utf8(0x3042, "あ");
      case 11:
        return test_codepoint_to_utf8(0x590F, "夏");
      case 12:
        return test_codepoint_to_utf8(0xFFEE, "￮");
      case 13:
        return test_codepoint_to_utf8(0x30B3, "コ");
      case 14:
        return test_codepoint_to_utf8(0x1F0A0, "🂠");
      case 15:
        return test_string_to_list("あいうえお", 5, "あ", "い", "う", "え", "お");
      case 16:
        return test_string_to_list("あいuえお", 5, "あ", "い", "u", "え", "お");
      case 17:
        return test_string_to_list("", 0);
    }
    return 2;
}

int test_utf8_to_codepoint(string utf8, uint32 expect_codepoint) {
    try {
        uint32 result = Utf8Utils.utf8_to_codepoint((char[]) utf8.data);
        print("codepoint: result => 0x%x, expect => 0x%x\n", result, expect_codepoint);
        assert(result == expect_codepoint);
        return 0;
    } catch (Utf8Utils.ParseError e) {
        printerr("%s\n", e.message);
        return 3;
    }
}

int test_codepoint_to_utf8(uint32 codepoint, string expect_string) {
    string result = Utf8Utils.codepoint_to_utf8(codepoint);
    print("get utf8: result => %s, expect => %s\n", result, expect_string);
    return 0;
}

int test_string_to_list(string s, int expect_list_size, ...) {
    Gee.List<string> result = Utf8Utils.string_to_list(s);
    assert(result.size == expect_list_size);
    var l = va_list();
    for (int i = 0; i < result.size; i++) {
        string? arg = l.arg();
        if (arg == null) {
            assert_not_reached();
        } else {
            assert(result[i] == arg);
        }
    }
    return 0;
}
