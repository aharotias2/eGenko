int main(string[] args) {
    set_print_handler((text) => stdout.puts(text));
    set_printerr_handler((text) => stderr.puts(text));
    switch (int.parse(args[1])) {
      default: case 0:
        return 1;
      case 1:
        return test_hurigana_regex(
            "あああああ[/ううう/いいい/]えええええ",
            15,
            "ううう",
            "いいい",
            23
        );
      case 2:
        return test_hurigana_regex(
            "あああああ[/ううう/いいい/]えええええ",
            0,
            null,
            null,
            0
        );
      case 3:
        return test_hurigana_regex(
            "あああああ[/ABC/abc/]えええええ",
            15,
            "ABC",
            "abc",
            11
        );
    }
}

int test_hurigana_regex(string src_text, int start_offset, string? expect_main_text, string? expect_hurigana,
        int expect_match_length) {
    string result_hurigana, result_main_text;
    int result = HuriganaHelper.read_hurigana(src_text, start_offset, out result_main_text, out result_hurigana);
    print("match-length: result => %d, expect => %d\n", result, expect_match_length);
    assert(result == expect_match_length);
    if (result > 0) {
        print("hurigana-text: result => %s, expect => %s\n", result_hurigana, expect_hurigana);
        assert(result_hurigana == expect_hurigana);
        print("main-text: result => %s, expect => %s\n", result_main_text, expect_main_text);
        assert(result_main_text == expect_main_text);
    }
    return 0;
}
