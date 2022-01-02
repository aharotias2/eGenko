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
    
    // パブリックメソッド
    
    /**
     * デフォルトのコンストラクタ。
     * 空のテキストを作成して保持する。
     */
    public TextModel() {
        undo_list = new History();
        redo_list = new History();
        data = construct_text("", DIRECT_INPUT, NOWRAP);
    }

    /**
     * 文字列を受け取るコンストラクタ。
     * 引数の文字列からテキストを作成して保持する。
     */
    public TextModel.from_string(string src) {
        set_contents(src);
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
        return pos in selection;
    }
    
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
            delete_between(selection);
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
    
    public void set_contents(string new_text) {
        set_contents_async.begin(new_text);
    }
    
    public async void set_contents_async(string new_text) {
        data.clear();
        string[] lines = new_text.split("\n");
        for (int i = 0; i < lines.length; i++) {
            var text_list = construct_text(lines[i], DIRECT_INPUT, WRAP, true);
            if (i < lines.length - 1) {
                text_list.last().add(new TextElement("\n"));
            }
            data.add_all(text_list);
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
        if (selection.start.comp_lt(selection.last)) {
            p1 = selection.start;
            p2 = selection.last;
        } else {
            p1 = selection.last;
            p2 = selection.start;
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
     * 選択範囲がある場合 (selection.startとselection.lastが違う場合)、
     * 選択範囲を削除して挿入する。
     */
    public void insert_string(string src) {
        debug("insert_string(%s)", src);
        // 挿入するテキストを作成する。
        EditMode tmp = DIRECT_INPUT;
        if (edit_mode == PREEDITING) {
            selection.start = preedit.start;
            selection.last = preedit.last;
            tmp = edit_mode;
        }
        
        debug("insert_string (%s) at [[%d, %d], [%d, %d]]\n",
                src, selection.start.hpos, selection.start.vpos,
                selection.last.hpos, selection.last.vpos);

        var new_text = construct_text(src, DIRECT_INPUT, NOWRAP);
        undo_list.new_action();
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
        undo_list.push_action(INSERT, selection.start, selection.last, text);
    }

    public void insert_text(Gee.List<SimpleList<TextElement>> new_piece) {
        // 選択範囲の二つの点のうち前にあるものをp1、後ろにあるものをp2とする
        Region region = selection.adjust();

        // 選択範囲内の文字列を削除する。
        if (!region.start.comp_eq(region.last)) {
            debug("insert_text go into delete selection");
            delete_between(selection);
            debug("insert_text come back from delete selection");
        }
        
        selection.move_to(region.start);

        // 選択範囲の先頭が行末より下にある場合、空白文字で埋める。
        if (region.start.hpos >= data.size || region.start.vpos >= data[region.start.hpos].size) {
            pad_space(region.start.hpos, region.start.vpos);
        }
        
        var line = data[region.start.hpos];
        
        if (text_is_newline(new_piece)) {
            debug("insert a newline");
            // 改行を挿入する
            if (region.start.vpos < line.size) {
                var new_line = line.cut_at(region.start.vpos);
                line.add(new TextElement("\n"));
                data.insert(region.start.hpos + 1, new_line);
                CellPosition new_pos = {region.start.hpos + 1, 0};
                debug("new pos = [%d, %d]", new_pos.hpos, new_pos.vpos);
                set_cursor(new_pos);
            } else {
                CellPosition new_pos = {region.start.hpos + 1, 0};
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
            line.insert_all(region.start.vpos, new_piece[0]);
            if (data[region.start.hpos].size >= Y_LENGTH) {
                wrap_line(region.start.hpos);
            }

            // カーソルを挿入した文字列の末尾の位置に移動する。
            selection.start = region.start.add_offset(new_piece_size);
        } else {
            debug("insert multiple lines");
            int new_piece_last_size = new_piece.last().size;
            // 複数行挿入する場合は一行ずつ処理をする。
            if (region.start.vpos == 0) {
                if (line.size > 0) {
                    new_piece.last().concat(line);
                }
            } else if (region.start.vpos >= line.size) {
                new_piece.first().insert_all(0, line);
            } else {
                var part1 = line;
                var part2 = part1.cut_at(region.start.vpos);
                new_piece[0].insert_all(0, part1);
                new_piece.last().concat(part2);
            }

            data.remove_at(region.start.hpos);

            int n_lines = 0;
            for (int i = new_piece.size - 1; i >= 0; i--) {
                data.insert(region.start.hpos, new_piece[i]);
                n_lines += wrap_line(region.start.hpos);
            }

            // カーソルを挿入した文字列の末尾の位置に移動する。
            selection.start = {
                region.start.hpos + n_lines,
                new_piece_last_size % Y_LENGTH
            };
        }
        
        selection.last = selection.start;
        cursor_moved(selection.last);
    }
    
    /**
     * プリエディットの開始時の処理。
     * プリエディットの範囲を選択範囲の開始点と同じにする。
     */
    public void start_preedit() {
        debug("start_preedit");
        preedit.move_to(selection.start);
        edit_mode = PREEDITING;
    }

    /**
     * プリエディットの終了処理。
     * 始点と終点をクリアする。
     */
    public void end_preedit() {
        debug("end_preedit");
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

        selection.start = preedit.start;
        selection.last = preedit.last;
        debug("preedit_changed (%s) at [[%d, %d], [%d, %d]]\n",
                preedit_string, selection.start.hpos, selection.start.vpos,
                selection.last.hpos, selection.last.vpos);

        var preedit_text = construct_text(preedit_string, PREEDITING, NOWRAP);
        var preedit_size = preedit_text[0].size;

        insert_text(preedit_text);
        
        preedit.last = preedit.start.add_offset(preedit_size);
        selection.start = preedit.start;
        selection.last = preedit.last;
        cursor_moved(preedit.last);
    }

    /**
     * 文字を削除する。
     */
    public void delete_char() {
        delete_between(selection);
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
                selection.start.hpos = data.size - 1;
                selection.start.vpos = data[selection.start.hpos].size;
                selection.last = selection.start;
                cursor_moved(selection.start);
                return;
            } else if (selection.start.vpos >= data[selection.start.hpos].size) {
                // カーソルが行末より下にある場合行末に移動する。
                selection.start.vpos = data[selection.start.hpos].size - 1;
            }
            selection.last = selection.start;
        }
        debug("delete at [[%d, %d], [%d, %d]]\n",
                selection.start.hpos, selection.start.vpos, selection.last.hpos, selection.last.vpos);
        delete_between(selection);
        cursor_moved(selection.start);
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
        delete_between(selection);
        cursor_moved(selection.last);
    }

    
    /**
     * アンドゥ処理を行う。
     */
    public void undo_history() {
    }
    
    /**
     * リドゥ処理を行う。
     */
    public void redo_history() {
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
     * 二つのポジションの間にある文字を削除する。
     * 二つのポジションが同じ位置である場合、一つの文字のみ削除する。
     * 二つのポジションが最終行以降にある場合、何もしない。
     */
    private void delete_between(Region region) {
        // 選択範囲の二つの点のうち前にあるものをregion.start、後ろにあるものをregion.lastとする
        region = region.adjust();
        CellPosition p3 = region.last.add_offset(1);
        
        if (region.start.hpos >= data.size) {
            // 選択範囲が最終行以後にある場合は何もせず終了する。
            return;
        }

        //undo_list.start();
        if (region.start.comp_eq(region.last)) {
            var line = data[region.start.hpos];
            if (region.start.vpos < line.size) {
                // カーソルが行の末尾より下にある場合は何もしないようにする。
                if (line.size == 1 && region.start.hpos > 0) {
                    // 削除するのが行の最後の文字である場合はその行ごと削除する。
                    data.remove_at(region.start.hpos);
                } else {
                    // カーソル位置の文字を削除する。
                    line.remove_at(region.start.vpos);
                }
            }
        } else if (region.start.hpos == region.last.hpos) {
            // region.startとregion.lastが同じ行にある場合
            var line = data[region.start.hpos];
            if (region.start.vpos == 0 && region.last.vpos >= line.size - 1) {
                if (data.size == 1 && region.start.hpos == 0) {
                    line.clear();
                } else {
                    data.remove(line);
                }
            } else if (region.start.vpos < line.size) {
                if (edit_mode == DIRECT_INPUT) {
                    region.last.self_add_offset(1);
                }
                line.slice_cut(region.start.vpos, region.last.vpos);
            }
            //undo_list.put(DELETE, piece);
        } else {
            // region.startとregion.lastが違う行にある場合
            var line1 = data[region.start.hpos];
            if (region.start.vpos >= line1.size) {
                region.start  = {region.start.hpos + 1, 0};
                if (region.start.hpos >= data.size) {
                    return;
                } else if (region.start.comp_eq(region.last)) {
                    delete_between(region);
                    return;
                }
            }
            // 選択範囲の前の部分に選択範囲の後ろの部分を追加する。
            var part1 = line1;
            var part2 = part1.cut_at(region.start.vpos);
            var p4 = region.last;
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
            for (int i = region.start.hpos; i <= p4.hpos && region.start.hpos < data.size; i++) {
                //undo_list.put(DELETE, data[region.start.hpos]);
                data.remove_at(region.start.hpos);
            }
            // 切り取り後の行を挿入する。
            data.insert(region.start.hpos, part1);
        }
        //undo_list.finish();
        // 行送りを調整する。
        wrap_line(region.start.hpos);
        selection.move_to(region.start);
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
