int main(string[] args) {
    if (args.length < 2) {
        return 1;
    }
    set_print_handler((text) => stdout.puts(text));
    int arg = int.parse(args[1]);
    int i = 1;
    if (arg == i) {
        return test_utf8_to_codepoint("a", 0x61);
    }
    i++;
    if (arg == i) {
        return test_utf8_to_codepoint("©", 0xA9);
    }
    i++;
    if (arg == i) {
        return test_utf8_to_codepoint("あ", 0x3042);
    }
    i++;
    if (arg == i) {
        return test_utf8_to_codepoint("夏", 0x590F);
    }
    i++;
    if (arg == i) {
        return test_utf8_to_codepoint("￮", 0xFFEE);
    }
    i++;
    if (arg == i) {
        return test_utf8_to_codepoint("コ", 0x30B3);
    }
    i++;
    if (arg == i) {
        return test_utf8_to_codepoint("🂠", 0x1F0A0);
    }
    i++;
    if (arg == i) {
        return test_codepoint_to_utf8(0x61, "a");
    }
    i++;
    if (arg == i) {
        return test_codepoint_to_utf8(0xA9, "©");
    }
    i++;
    if (arg == i) {
        return test_codepoint_to_utf8(0x3042, "あ");
    }
    i++;
    if (arg == i) {
        return test_codepoint_to_utf8(0x590F, "夏");
    }
    i++;
    if (arg == i) {
        return test_codepoint_to_utf8(0xFFEE, "￮");
    }
    i++;
    if (arg == i) {
        return test_codepoint_to_utf8(0x30B3, "コ");
    }
    i++;
    if (arg == i) {
        return test_codepoint_to_utf8(0x1F0A0, "🂠");
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
