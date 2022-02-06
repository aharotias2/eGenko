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

public class InsertTextAction : AbstractEditAction {
    private EditMode edit_mode;
    private Gee.List<SimpleList<TextElement>> text_piece;

    public InsertTextAction(Gee.List<SimpleList<TextElement>> text, Region selection,
            Gee.List<SimpleList<TextElement>> text_piece, EditMode edit_mode) {
        base(text, selection);
        this.text_piece = text_piece;
        this.edit_mode = edit_mode;
    }

    protected override Region process_text(Gee.List<SimpleList<TextElement>> text_before,
            Region local_selection_before, out Gee.List<SimpleList<TextElement>> text_after) {
        assert(text_before.size > 0);
        text_after = EditActionUtils.text_copy_all(text_before);
        // 選択範囲の二つの点のうち前にあるものをp1、後ろにあるものをp2とする
        Region region = local_selection_before.asc_order();

        region.move_to(region.start);

        // 選択範囲の先頭が行末より下にある場合、空白文字で埋める。
        if (region.start.hpos >= text_after.size || region.start.vpos >= text_after[region.start.hpos].size) {
            EditActionUtils.pad_space(text_after, region.start);
        }

        var line = text_after[region.start.hpos];

        if (EditActionUtils.text_is_newline(text_piece)) {
            debug("insert a newline");
            // 改行を挿入する
            if (region.start.vpos < line.size) {
                var new_line = line.cut_at(region.start.vpos);
                line.add(new TextElement("\n"));
                text_after.insert(region.start.hpos + 1, new_line);
                CellPosition new_pos = {region.start.hpos + 1, 0};
                debug("new pos = [%d, %d]", new_pos.hpos, new_pos.vpos);
                EditActionUtils.wrap_line(text_after, new_pos.hpos);
                region.move_to(new_pos);
            } else {
                line.add(new TextElement("\n"));
                CellPosition new_pos = {region.start.hpos + 1, 0};
                debug("new pos = [%d, %d]", new_pos.hpos, new_pos.vpos);
                region.move_to(new_pos);
                EditActionUtils.pad_space(text_after, new_pos);
                EditActionUtils.wrap_line(text_after, new_pos.hpos);
            }
            return region;
        // 新しい文字列を追加する。
        } else if (text_piece.size == 1) {
            debug("insert a single line");
            // 挿入する文字列が一行の場合は単純に挿入して行折り返し処理をする。
            int text_piece_size = text_piece[0].size;
            line.insert_all(region.start.vpos, text_piece[0]);
            if (text_after[region.start.hpos].size >= Y_LENGTH) {
                EditActionUtils.wrap_line(text_after, region.start.hpos);
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

            text_after.remove_at(region.start.hpos);

            int n_lines = 0;
            for (int i = text_piece.size - 1; i >= 0; i--) {
                text_after.insert(region.start.hpos, text_piece[i]);
                n_lines += EditActionUtils.wrap_line(text_after, region.start.hpos);
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
}
