int main(string[] argv) {
    if (argv.length < 2) {
        return 1;
    }
    set_print_handler((text) => stdout.puts(text));
    set_printerr_handler((text) => stdout.puts(text));
    var main_loop = new MainLoop();
    int result_code = 0;
    select_test.begin(argv[1], (obj, res) => {
        result_code = select_test.end(res);
        main_loop.quit();
    });
    main_loop.run();
    return 0;
}

async int select_test(string test_name) {
    switch (test_name) {
      case "construct_text_1":
        return yield test_construct_text(
                "ああああああいいいいいい", 12, 1, 1);
                
      case "construct_text_2":
        return yield test_construct_text(
                "ああああああいいいいいいううううううええええええ", 24, 1, 2);
                
      case "construct_text_3":
        return yield test_construct_text(
                "ああああああいいいいいい\nううううううええええええ", 25, 2, 2);
                
      case "construct_text_4":
        return yield test_construct_text(
                "ああああああいいいいいい\nううううううええええええ\n", 26, 3, 3);
                
      case "get_contents_1":
        return yield test_get_contents("おはようございます。", "おはようございます。");

      case "get_contents_2":
        return yield test_get_contents(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかかかかかかかかか",
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかかかかかかかかか");
        
      case "count_lines_1":
        return yield test_count_lines("おはようございます。", 1);
        
      case "count_lines_2":
        return yield test_count_lines(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかかかかかかかかか",
                2);
        
      case "count_visible_lines_1":
        return yield test_count_visible_lines("おはようございます。", 1);
        
      case "count_visible_lines_2":
        return yield test_count_visible_lines(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                4);
      
      case "insert_string_1":
        return yield test_insert_string("おはようございます。", {0, 4}, "、", "おはよう、ございます。", 1, 1);

      case "insert_string_2":
        return yield test_insert_string(
                "ああああああいいいいいいうううううう",
                {0, 12},
                "ええええええ",
                "ああああああいいいいいいええええええうううううう",
                1,
                2);
        
      case "insert_string_3":
        return yield test_insert_string(
                "ああああああああああいいいいいいいいいいうううううううううう",
                {1, 0},
                "ええええええええええおおおおおおおおおお",
                "ああああああああああいいいいいいいいいいええええええええええおおおおおおおおおおうううううううううう",
                1,
                3);
        
      case "insert_string_4":
        return yield test_insert_string(
                "ああああああいいいいいいううううううええええええおおおおおお",
                {1, 0},
                "かかかかかか\nきききききき\n",
                "ああああああいいいいいいううううううええかかかかかか\nきききききき\nええええおおおおおお",
                3,
                4);
        
      case "insert_string_5":
        return yield test_insert_string(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                {0, 0},
                "ききききききききききくくくくくくくくくく",
                "ききききききききききくくくくくくくくくくああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                2,
                5);
      
      case "insert_string_6":
        return yield test_insert_string(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                {0, 1},
                "ききききききききききくくくくくくくくくく",
                "あききききききききききくくくくくくくくくくあああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                2,
                5);

      case "insert_string_7":
        return yield test_insert_string(
                "ああああああいいいいいいうううううう",
                {0, 17},
                "ええええええ",
                "ああああああいいいいいいうううううええええええう",
                1,
                2);
            
      case "delete_char_1":
        return yield test_delete_char(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                {0, 0},
                "あああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                2,
                4);

      case "delete_char_2":
        return yield test_delete_char(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                {1, 10},
                "ああああああああああいいいいいいいいいいうううううううううう"
                        + "ええええええええええおおおおおおおおおおかかか",
                1,
                3);

      case "delete_char_backward_1":
        return yield test_delete_char_backward(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                {1, 1},
                1,
                "ああああああああああいいいいいいいいいいううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                2,
                4);

      case "delete_char_backward_2":
        return yield test_delete_char_backward(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                {1, 0},
                1,
                "ああああああああああいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                2,
                4);

      case "delete_char_backward_3":
        return yield test_delete_char_backward(
                "ああああああああああいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                {1, 1},
                2,
                "ああああああああああいいいいいいいいいううううううううう\n"
                        + "ええええええええええおおおおおおおおおおかかか",
                2,
                4);

      case "delete_char_backward_4":
        return yield test_delete_char_backward(
                "ああああああああああ",
                {0, 10},
                1,
                "あああああああああ",
                1,
                1);

      case "delete_char_backward_5":
        return yield test_delete_char_backward(
                "ああああああああああ\nいいいいいいいいいい\nうううううううううう\n"
                        + "ええええええええええ\nおおおおおおおおおお\nかかか",
                {2, 0},
                1,
                "ああああああああああ\nいいいいいいいいいいうううううううううう\n"
                        + "ええええええええええ\nおおおおおおおおおお\nかかか",
                5,
                6);

      case "delete_char_backward_6":
        return yield test_delete_char_backward(
                "\n\nあ\n\n\n",
                {1, 0},
                1,
                "\nあ\n\n\n",
                5,
                5);

      case "insert_newline_1":
        return yield test_insert_newline(
                "あああああいいいいいうううううえええ\n",
                {0, 5},
                1,
                "あああああ\nいいいいいうううううえええ\n",
                3,
                3);
        
      case "preedit_changed_1":
        return yield test_preedit_changed(
                "ああああああいいいいいい",
                {0, 6},
                { "う", "ええ", "おおお", "かかかか" },
                "ああああああかかかかいいいいいい",
                1,
                1);
                
      case "preedit_changed_2":
        return yield test_preedit_changed(
                "ああああああいいいいいい",
                {0, 6},
                { "うううううう", "えええ" },
                "ああああああえええいいいいいい",
                1,
                1);
                
      case "preedit_changed_3":
        return yield test_preedit_changed(
                "ああああああいいいいいいうううううう",
                {0, 6},
                { "ええええええ", "おおお" },
                "ああああああおおおいいいいいいうううううう",
                1,
                2);
                
      case "preedit_changed_4":
        return yield test_preedit_changed(
                "ああああああいいいいいいうううううう",
                {0, 17},
                { "ええええええ" },
                "ああああああいいいいいいうううううええええええう",
                1,
                2);
                
      case "preedit_changed_5":
        return yield test_preedit_changed(
                "ああああああいいいいいいうううううう",
                {0, 17},
                { "え", "おお", "かかか", "きききき" },
                "ああああああいいいいいいうううううききききう",
                1,
                2);
                
      case "preedit_changed_6":
        return yield test_preedit_changed(
                "ああああああいいいいいいうううううう",
                {0, 17},
                { "え", "おお", "かかか" },
                "ああああああいいいいいいうううううかかかう",
                1,
                2);
                
      case "preedit_changed_7":
        return yield test_preedit_changed(
                "ああああああいいいいいいうううううう",
                {0, 18},
                { "え", "おお", "かかか" },
                "ああああああいいいいいいううううううかかか",
                1,
                2);

      case "delete_selection_1":
        return yield test_delete_selection(
                "ああああああいいいいいいうううううう",
                {0, 6}, {0, 12},
                "ああああああうううううう",
                1,
                1);
        
      case "delete_selection_2":
        return yield test_delete_selection(
                "ああああああいいいいいいううううううえおかきくえ",
                {0, 19}, {1, 1},
                "ああああああいいいいいいううううううえくえ",
                1,
                2);
        
      case "delete_selection_3":
        return yield test_delete_selection(
                "ああああああいいいいいいううううううえおかきくえ",
                {0, 19}, {1, 1},
                "ああああああいいいいいいううううううえくえ",
                1,
                2);
        
      case "delete_selection_4":
        return yield test_delete_selection(
                "ああああああいいいいいいううううううえおかきくえ",
                {0, 19}, {1, 2},
                "ああああああいいいいいいううううううええ",
                1,
                1);
        
      case "delete_selection_5":
        return yield test_delete_selection(
                "ああああああいいいいいいううううううえおかきくえ",
                {0, 19}, {1, 4},
                "ああああああいいいいいいううううううえ",
                1,
                1);

      case "selection_to_string_1":
        return yield test_selection_to_string(
                "ああああああいいいいいいううううううええおおおおおおかかかかかか",
                {0, 6}, {0, 11},
                "いいいいいい");

      case "selection_to_string_2":
        return yield test_selection_to_string(
                "ああああああいいいいいいううううううええおおおおおおかかかかかか",
                {0, 18}, {1, 5},
                "ええおおおおおお");
        
      default:
        return 1;
    }
}

async int test_construct_text(string src_text, int expect_length, int expect_lines, int expect_visible_lines) {
    var model = new TextModel();
    yield model.set_contents_async(src_text);
    debug("%s\n", model.get_contents());
    print("length: expect = %d, actual = %d\n", expect_length, model.count_chars());
    assert(model.count_chars() == expect_length);
    print("lines: expect = %d, actual = %d\n", expect_lines, model.count_lines());
    assert(model.count_lines() == expect_lines);
    print("visible-lines: expect = %d, actual = %d\n", expect_visible_lines, model.count_visible_lines());
    assert(model.count_visible_lines() == expect_visible_lines);
    return 0;
}

async int test_get_contents(string src_text, string expect) {
    var model = new TextModel();
    yield model.set_contents_async(src_text);
    var result = model.get_contents();
    assert(result == expect);
    return 0;
}

async int test_count_lines(string text, int expect) {
    var model = new TextModel();
    yield model.set_contents_async(text);
    assert(model.count_lines() == expect);
    return 0;
}

async int test_count_visible_lines(string text, int expect) {
    var model = new TextModel();
    yield model.set_contents_async(text);
    assert(model.count_visible_lines() == expect);
    return 0;
}

async int test_insert_string(string text, CellPosition pos, string new_text, string expect, int expect_lines, int expect_visible_lines) {
    var model = new TextModel();
    yield model.set_contents_async(text);
    model.set_cursor(pos);
    model.insert_string(new_text);
    string result = model.get_contents();
    print("result = %s\nexpect = %s\n", result, expect);
    assert(result == expect);
    assert(model.count_lines() == expect_lines);
    assert(model.count_visible_lines() == expect_visible_lines);
    return 0;
}

async int test_preedit_changed(string orig_text, CellPosition preedit_start, string[] preedit_texts,
        string expect_string, int expect_lines, int expect_visible_lines) {
    var model = new TextModel();
    yield model.set_contents_async(orig_text);
    model.set_cursor(preedit_start);
    model.start_preedit();
    for (int i = 0; i < preedit_texts.length - 1; i++) {
        model.preedit_changed(preedit_texts[i]);
        print("preedit_changed!: %s\n", model.get_contents());
    }
    model.insert_string(preedit_texts[preedit_texts.length - 1]);
    print("insert_string!:   %s\n", model.get_contents());
    model.preedit_changed("");
    print("preedit_changed!: %s\n", model.get_contents());
    model.end_preedit();
    string result = model.get_contents();
    print("result = %s\nexpect = %s\n", result, expect_string);
    assert(result == expect_string);
    assert(model.count_lines() == expect_lines);
    assert(model.count_visible_lines() == expect_visible_lines);
    return 0;
}

async int test_delete_char(string text, CellPosition pos, string expect, int expect_lines, int expect_visible_lines) {
    var model = new TextModel();
    yield model.set_contents_async(text);
    model.set_cursor(pos);
    model.delete_char();
    string result = model.get_contents();
    print("result: %s\nexpect: %s\n", result, expect);
    assert(result == expect);
    assert(model.count_lines() == expect_lines);
    assert(model.count_visible_lines() == expect_visible_lines);
    return 0;
}

async int test_delete_selection(string orig_string, CellPosition selection_start,
        CellPosition selection_end, string expect, int expect_lines, int expect_visible_lines) {
    var model = new TextModel();
    yield model.set_contents_async(orig_string);
    model.set_selection_start(selection_start);
    model.set_selection_end(selection_end);
    model.delete_selection();
    string result = model.get_contents();
    print("result: %s\nexpect: %s\n", result, expect);
    assert(result == expect);
    assert(model.count_lines() == expect_lines);
    assert(model.count_visible_lines() == expect_visible_lines);
    return 0;
}

async int test_delete_char_backward(string orig_string, CellPosition cursor_pos, int delete_num,
        string expect, int expect_lines, int expect_visible_lines) {
    var model = new TextModel();
    yield model.set_contents_async(orig_string);
    model.set_cursor(cursor_pos);
    for (int i = 0; i < delete_num; i++) {
        print("call delete char backward\n");
        model.delete_char_backward();
    }
    string result = model.get_contents();
    print("result: %s\nexpect: %s\n", result, expect);
    assert(result == expect);
    print("expected_lines: %d, actual: %d\n", expect_lines, model.count_lines());
    assert(model.count_lines() == expect_lines);
    print("expected_visible_lines: %d, actual: %d\n", expect_visible_lines, model.count_visible_lines());
    assert(model.count_visible_lines() == expect_visible_lines);
    return 0;
}

async int test_insert_newline(string orig, CellPosition insert_pos, int insert_num, 
        string expect, int expect_lines, int expect_visible_lines) {
    var model = new TextModel();
    yield model.set_contents_async(orig);
    model.set_cursor(insert_pos);
    for (int i = 0; i < insert_num; i++) {
        model.insert_string("\n");
    }
    string result = model.get_contents();
    model.analyze_all_lines("analyze_all_lines");
    print("result: %s\nexpect: %s\n", result, expect);
    assert(result == expect);
    print("expected_lines: %d, actual: %d\n", expect_lines, model.count_lines());
    assert(model.count_lines() == expect_lines);
    print("expected_visible_lines: %d, actual: %d\n", expect_visible_lines, model.count_visible_lines());
    assert(model.count_visible_lines() == expect_visible_lines);
    return 0;
}

async int test_selection_to_string(string orig, CellPosition selection_start,
        CellPosition selection_end, string expect) {
    var model = new TextModel();
    yield model.set_contents_async(orig);
    model.set_selection_start(selection_start);
    model.set_selection_end(selection_end);
    string selection = model.selection_to_string();
    print("result => %s, expect => %s\n", selection, expect);
    assert(selection == expect);
    return 0;
}
