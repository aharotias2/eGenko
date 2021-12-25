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
    
    public bool can_undo { get { return undo_list.size > 0; } }
    
    public bool can_redo { get { return redo_list.size > 0; } }
    
    // プライベートフィールド
        
    private Gee.List<SimpleList<TextElement>> data;
    private CellPosition selection_start = { 0, 0 };
    private CellPosition selection_end = { 0, 0 };
    private CellPosition preedit_start = { -1, -1 };
    private CellPosition preedit_end = { -1, -1 };
    private Gee.Deque<HistoryItem> undo_list;
    private Gee.Deque<HistoryItem> redo_list;
    
    // パブリックメソッド
    
    /**
     * デフォルトのコンストラクタ。
     * 空のテキストを作成して保持する。
     */
    public TextModel() {
        undo_list = new Gee.ArrayQueue<HistoryItem>();
        redo_list = new Gee.ArrayQueue<HistoryItem>();
        data = construct_text("", DIRECT_INPUT, NOWRAP);
    }

    /**
     * 文字列を受け取るコンストラクタ。
     * 引数の文字列からテキストを作成して保持する。
     */
    public TextModel.from_string(string src) {
        data = construct_text(src, DIRECT_INPUT, NOWRAP);
        for (int i = data.size - 1; i >= 0; i--) {
            wrap_line(i);
        }
    }

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
        int offset1 = selection_start.hpos * Y_LENGTH + selection_start.vpos;
        int offset2 = selection_end.hpos * Y_LENGTH + selection_end.vpos;
        int offset3 = pos.hpos * Y_LENGTH + pos.vpos;
        if (offset1 == offset2) {
            return offset1 == offset3;
        } else if (offset1 < offset2) {
            return offset1 <= offset3 && offset3 <= offset2;
        } else {
            return offset2 <= offset3 && offset3 <= offset1;
        }
    }
    
    /**
     * offsetで指定した文字数分、カーソルを前方に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_foreward(int offset = 1, bool is_shift_masked = false) {
        selection_end.self_add_offset(offset);
        if (!is_shift_masked) {
            selection_start = selection_end;
        }
        cursor_moved(selection_end);
    }
    
    /**
     * offsetで指定した文字数分、カーソルを後方に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_backward(int offset = 1, bool is_shift_masked = false) {
        selection_end.self_subtract_offset(offset);
        if (!is_shift_masked) {
            selection_start = selection_end;
        }
        cursor_moved(selection_end);
    }

    /**
     * カーソルを行頭に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_beginning_of_line(bool is_shift_masked = false) {
        selection_end.vpos = 0;
        if (!is_shift_masked) {
            selection_start = selection_end;
        }
        cursor_moved(selection_end);
    }

    /**
     * カーソルを行末に移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_end_of_line(bool is_shift_masked = false) {
        selection_end.vpos = X_LENGTH - 1;
        if (!is_shift_masked) {
            selection_start = selection_end;
        }
        cursor_moved(selection_end);
    }
    
    /**
     * カーソルを左のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_left(int offset = 1, bool is_shift_masked = false) {
        selection_end.self_add({offset, 0});
        if (!is_shift_masked) {
            selection_start = selection_end;
        }
        cursor_moved(selection_end);
    }

    /**
     * カーソルを右のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     * カーソルが先頭行にある場合、何もしない。
     */
    public void move_to_right(int offset = 1, bool is_shift_masked = false) {
        if (selection_end.hpos > 0) {
            selection_end.self_subtract({offset, 0});
            if (!is_shift_masked) {
                selection_start = selection_end;
            }
        }
        cursor_moved(selection_end);
    }

    /**
     * カーソルを左端のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_leftend_of_page(int page = 0, bool is_shift_masked = false) {
        selection_end.hpos = page * Y_LENGTH + Y_LENGTH - 1;
        if (!is_shift_masked) {
            selection_start = selection_end;
        }
        cursor_moved(selection_end);
    }

    /**
     * カーソルを右端のセルに移動する。
     * is_shift_maskedがtrueの場合、カーソルの代わりに選択範囲の末尾を移動する。
     */
    public void move_to_rightend_of_page(int page = 0, bool is_shift_masked = false) {
        selection_end.hpos = page * Y_LENGTH;
        if (!is_shift_masked) {
            selection_start = selection_end;
        }
        cursor_moved(selection_end);
    }

    /**
     * カーソルを任意の位置に移動する。
     */
    public void set_cursor(CellPosition new_pos) {
        if (edit_mode == PREEDITING) {
            delete_between(selection_start, selection_end);
            end_preedit();
        }
        selection_start = new_pos;
        selection_end = new_pos;
        cursor_moved(selection_end);
    }
    
    /**
     * 選択範囲の始点を設定する。
     */
    public void set_selection_start(CellPosition new_pos) {
        selection_start = new_pos;
        cursor_moved(selection_start);
    }

    public CellPosition get_selection_start() {
        return selection_start;
    }
    
    /**
     * 選択範囲の終点を設定する。
     */
    public void set_selection_end(CellPosition new_pos) {
        selection_end = new_pos;
        cursor_moved(selection_end);
    }

    public CellPosition get_selection_end() {
        return selection_end;
    }
    
    public void set_contents(string new_text) {
        set_contents_async.begin(new_text);
    }
    
    public async void set_contents_async(string new_text) {
        data.clear();
        foreach (var line in new_text.split("\n")) {
            var new_line = construct_text(line, DIRECT_INPUT, WRAP);
            new_line[0].add(new TextElement("\n"));
            data.add(new_line[0]);
            Idle.add(set_contents_async.callback);
            yield;
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
     * 選択範囲を文字列形式で取得する。
     */
    public string selection_to_string() {
        CellPosition p1, p2, p;
        if (selection_start.comp_lt(selection_end)) {
            p1 = selection_start;
            p2 = selection_end;
        } else {
            p1 = selection_end;
            p2 = selection_start;
        }
        p = p1;
        var sb = new StringBuilder();
        while (p.comp_le(p2)) {
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
     * 選択範囲がある場合 (selection_startとselection_endが違う場合)、
     * 選択範囲を削除して挿入する。
     */
    public void insert_string(string src) {
        debug("insert_string(%s)", src);
        // 挿入するテキストを作成する。
        EditMode tmp = DIRECT_INPUT;
        if (edit_mode == PREEDITING) {
            selection_start = preedit_start;
            selection_end = preedit_end;
            tmp = edit_mode;
        }
        
        debug("insert_string (%s) at [[%d, %d], [%d, %d]]\n",
                src, selection_start.hpos, selection_start.vpos,
                selection_end.hpos, selection_end.vpos);

        var new_text = construct_text(src, DIRECT_INPUT, NOWRAP);
        insert_text(new_text);
        
        edit_mode = tmp;
        if (edit_mode == PREEDITING) {
            start_preedit();
        }
    }

    public void insert_newline() {
        debug("is newline");
        var text = construct_text("\n", DIRECT_INPUT, NOWRAP);
        insert_text(text);
        undo_list.add(new HistoryItem(INSERT, text, null, selection_start, selection_end));
    }

    public void insert_text(Gee.List<SimpleList<TextElement>> new_piece) {
        // 選択範囲の二つの点のうち前にあるものをp1、後ろにあるものをp2とする
        CellPosition p1, p2;
        if (selection_start.comp_le(selection_end)) {
            p1 = selection_start;
            p2 = selection_end;
        } else {
            p1 = selection_end;
            p2 = selection_start;
        }

        // 選択範囲内の文字列を削除する。
        if (!p1.comp_eq(p2)) {
            debug("insert_text go into delete selection");
            delete_between(selection_start, selection_end);
            debug("insert_text come back from delete selection");
        }
        
        selection_start = p1;
        selection_end = p1;

        // 選択範囲の先頭が行末より下にある場合、空白文字で埋める。
        if (p1.hpos >= data.size || p1.vpos >= data[p1.hpos].size) {
            pad_space(p1.hpos, p1.vpos);
        }
        
        var line = data[p1.hpos];
        
        if (text_is_newline(new_piece)) {
            debug("insert a newline");
            // 改行を挿入する
            if (p1.vpos < line.size) {
                var new_line = line.cut_at(p1.vpos);
                line.add(new TextElement("\n"));
                data.insert(p1.hpos + 1, new_line);
                CellPosition new_pos = {p1.hpos + 1, 0};
                debug("new pos = [%d, %d]", new_pos.hpos, new_pos.vpos);
                set_cursor(new_pos);
            } else {
                CellPosition new_pos = {p1.hpos + 1, 0};
                debug("new pos = [%d, %d]", new_pos.hpos, new_pos.vpos);
                set_cursor(new_pos);
                pad_space(new_pos.hpos, new_pos.vpos);
            }
            return;
        // 新しい文字列を追加する。
        } else if (new_piece.size == 1) {
            debug("insert a single line");
            // 挿入する文字列が一行の場合は単純に挿入して行折り返し処理をする。
            int new_piece_size = new_piece[0].size;
            line.insert_all(p1.vpos, new_piece[0]);
            if (data[p1.hpos].size >= Y_LENGTH) {
                wrap_line(p1.hpos);
            }

            // カーソルを挿入した文字列の末尾の位置に移動する。
            selection_start = p1.add_offset(new_piece_size);
        } else {
            debug("insert multiple lines");
            int new_piece_last_size = new_piece.last().size;
            // 複数行挿入する場合は一行ずつ処理をする。
            if (p1.vpos == 0) {
                if (line.size > 0) {
                    new_piece.last().concat(line);
                }
            } else if (p1.vpos >= line.size) {
                new_piece.first().insert_all(0, line);
            } else {
                var part1 = line;
                var part2 = part1.cut_at(p1.vpos);
                new_piece[0].insert_all(0, part1);
                new_piece.last().concat(part2);
            }

            data.remove_at(p1.hpos);

            int n_lines = 0;
            for (int i = new_piece.size - 1; i >= 0; i--) {
                data.insert(p1.hpos, new_piece[i]);
                n_lines += wrap_line(p1.hpos);
            }

            // カーソルを挿入した文字列の末尾の位置に移動する。
            selection_start = {
                p1.hpos + n_lines,
                new_piece_last_size % Y_LENGTH
            };
        }
        
        selection_end = selection_start;
        cursor_moved(selection_end);
    }
    
    /**
     * プリエディットの開始時の処理。
     * プリエディットの範囲を選択範囲の開始点と同じにする。
     */
    public void start_preedit() {
        debug("start_preedit");
        preedit_start = selection_start;
        preedit_end = preedit_start;
        edit_mode = PREEDITING;
    }

    /**
     * プリエディットの終了処理。
     * 始点と終点をクリアする。
     */
    public void end_preedit() {
        debug("end_preedit");
        preedit_start = { -1, -1 };
        preedit_end = { -1, -1 };
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

        selection_start = preedit_start;
        selection_end = preedit_end;
        debug("preedit_changed (%s) at [[%d, %d], [%d, %d]]\n",
                preedit_string, selection_start.hpos, selection_start.vpos,
                selection_end.hpos, selection_end.vpos);

        var preedit_text = construct_text(preedit_string, PREEDITING, NOWRAP);
        var preedit_size = preedit_text[0].size;

        insert_text(preedit_text);
        
        preedit_end = preedit_start.add_offset(preedit_size);
        selection_start = preedit_start;
        selection_end = preedit_end;
        cursor_moved(preedit_end);
    }

    /**
     * 文字を削除する。
     */
    public void delete_char() {
        delete_between(selection_start, selection_end);
        cursor_moved(selection_end);
    }
    
    /**
     * 文字を削除する。(バックスペース処理)
     */
    public void delete_char_backward() {
        if (data == null || data.size == 0 || (data.size == 1 && data[0].size == 0)) {
            // テキストが空の場合 (1文字も持っていない場合) は何もしない。カーソルを0, 0の位置に戻す。
            selection_start = { 0, 0 };
            selection_end = { 0, 0 };
            cursor_moved(selection_start);
            return;
        }
        if (selection_start.comp_eq(selection_end)) {
            // カーソルが1つ (選択範囲がない) の場合
            if (selection_start.comp_eq({0, 0})) {
                // カーソルが0, 0の位置にある場合、何もしない。
                return;
            }
            // バックスペース押した時のイベントなのでカーソルを一つ後ろに移動する。
            selection_start.self_subtract_offset(1);
            if (selection_start.hpos >= data.size) {
                // カーソルが文書全体より後ろにある場合、カーソルを文書の最後の位置に動かして終了する
                selection_start.hpos = data.size - 1;
                selection_start.vpos = data[selection_start.hpos].size;
                selection_end = selection_start;
                cursor_moved(selection_start);
                return;
            } else if (selection_start.vpos >= data[selection_start.hpos].size) {
                // カーソルが行末より下にある場合行末に移動する。
                selection_start.vpos = data[selection_start.hpos].size - 1;
            }
            selection_end = selection_start;
        }
        debug("delete at [[%d, %d], [%d, %d]]\n",
                selection_start.hpos, selection_start.vpos, selection_end.hpos, selection_end.vpos);
        delete_between(selection_start, selection_end);
        cursor_moved(selection_start);
    }
    
    /**
     * 行の折り返し処理を行う。
     * 折り返した結果の行数を返す。
     * 行が空行の場合、1を返す。
     * 行の長さが20文字以下の場合も1を返す。
     * 一回行送りがあると2を返す。以下同順。
     */
    public int wrap_line(int x) {
        // xが全ての行数より大きい場合は何もしない。0を返す。
        if (data.size <= x) {
            return 0;
        }

        // x行目の長さが0の場合、その行を削除する。(ただし最初の行しか残っていない場合は何もしない)
        if (data[x].size == 0) {
            if (data.size == 1 && x == 0) {
                return 0;
            } else if (x == data.size - 1) {
                return 0;
            } else {
                data.remove_at(x);
                return 0;
            }
        }

        // x行目の長さが20文字以内、かつ行末が'\n'の場合は何もしない。        
        if (data[x].size < Y_LENGTH && data[x].get_last().str == "\n") {
            return 0;
        }

        // x行目の行末が'\n'以外の場合はラップ処理を行う。
        var line = new SimpleList<TextElement>();
        line.concat(data[x]);
        data.remove_at(x);

        // x行目に続く行を末尾が'\n'になるまで新しく作成したリストに追加し、一列にする。
        while (x < data.size && line.get_last().str != "\n") {
            line.concat(data[x]);
            // 取り込んだ行は削除する。
            data.remove_at(x);
        }

        int result = 0;
        
        // 新しく作成したリストが20文字を超える場合
        if (line.size >= Y_LENGTH) {
            // 20文字で区切って挿入していく
            var part1 = line;
            var part2 = part1.cut_at(Y_LENGTH);
            data.insert(x, part1);
            int i = 1;
            
            // 以降20文字ずつに区切って挿入を繰り返す。
            while (part2.size >= Y_LENGTH) {
                part1 = part2;
                part2 = part1.cut_at(Y_LENGTH);
                data.insert(x + i, part1);
                i++;
            }
            if (part2.is_empty()) {
                result = i;
            } else {
                data.insert(x + i, part2);
                result = i + 1;
            }
        } else {
            // 新しい行が改行含めて20文字以内に収まる場合は挿入して終わり。
            data.insert(x, line);
            result = 0;
        }
        return result;
    }

    /**
     * 選択範囲を削除する。
     */
    public void delete_selection() {
        delete_between(selection_start, selection_end);
        cursor_moved(selection_end);
    }

    
    /**
     * アンドゥ処理を行う。
     */
    public void undo_history() {
        if (undo_list.size == 0) {
            return;
        }
        var hist_action = undo_list.poll_head();
        switch (hist_action.action_type) {
          case INSERT:
            // 選択範囲のテキストを削除→新たにテキストを挿入、という流れなので、
            // 挿入したテキストを削除→削除したテキストを挿入、を行う。
            delete_between(hist_action.selection_start, selection_end.subtract_offset(1));
            selection_start = hist_action.selection_start;
            selection_end = selection_start;
            insert_text(hist_action.deleted_text);
            break;
          case DELETE:
            // 選択範囲のテキストを削除しただけなので、
            // 削除したテキストの挿入を行う。
            selection_start = hist_action.selection_start;
            selection_end = selection_start;
            insert_text(hist_action.deleted_text);
            break;
        }
        redo_list.offer_head(hist_action);
    }
    
    /**
     * リドゥ処理を行う。
     */
    public void redo_history() {
        if (redo_list.size == 0) {
            return;
        }
        var hist_action = redo_list.poll_head();
        switch (hist_action.action_type) {
          case INSERT:
            selection_start = hist_action.selection_start;
            selection_end = hist_action.selection_end;
            insert_text(hist_action.inserted_text);
            break;
          case DELETE:
            selection_start = hist_action.selection_start;
            selection_end = hist_action.selection_end;
            delete_between(selection_start, selection_end);
            break;
        }
        undo_list.offer_head(hist_action);
    }

    /**
     * 「全て選択」を行う。
     */
    public void select_all() {
        if (data.size == 0) {
            selection_start = { 0, 0 };
            selection_end = { 0, 0 };
        } else {
            selection_start = { 0, 0 };
            if (data.last().size == 0) {
                selection_end = {data.size - 1, 0 };
            } else {
                selection_end = { data.size - 1, data.last().size - 1 };
            }
        }
        cursor_moved(selection_end);
    }
    
    // プライベートメソッド
        
    /**
     * 二つのポジションの間にある文字を削除する。
     * 二つのポジションが同じ位置である場合、一つの文字のみ削除する。
     * 二つのポジションが最終行以降にある場合、何もしない。
     */
    private void delete_between(CellPosition start_pos, CellPosition end_pos) {
        // 選択範囲の二つの点のうち前にあるものをp1、後ろにあるものをp2とする
        CellPosition p1, p2, p3;
        if (start_pos.comp_le(end_pos)) {
            p1 = start_pos;
            p2 = end_pos;
        } else {
            p1 = end_pos;
            p2 = start_pos;
        }
        p3 = p2.add_offset(1);
        
        if (p1.hpos >= data.size) {
            // 選択範囲が最終行以後にある場合は何もせず終了する。
            return;
        }

        //undo_list.start();
        if (p1.comp_eq(p2)) {
            var line = data[p1.hpos];
            if (p1.vpos < line.size) {
                // カーソルが行の末尾より下にある場合は何もしないようにする。
                if (line.size == 1 && p1.hpos > 0) {
                    // 削除するのが行の最後の文字である場合はその行ごと削除する。
                    data.remove_at(p1.hpos);
                } else {
                    // カーソル位置の文字を削除する。
                    line.remove_at(p1.vpos);
                }
            }
        } else if (p1.hpos == p2.hpos) {
            // p1とp2が同じ行にある場合
            var line = data[p1.hpos];
            if (p1.vpos == 0 && p2.vpos >= line.size - 1) {
                if (data.size == 1 && p1.hpos == 0) {
                    line.clear();
                } else {
                    data.remove(line);
                }
            } else if (p1.vpos < line.size) {
                if (edit_mode == DIRECT_INPUT) {
                    p2.self_add_offset(1);
                }
                line.slice_cut(p1.vpos, p2.vpos);
            }
            //undo_list.put(DELETE, piece);
        } else {
            // p1とp2が違う行にある場合
            var line1 = data[p1.hpos];
            if (p1.vpos >= line1.size) {
                p1  = {p1.hpos + 1, 0};
                if (p1.hpos >= data.size) {
                    return;
                } else if (p1.comp_eq(p2)) {
                    delete_between(p1, p2);
                    return;
                }
            }
            // 選択範囲の前の部分に選択範囲の後ろの部分を追加する。
            var part1 = line1;
            var part2 = part1.cut_at(p1.vpos);
            var p4 = p2;
            if (edit_mode == DIRECT_INPUT) {
                p4 = p3;
            }
            if (p4.hpos < data.size) {
                var line2 = data[p4.hpos];
                if (p4.vpos < line2.size) {
                    var part3 = line2;
                    var part4 = part3.cut_at(p4.vpos);
                    part1.concat(part4);
                }
            }
            // 選択範囲の開始と終了の間の行を削除する。
            for (int i = p1.hpos; i <= p4.hpos && p1.hpos < data.size; i++) {
                //undo_list.put(DELETE, data[p1.hpos]);
                data.remove_at(p1.hpos);
            }
            // 切り取り後の行を挿入する。
            data.insert(p1.hpos, part1);
        }
        //undo_list.finish();
        // 行送りを調整する。
        wrap_line(p1.hpos);
        selection_start = p1;
        selection_end = p1;
    }

    /**
     * 文章の一部を作成する処理。
     * 元となる文字列をUTF-8の方式で一文字ずつ分解してTextElementのリストを作る。
     * 改行を含む場合は複数行を作成する。
     */
    private Gee.List<SimpleList<TextElement>> construct_text(string src, EditMode arg_edit_mode = DIRECT_INPUT, WrapMode wrap_mode = NOWRAP,
            bool has_hurigana = false) {
        var result = new Gee.ArrayList<SimpleList<TextElement>>();
        var line = new SimpleList<TextElement>();
        result.add(line);
        if (src.length == 0) {
            return result;
        }
        int offset = 0;
        while (src[offset] != '\0') {
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
        return result;
    }
    
    private bool text_is_newline(Gee.List<SimpleList<TextElement>>? text) {
        if (text != null && text.size == 2 && text[0].size == 1 && text[0][0].str == "\n" && text[1].size == 0) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
     * カーソル位置まで空白か改行文字で埋める。
     * カーソル位置が既存行の末尾以下にある場合は空白で埋める。
     * カーソル位置が最終行より後ろにある場合は改行で埋める。
     */
    private void pad_space(int hpos, int vpos) {
        if (data.size <= hpos) {
            var last_line = data.last();
            if (last_line.size == 0 || (last_line.size < (Y_LENGTH - 1) && last_line.get_last().str != "\n")) {
                last_line.add(new TextElement("\n"));
            }
            while (data.size <= hpos) {
                var new_line = new SimpleList<TextElement>();
                if (data.size < hpos) {
                    new_line.add(new TextElement("\n"));
                }
                data.add(new_line);
            }
        }
        var line = data[hpos];
        if (line.size > 0 && line.get_last().str == "\n") {
            while (line.size <= vpos) {
                // 全角空白を追加する。
                var space = new TextElement("　");
                line.insert(line.size - 1, space);
            }
        } else {
            while (line.size < vpos) {
                // 全角空白を追加する。
                var space = new TextElement("　");
                line.add(space);
            }
        }
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
