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

public abstract class AbstractEditAction : EditAction, Object {
    public abstract Region perform();
    public abstract Region undo();
    public virtual Region redo() { return perform(); }
    
    protected static Gee.List<SimpleList<TextElement>> copy_paragraphs(Gee.List<SimpleList<TextElement>> text,
            Region paragraph_region) {
        var result = new Gee.ArrayList<SimpleList<TextElement>>();
        for (int i = paragraph_region.start.hpos; i < paragraph_region.last.hpos; i++) {
            result.add(text[i].copy_all());
        }
        return result;
    }

    protected static Region paragraph_containing_region(Gee.List<SimpleList<TextElement>> text, Region region) 
            requires(text.size > 0) {
        region = region.asc_order();
        var result = Region();
        if (region.start.hpos < text.size) {
            result.start = {region.start.hpos, 0};
        } else {
            result.start = {text.size - 1, 0};
        }
        if (region.last.hpos == text.size - 1) {
            result.last = {text.size, 0};
        } else if (region.last.hpos >= text.size) {
            result.last = {text.size, 0};
        } else {
            for (result.last = {region.last.hpos + 1, 0};;) {
                if (result.last.hpos == text.size - 1) {
                    result.last.hpos++;
                    break;
                } else if (text[result.last.hpos].get_last().str == "\n") {
                    result.last.hpos++;
                    break;
                } else {
                    result.last.hpos++;
                }
            }
        }
        return result;
    }
    
    protected static Gee.List<SimpleList<TextElement>> text_copy_all(Gee.List<SimpleList<TextElement>> src) {
        var dest = new Gee.ArrayList<SimpleList<TextElement>>();
        foreach (var line in src) {
            dest.add(line.copy_all());
        }
        return dest;
    }
    
    protected static Region insert_text(Gee.List<SimpleList<TextElement>> text, Region selection,
            Gee.List<SimpleList<TextElement>> text_piece, EditMode edit_mode)
            requires(text.size > 0) {
        // 選択範囲の二つの点のうち前にあるものをp1、後ろにあるものをp2とする
        Region region = selection.asc_order();

        // 選択範囲内の文字列を削除する。
        if (!region.start.comp_eq(region.last)) {
            debug("insert_text go into delete region");
            delete_region(text, region, edit_mode);
            debug("insert_text come back from delete region");
        }
        
        region.move_to(region.start);

        // 選択範囲の先頭が行末より下にある場合、空白文字で埋める。
        if (region.start.hpos >= text.size || region.start.vpos >= text[region.start.hpos].size) {
            pad_space(text, region.start);
        }
        
        var line = text[region.start.hpos];
        
        if (text_is_newline(text_piece)) {
            debug("insert a newline");
            // 改行を挿入する
            if (region.start.vpos < line.size) {
                var new_line = line.cut_at(region.start.vpos);
                line.add(new TextElement("\n"));
                text.insert(region.start.hpos + 1, new_line);
                CellPosition new_pos = {region.start.hpos + 1, 0};
                debug("new pos = [%d, %d]", new_pos.hpos, new_pos.vpos);
                wrap_line(text, new_pos.hpos);
                region.move_to(new_pos);
            } else {
                line.add(new TextElement("\n"));
                CellPosition new_pos = {region.start.hpos + 1, 0};
                debug("new pos = [%d, %d]", new_pos.hpos, new_pos.vpos);
                region.move_to(new_pos);
                pad_space(text, new_pos);
                wrap_line(text, new_pos.hpos);
            }
            return region;
        // 新しい文字列を追加する。
        } else if (text_piece.size == 1) {
            debug("insert a single line");
            // 挿入する文字列が一行の場合は単純に挿入して行折り返し処理をする。
            int text_piece_size = text_piece[0].size;
            line.insert_all(region.start.vpos, text_piece[0]);
            if (text[region.start.hpos].size >= Y_LENGTH) {
                wrap_line(text, region.start.hpos);
            }

            // カーソルを挿入した文字列の末尾の位置に移動する。
            region.start = region.start.add_offset(text_piece_size);
            region.last = region.start;
        } else {
            debug("insert multiple lines");
            int text_piece_last_size = text_piece.last().size;
            // 複数行挿入する場合は一行ずつ処理をする。
            if (region.start.vpos == 0) {
                if (line.size > 0) {
                    text_piece.last().concat(line);
                }
            } else if (region.start.vpos >= line.size) {
                text_piece.first().insert_all(0, line);
            } else {
                var part1 = line;
                var part2 = part1.cut_at(region.start.vpos);
                text_piece[0].insert_all(0, part1);
                text_piece.last().concat(part2);
            }

            text.remove_at(region.start.hpos);

            int n_lines = 0;
            for (int i = text_piece.size - 1; i >= 0; i--) {
                text.insert(region.start.hpos, text_piece[i]);
                n_lines += wrap_line(text, region.start.hpos);
            }

            // カーソルを挿入した文字列の末尾の位置に移動する。
            region.start = {
                region.start.hpos + n_lines,
                text_piece_last_size % Y_LENGTH
            };
            region.last = region.start;
        }
        return region;
    }

    protected static Region delete_region(Gee.List<SimpleList<TextElement>> text,
            Region region, EditMode edit_mode)
            requires(text.size > 0) {
        // 選択範囲の二つの点のうち前にあるものをregion.start、後ろにあるものをregion.lastとする
        region = region.asc_order();
        CellPosition p3 = region.last.add_offset(1);
        
        if (region.start.hpos >= text.size) {
            // 選択範囲が最終行以後にある場合は何もせず終了する。
            return region;
        }

        if (region.start.comp_eq(region.last)) {
            var line = text[region.start.hpos];
            if (region.start.vpos < line.size) {
                // カーソルが行の末尾より下にある場合は何もしないようにする。
                if (line.size == 1 && region.start.hpos > 0) {
                    // 削除するのが行の最後の文字である場合はその行ごと削除する。
                    text.remove_at(region.start.hpos);
                } else {
                    // カーソル位置の文字を削除する。
                    line.remove_at(region.start.vpos);
                }
            }
        } else if (region.start.hpos == region.last.hpos) {
            // region.startとregion.lastが同じ行にある場合
            var line = text[region.start.hpos];
            if (region.start.vpos == 0 && region.last.vpos >= line.size - 1) {
                if (text.size == 1 && region.start.hpos == 0) {
                    line.clear();
                } else {
                    text.remove(line);
                }
            } else if (region.start.vpos < line.size) {
                if (edit_mode == DIRECT_INPUT) {
                    region.last.self_add_offset(1);
                }
                line.slice_cut(region.start.vpos, region.last.vpos);
            }
        } else {
            // region.startとregion.lastが違う行にある場合
            var line1 = text[region.start.hpos];
            if (region.start.vpos >= line1.size) {
                region.start  = {region.start.hpos + 1, 0};
                if (region.start.hpos >= text.size) {
                    return region;
                } else if (region.start.comp_eq(region.last)) {
                    delete_region(text, region, edit_mode);
                    return region;
                }
            }
            // 選択範囲の前の部分に選択範囲の後ろの部分を追加する。
            var part1 = line1;
            part1.cut_at(region.start.vpos); // 戻り値は使わないので捨てる。
            var p4 = region.last;
            if (edit_mode == DIRECT_INPUT) {
                p4 = p3;
            }
            if (p4.hpos < text.size) {
                var line2 = text[p4.hpos];
                if (p4.vpos < line2.size) {
                    var part3 = line2;
                    var part4 = part3.cut_at(p4.vpos);
                    part1.concat(part4);
                }
            }
            // 選択範囲の開始と終了の間の行を削除する。
            for (int i = region.start.hpos; i <= p4.hpos && region.start.hpos < text.size; i++) {
                text.remove_at(region.start.hpos);
            }
            // 切り取り後の行を挿入する。
            text.insert(region.start.hpos, part1);
        }
        // 行送りを調整する。
        wrap_line(text, region.start.hpos);
        region.move_to(region.start);
        return region;
    }
    
    /**
     * 行の折り返し処理を行う。
     * 折り返した結果の行数を返す。
     * 行が空行の場合、1を返す。
     * 行の長さが20文字以下の場合も1を返す。
     * 一回行送りがあると2を返す。以下同順。
     */
    protected static int wrap_line(Gee.List<SimpleList<TextElement>> text, int x)
            requires(text.size > 0) {
        // xが全ての行数より大きい場合は何もしない。0を返す。
        if (text.size <= x) {
            return 0;
        }

        // x行目の長さが0の場合、その行を削除する。(ただし最初の行しか残っていない場合は何もしない)
        if (text[x].size == 0) {
            if (text.size == 1 && x == 0) {
                return 0;
            } else if (x == text.size - 1) {
                return 0;
            } else {
                text.remove_at(x);
                return 0;
            }
        }

        // x行目の長さが20文字以内、かつ行末が'\n'の場合は何もしない。        
        if (text[x].size < Y_LENGTH && text[x].get_last().str == "\n") {
            return 0;
        }

        // x行目の行末が'\n'以外の場合はラップ処理を行う。
        var line = new SimpleList<TextElement>();
        line.concat(text[x]);
        text.remove_at(x);

        // x行目に続く行を末尾が'\n'になるまで新しく作成したリストに追加し、一列にする。
        while (x < text.size && line.get_last().str != "\n") {
            line.concat(text[x]);
            // 取り込んだ行は削除する。
            text.remove_at(x);
        }

        int result = 0;
        
        // 新しく作成したリストが20文字を超える場合
        if (line.size >= Y_LENGTH) {
            // 20文字で区切って挿入していく
            var part1 = line;
            var part2 = part1.cut_at(Y_LENGTH);
            text.insert(x, part1);
            int i = 1;
            
            // 以降20文字ずつに区切って挿入を繰り返す。
            while (part2.size >= Y_LENGTH) {
                part1 = part2;
                part2 = part1.cut_at(Y_LENGTH);
                text.insert(x + i, part1);
                i++;
            }
            if (part2.is_empty()) {
                result = i;
            } else {
                text.insert(x + i, part2);
                result = i + 1;
            }
        } else {
            // 新しい行が改行含めて20文字以内に収まる場合は挿入して終わり。
            text.insert(x, line);
            result = 0;
        }
        return result;
    }

    /**
     * カーソル位置まで空白か改行文字で埋める。
     * カーソル位置が既存行の末尾以下にある場合は空白で埋める。
     * カーソル位置が最終行より後ろにある場合は改行で埋める。
     */
    protected static void pad_space(Gee.List<SimpleList<TextElement>> text, CellPosition pos)
            requires(text.size > 0) {
        if (text.size <= pos.hpos) {
            var last_line = text.last();
            if (last_line.size == 0 || (last_line.size < (Y_LENGTH - 1) && last_line.get_last().str != "\n")) {
                last_line.add(new TextElement("\n"));
            }
            while (text.size <= pos.hpos) {
                var new_line = new SimpleList<TextElement>();
                if (text.size < pos.hpos) {
                    new_line.add(new TextElement("\n"));
                }
                text.add(new_line);
            }
        }
        var line = text[pos.hpos];
        if (line.size > 0 && line.get_last().str == "\n") {
            while (line.size <= pos.vpos) {
                // 全角空白を追加する。
                var space = new TextElement("　");
                line.insert(line.size - 1, space);
            }
        } else {
            while (line.size < pos.vpos) {
                // 全角空白を追加する。
                var space = new TextElement("　");
                line.add(space);
            }
        }
    }

    /**
     * construct_textメソッドによって生成された、
     * 改行文字のみを含むオブジェクトであることを判定する。
     */    
    protected static bool text_is_newline(Gee.List<SimpleList<TextElement>>? text) {
        if (text != null
                && text.size == 2
                && text[0].size == 1
                && text[0][0].str == "\n"
                && text[1].size == 0) {
            return true;
        } else {
            return false;
        }
    }
}
