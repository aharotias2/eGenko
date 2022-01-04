/*
 * This file is part of GenkoYoshi.
 *
 *     GenkoYoshi is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     GenkoYoshi is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with GenkoYoshi.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2021 Takayuki Tanaka
 */

/**
 * 原稿用紙に表示するテキストを保持・操作するためのモデルクラス。
 * 内部的には連結リストで一文字ずつテキストを保持する。
 */
public class TextModel : Object {
    // シグナル

    public signal void cursor_moved(CellPosition cursor_position);
    public signal void changed();

    // プロパティ

    public EditMode edit_mode { get; private set; default = DIRECT_INPUT; }

    public Availability hurigana_mode { get; set; default = ENABLED; }

    public bool can_undo { get { return undo_list.has_history(); } }

    public bool can_redo { get { return redo_list.has_history(); } }

    // プライベートフィールド

    private Gee.List<SimpleList<TextElement>> data;
    private Region selection = {{0, 0}, {0, 0}};
    private Region preedit = {{-1, -1}, {-1, -1}};
    private History undo_list;
    private History redo_list;
    private Gee.LinkedList<EditAction>? preedit_action_list;

    // パブリックメソッド

    /**
     * デフォルトのコンストラクタ。
     * 空のテキストを作成して保持する。
     */
    public TextModel() {
        undo_list = new History();
        redo_list = new History();
        data = construct_text("", DIRECT_INPUT, NOWRAP, false);
        assert(data.size > 0);
    }

    /**
     * 文字列を受け取るコンストラクタ。
     * 引数の文字列からテキストを作成して保持する。
     */
    public TextModel.from_string(string src) {
        set_contents(src);
    }

    // ステータス関連

    /**
     * 行数を数える。ただし見えている行数なので一行の上限は20文字までとなる。
     */
    public int count_visible_lines() {
        return data.size;
    }

    /**
     * 改行の数を数える。
     */
    public int count_lines() {
        int count = 1;
        foreach (var line in data) {
            if (line.size > 0) {
                if (line.get_last().str == "\n") {
                    count++;
                }
            }
        }
        return count;
    }

    /**
     * ページ数を数える。
     */
    public int count_pages() {
        return data.size / X_LENGTH + 1;
    }

    /**
     * 全ての文字数を数える。
     * UTF-8での数え方なのでバイト数ではない。
     */
    public int count_chars() {
        int result = 0;
        foreach (var line in data) {
            result += line.size;
        }
        return result;
    }

    /**
     * 指定の位置にある文字を取得する。
     * 指定の位置に文字がない場合、nullを返す。
     */
    public TextElement? get_element(int hpos, int vpos) {
        if (hpos < data.size) {
            if (vpos < data[hpos].size) {
                return data[hpos][vpos];
            }
        }
        return null;
    }

    /**
     * 指定した位置が選択範囲に含まれているかどうかを判定する。
     */
    public bool is_in_selection(CellPosition pos) {
        return pos in selection;
    }

    // カーソル関連

    /**
     * offsetで指定した文字数分、カーソルを前方に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_foreward(int offset = 1, bool is_shift_masked = false) {
        selection.last.self_add_offset(offset);
        if (!is_shift_masked) {
            selection.start = selection.last;
        }
        cursor_moved(selection.last);
    }

    /**
     * offsetで指定した文字数分、カーソルを後方に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_backward(int offset = 1, bool is_shift_masked = false) {
        selection.last.self_subtract_offset(offset);
        if (!is_shift_masked) {
            selection.start = selection.last;
        }
        cursor_moved(selection.last);
    }

    /**
     * カーソルを行頭に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_beginning_of_line(bool is_shift_masked = false) {
        selection.last.vpos = 0;
        if (!is_shift_masked) {
            selection.start = selection.last;
        }
        cursor_moved(selection.last);
    }

    /**
     * カーソルを行末に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_end_of_line(bool is_shift_masked = false) {
        selection.last.vpos = X_LENGTH - 1;
        if (!is_shift_masked) {
            selection.start = selection.last;
        }
        cursor_moved(selection.last);
    }

    /**
     * カーソルを左のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_left(int offset = 1, bool is_shift_masked = false) {
        selection.last.self_add({offset, 0});
        if (!is_shift_masked) {
            selection.start = selection.last;
        }
        cursor_moved(selection.last);
    }

    /**
     * カーソルを右のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     * カーソルが先頭行にある場合、何もしない。
     */
    public void move_to_right(int offset = 1, bool is_shift_masked = false) {
        if (selection.last.hpos > 0) {
            selection.last.self_subtract({offset, 0});
            if (!is_shift_masked) {
                selection.start = selection.last;
            }
        }
        cursor_moved(selection.last);
    }

    /**
     * カーソルを左端のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_leftend_of_page(int page = 0, bool is_shift_masked = false) {
        selection.last.hpos = page * Y_LENGTH + Y_LENGTH - 1;
        if (!is_shift_masked) {
            selection.start = selection.last;
        }
        cursor_moved(selection.last);
    }

    /**
     * カーソルを右端のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_rightend_of_page(int page = 0, bool is_shift_masked = false) {
        selection.last.hpos = page * Y_LENGTH;
        if (!is_shift_masked) {
            selection.start = selection.last;
        }
        cursor_moved(selection.last);
    }

    /**
     * カーソルを任意の位置に移動する。
     */
    public void set_cursor(CellPosition new_pos) {
        if (edit_mode == PREEDITING) {
            var action_list = begin_new_edit_action();
            delete_region(selection, action_list);
            end_preedit();
        }
        selection.move_to(new_pos);
        cursor_moved(selection.last);
    }

    public Region get_selection() {
        return selection;
    }

    public void set_selection(Region selection) {
        this.selection = selection;
        cursor_moved(selection.last);
    }

    /**
     * 選択範囲の始点を設定する。
     */
    public void set_selection_start(CellPosition new_pos) {
        selection.start = new_pos;
        cursor_moved(selection.start);
    }

    public CellPosition get_selection_start() {
        return selection.start;
    }

    /**
     * 選択範囲の終点を設定する。
     */
    public void set_selection_last(CellPosition new_pos) {
        selection.last = new_pos;
        cursor_moved(selection.last);
    }

    public CellPosition get_selection_last() {
        return selection.last;
    }

    // 編集関連

    public void set_contents(string? new_text) {
        set_contents_async.begin(new_text);
    }

    public async void set_contents_async(string? new_text) {
        data.clear();
        if (new_text == null || new_text.length == 0) {
            return;
        }
        string[] lines = new_text.split("\n");
        int limit_lines = X_LENGTH;
        for (int i = 0; i < lines.length; i++) {
            var text_list = construct_text(lines[i], DIRECT_INPUT, WRAP, true);
            if (i < lines.length - 1) {
                text_list.last().add(new TextElement("\n"));
            }
            data.add_all(text_list);
            int visible_lines = count_visible_lines();
            if (visible_lines > limit_lines) {
                limit_lines = X_LENGTH * ((visible_lines / X_LENGTH) + 1);
                Idle.add(set_contents_async.callback);
                yield;
            }
        }
        changed();
    }

    public string get_contents() {
        StringBuilder sb = new StringBuilder();
        foreach (var visible_line in data) {
            foreach (var text_element in visible_line) {
                sb.append(text_element.str);
            }
        }
        return sb.str;
    }

    /**
     * テキストを空にする。
     */
    public void clear() {
        select_all();
        var action_list = begin_new_edit_action();
        delete_region(selection, action_list);
        cursor_moved(selection.last);
    }

    /**
     * 選択範囲を文字列形式で取得する。
     */
    public string selection_to_string() {
        Region region = selection.asc_order();
        CellPosition p = region.start;
        var sb = new StringBuilder();
        while (p.comp_le(region.last)) {
            if (p.hpos < data.size) {
                if (p.vpos < data[p.hpos].size) {
                    sb.append(data[p.hpos][p.vpos].str);
                    p.self_add_offset(1);
                } else {
                    p = {p.hpos + 1, 0};
                    continue;
                }
            } else {
                break;
            }
        }
        return sb.str;
    }

    /**
     * 文字列を挿入する。
     *
     * 選択範囲がある場合 (selection.startとselection.lastが違う場合)、
     * 選択範囲を削除して挿入する。
     */
    public void insert_string(string src) {
        debug("insert_string(%s)", src);
        // 挿入するテキストを作成する。
        EditMode tmp = DIRECT_INPUT;
        if (edit_mode == PREEDITING) {
            selection = preedit;
            tmp = edit_mode;
        }

        debug("insert_string (%s) at [[%d, %d], [%d, %d]]\n",
                src, selection.start.hpos, selection.start.vpos,
                selection.last.hpos, selection.last.vpos);

        var new_text = construct_text(src, DIRECT_INPUT, NOWRAP);
        var action_list = edit_mode == PREEDITING ? preedit_action_list : begin_new_edit_action();
        insert_text(new_text, action_list);
        cursor_moved(selection.last);

        edit_mode = tmp;
        if (edit_mode == PREEDITING) {
            preedit.move_to(selection.start);
        }
    }

    public void insert_newline() {
        debug("is newline");
        var text = construct_text("\n", DIRECT_INPUT, NOWRAP);
        var action_list = begin_new_edit_action();
        insert_text(text, action_list);
        cursor_moved(selection.last);
    }

    /**
     * プリエディットの開始時の処理。
     * プリエディットの範囲を選択範囲の開始点と同じにする。
     */
    public void start_preedit() {
        debug("start_preedit");
        preedit_action_list = begin_new_edit_action();
        preedit.move_to(selection.start);
        edit_mode = PREEDITING;
    }

    /**
     * プリエディットの終了処理。
     * 始点と終点をクリアする。
     */
    public void end_preedit() {
        debug("end_preedit");
        preedit_action_list = null;
        preedit.move_to({ -1, -1 });
        edit_mode = DIRECT_INPUT;
    }

    /**
     * プリエディットの文字列が変更された時の処理。
     * 現在のプリエディットを削除し、新しいプリエディットを挿入する。
     */
    public void preedit_changed(string? preedit_string) {
        debug("preedit_changed(%s)", preedit_string);
        if (edit_mode == DIRECT_INPUT) {
            return;
        }

        selection = preedit;
        debug("preedit_changed (%s) at [[%d, %d], [%d, %d]]\n",
                preedit_string, selection.start.hpos, selection.start.vpos,
                selection.last.hpos, selection.last.vpos);

        var preedit_text = construct_text(preedit_string, PREEDITING, NOWRAP);
        var preedit_size = preedit_text[0].size;

        //var action_list = begin_new_edit_action();
        insert_text(preedit_text, preedit_action_list);
        preedit.last = preedit.start.add_offset(preedit_size);
        selection = preedit;
        cursor_moved(preedit.last);
    }

    /**
     * 文字を削除する。
     */
    public void delete_char() {
        var action_list = begin_new_edit_action();
        delete_region(selection, action_list);
        cursor_moved(selection.last);
    }

    /**
     * 文字を削除する。(バックスペース処理)
     */
    public void delete_char_backward() {
        if (data == null || data.size == 0 || (data.size == 1 && data[0].size == 0)) {
            // テキストが空の場合 (1文字も持っていない場合) は何もしない。カーソルを0, 0の位置に戻す。
            selection = {{0, 0}, {0, 0}};
            cursor_moved(selection.start);
            return;
        }
        if (selection.start.comp_eq(selection.last)) {
            // カーソルが1つ (選択範囲がない) の場合
            if (selection.start.comp_eq({0, 0})) {
                // カーソルが0, 0の位置にある場合、何もしない。
                return;
            }
            // バックスペース押した時のイベントなのでカーソルを一つ後ろに移動する。
            selection.start.self_subtract_offset(1);
            if (selection.start.hpos >= data.size) {
                // カーソルが文書全体より後ろにある場合、カーソルを文書の最後の位置に動かして終了する
                selection.move_to({data.size - 1, data.last().size});
                cursor_moved(selection.start);
                return;
            } else if (selection.start.vpos >= data[selection.start.hpos].size) {
                // カーソルが行末より下にある場合行末に移動する。
                selection.move_to({selection.start.hpos, data[selection.start.hpos].size - 1});
            }
            selection.last = selection.start;
        }
        debug("delete at [[%d, %d], [%d, %d]]\n",
                selection.start.hpos, selection.start.vpos, selection.last.hpos, selection.last.vpos);
        var action_list = begin_new_edit_action();
        delete_region(selection, action_list);
        cursor_moved(selection.last);
    }

    /**
     * 選択範囲を削除する。
     */
    public void delete_selection() {
        var action_list = begin_new_edit_action();
        delete_region(selection, action_list);
        cursor_moved(selection.last);
    }

    /**
     * アンドゥ処理を行う。
     */
    public void do_undo() {
        var action_list = undo_list.pop_action();
        foreach_reverse<EditAction>(action_list, (action) => {
            selection = action.undo();
        });
        redo_list.push_action(action_list);
        cursor_moved(selection.last);
    }

    /**
     * リドゥ処理を行う。
     */
    public void do_redo() {
        var action_list = redo_list.pop_action();
        foreach(var action in action_list) {
            selection = action.redo();
        }
        undo_list.push_action(action_list);
        cursor_moved(selection.last);
    }

    public Gee.LinkedList<EditAction> begin_new_edit_action() {
        redo_list.clear();
        return undo_list.new_edit_action();
    }

    /**
     * 「全て選択」を行う。
     */
    public void select_all() {
        if (data.size == 0) {
            selection = {{0, 0}, {0, 0}};
        } else {
            selection.start = { 0, 0 };
            if (data.last().size == 0) {
                selection.last = {data.size - 1, 0 };
            } else {
                selection.last = { data.size - 1, data.last().size - 1 };
            }
        }
        cursor_moved(selection.last);
    }

    // プライベートメソッド

    /**
     * 選択範囲にあるテキストを削除し、その代わりに新たなテキストを挿入する。
     */
    private void insert_text(Gee.List<SimpleList<TextElement>> new_piece, Gee.List<EditAction> action_list) {
        var insert_text_action = new InsertTextAction(data, selection, new_piece, edit_mode);
        selection = insert_text_action.perform();
        action_list.add(insert_text_action);
    }

    /**
     * 二つのポジションの間にある文字を削除する。
     * 二つのポジションが同じ位置である場合、一つの文字のみ削除する。
     * 二つのポジションが最終行以降にある場合、何もしない。
     */
    private void delete_region(Region region, Gee.List<EditAction> action_list) {
        var delete_region_action = new DeleteRegionAction(data, region, edit_mode);
        selection = delete_region_action.perform();
        action_list.add(delete_region_action);
    }

    /**
     * 文章の一部を作成する処理。
     * 元となる文字列をUTF-8の方式で一文字ずつ分解してTextElementのリストを作る。
     * 改行を含む場合は複数行を作成する。
     */
    private static Gee.List<SimpleList<TextElement>> construct_text(string src,
            EditMode arg_edit_mode = DIRECT_INPUT, WrapMode wrap_mode = NOWRAP,
            bool has_hurigana = false) {
        var result = new Gee.ArrayList<SimpleList<TextElement>>();
        var line = new SimpleList<TextElement>();
        result.add(line);
        int offset = 0;
        while (offset < src.length) {
            bool is_normal_text = true;
            int substr_length = 0;
            char atp = src[offset]; // "atp" means "tha char At This Point"
            try {
                substr_length = Utf8Utils.get_length_sign(atp);
            } catch (Utf8Utils.ParseError e) {
                printerr("Error: %s\n", e.message);
                offset++;
                continue;
            }
            if (substr_length == 1 && atp == '[') {
                // ふりがなを調べる。
                string main_substr, hurigana_substr;
                int match_length = HuriganaHelper.read_hurigana(src, offset, out main_substr, out hurigana_substr);
                if (match_length > 0) {
                    // ふりがなの構文が見付かった場合、ふりがなを設定する。
                    var hurigana_text = construct_text(hurigana_substr, DIRECT_INPUT, NOWRAP);
                    var main_text = construct_text(main_substr, DIRECT_INPUT, NOWRAP, true);
                    var elem = main_text[0][0];
                    elem.has_hurigana = true;
                    elem.hurigana_span = main_text[0].size;
                    elem.hurigana = hurigana_text[0];
                    line.concat(main_text[0]);
                    offset += match_length;
                    is_normal_text = false;
                }
            }
            // ふりがなの構文が見付からなかった場合は、普通のテキストとして処理する。
            if (is_normal_text) {
                var item = new TextElement(src.substring(offset, substr_length));
                item.is_preedit = (arg_edit_mode == PREEDITING);
                item.has_hurigana = has_hurigana;
                line.add(item);
                offset += substr_length;
            }
            // 必要に応じて、折り返し処理を行なう。
            if ((wrap_mode == WRAP && line.size == Y_LENGTH) || atp == '\n') {
                line = new SimpleList<TextElement>();
                result.add(line);
            }
        }
        assert(result.size > 0);
        return result;
    }

    /**
     * デバッグ用のメソッド。
     * 一行分のテキストの内容をデバッグ表示する。
     * 使わない時はコメントアウトする。
     */
    public void analyze_line(SimpleList<TextElement> line) {
        StringBuilder sb = new StringBuilder();
        if (line.size == 0) {
            debug("[]");
        } else {
            sb.append("[");
            for (int i = 0; i < line.size - 1; i++) {
                var e = line[i];
                if (e.str == "\n") {
                    sb.append("\\n, ");
                } else {
                    sb.append(e.str);
                    sb.append(", ");
                }
            }
            if (line.get_last().str == "\n") {
                sb.append("\\n]");
            } else {
                sb.append(line.get_last().str);
                sb.append("]");
            }
            debug(sb.str);
        }
    }

    public void analyze_all_lines(string message) {
        debug(message);
        foreach (var line in data) {
            analyze_line(line);
        }
    }
}
