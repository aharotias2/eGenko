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
 * Copyright 2022 Takayuki Tanaka
 */

namespace EditActionUtils {

    public Gee.List<SimpleList<TextElement>> text_copy_all(Gee.List<SimpleList<TextElement>> src) {
        var dest = new Gee.ArrayList<SimpleList<TextElement>>();
        foreach (var line in src) {
            dest.add(line.copy_all());
        }
        return dest;
    }

    /**
     * 行の折り返し処理を行う。
     * 折り返した結果の行数を返す。
     * 行が空行の場合、1を返す。
     * 行の長さが20文字以下の場合も1を返す。
     * 一回行送りがあると2を返す。以下同順。
     */
    public int wrap_line(Gee.List<SimpleList<TextElement>> text, int x)
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
    public void pad_space(Gee.List<SimpleList<TextElement>> text, CellPosition pos)
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
    public bool text_is_newline(Gee.List<SimpleList<TextElement>>? text) {
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
