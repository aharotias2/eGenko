/**
 * Tests of CellPosition.
 */
int main(string[] argv) {
    if (argv.length != 2) {
        return 1;
    }
    int test_case = int.parse(argv[1]);
    if (test_case == 0) {
        return 3;
    }
    print("test %d: ", test_case);
    switch (test_case) {
      case 1:
        return test_add_offset({0, 0}, 1, {0, 1});
      case 2:
        return test_add_offset({0, 0}, 19, {0, 19});
      case 3:
        return test_add_offset({0, 0}, 20, {1, 0});
      case 4:
        return test_add_offset({0, 0}, 39, {1, 19});
      case 5:
        return test_add_offset({1, 0}, 40, {3, 0});
      case 6:
        return test_add_offset({2, 19}, 1, {3, 0});
      case 7:
        return test_add({0, 0}, {0, 1}, {0, 1});
      case 8:
        return test_add({1, 10}, {1, 10}, {3, 0});
      case 9:
        return test_add({2, 15}, {10, 6}, {13, 1});
      case 10:
        return test_subtract_offset({1, 9}, 1, {1, 8});
      case 11:
        return test_subtract_offset({1, 3}, 3, {1, 0});
      case 12:
        return test_subtract_offset({1, 3}, 4, {0, 19});
      case 13:
        return test_subtract_offset({2, 3}, 24, {0, 19});
      case 14:
        return test_comp_eq({2, 3}, {2, 3}, true);
      case 15:
        return test_comp_eq({2, 4}, {2, 3}, false);
      case 16:
        return test_comp_eq({3, 3}, {2, 3}, false);
      case 17:
        return test_comp_gt({3, 3}, {3, 2}, true);
      case 18:
        return test_comp_gt({3, 3}, {3, 3}, false);
      case 19:
        return test_comp_gt({3, 3}, {3, 4}, false);
      case 20:
        return test_comp_lt({3, 3}, {3, 2}, false);
      case 21:
        return test_comp_lt({3, 3}, {3, 3}, false);
      case 22:
        return test_comp_lt({3, 3}, {3, 4}, true);
      case 23:
        return test_comp_ge({3, 3}, {3, 2}, true);
      case 24:
        return test_comp_ge({3, 3}, {3, 3}, true);
      case 25:
        return test_comp_ge({3, 3}, {3, 4}, false);
      case 26:
        return test_comp_le({3, 3}, {3, 2}, false);
      case 27:
        return test_comp_le({3, 3}, {3, 3}, true);
      case 28:
        return test_comp_le({3, 3}, {3, 4}, true);
      case 29:
        return test_comp_gt({4, 3}, {3, 4}, true);
      case 30:
        return test_comp_gt({3, 3}, {4, 2}, false);
      case 31:
        return test_comp_lt({4, 3}, {3, 4}, false);
      case 32:
        return test_comp_lt({3, 4}, {4, 2}, true);
      case 33:
        return test_comp_ge({4, 3}, {3, 4}, true);
      case 34:
        return test_comp_ge({3, 3}, {4, 2}, false);
      case 35:
        return test_comp_le({4, 3}, {3, 4}, false);
      case 36:
        return test_comp_le({3, 4}, {4, 2}, true);
      case 37:
        return test_subtract({1, 9}, {0, 5}, {1, 4});
      case 38:
        return test_subtract({1, 3}, {1, 2}, {0, 1});
      case 39:
        return test_subtract({2, 3}, {1, 4}, {0, 19});
      case 40:
        return test_subtract({2, 3}, {2, 4}, {0, 0});
      default:
        return 2;
    }
}

int test_add_offset(CellPosition p1, int offset, CellPosition expect) {
    var p2 = p1.add_offset(offset);
    assert(p2.hpos == expect.hpos);
    assert(p2.vpos == expect.vpos);
    print("ok\n");
    return 0;
}

int test_add(CellPosition p1, CellPosition p2, CellPosition expect) {
    var p3 = p1.add(p2);
    assert(p3.hpos == expect.hpos);
    assert(p3.vpos == expect.vpos);
    print("ok\n");
    return 0;
}

int test_subtract_offset(CellPosition p1, int offset, CellPosition expect) {
    var p2 = p1.subtract_offset(offset);
    assert(p2.hpos == expect.hpos);
    assert(p2.vpos == expect.vpos);
    print("ok\n");
    return 0;
}

int test_subtract(CellPosition p1, CellPosition p2, CellPosition expect) {
    var p3 = p1.subtract(p2);
    assert(p3.hpos == expect.hpos);
    assert(p3.vpos == expect.vpos);
    print("ok\n");
    return 0;
}

int test_comp_eq(CellPosition p1, CellPosition p2, bool expect) {
    bool result = p1.comp_eq(p2);
    assert(result == expect);
    print("ok\n");
    return 0;
}

int test_comp_gt(CellPosition p1, CellPosition p2, bool expect) {
    bool result = p1.comp_gt(p2);
    assert(result == expect);
    print("ok\n");
    return 0;
}

int test_comp_lt(CellPosition p1, CellPosition p2, bool expect) {
    bool result = p1.comp_lt(p2);
    assert(result == expect);
    print("ok\n");
    return 0;
}

int test_comp_le(CellPosition p1, CellPosition p2, bool expect) {
    bool result = p1.comp_le(p2);
    assert(result == expect);
    print("ok\n");
    return 0;
}

int test_comp_ge(CellPosition p1, CellPosition p2, bool expect) {
    bool result = p1.comp_ge(p2);
    assert(result == expect);
    print("ok\n");
    return 0;
}
