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

public class DeleteRegionAction : AbstractEditAction {
    private EditMode edit_mode;
    
    public DeleteRegionAction(Gee.List<SimpleList<TextElement>> text, Region selection, EditMode edit_mode) {
        base(text, selection);
        this.edit_mode = edit_mode;
    }

    protected override Region process_text(Gee.List<SimpleList<TextElement>> text_before,
            Region local_selection_before, out Gee.List<SimpleList<TextElement>> text_after) {
        text_after = EditActionUtils.text_copy_all(text_before);
        // 選択範囲の二つの点のうち前にあるものをregion.start、後ろにあるものをregion.lastとする
        Region region = local_selection_before.asc_order();
        CellPosition p3 = region.last.add_offset(1);

        if (region.start.hpos >= text_after.size) {
            // 選択範囲が最終行以後にある場合は何もせず終了する。
            return region;
        }

        if (region.start.comp_eq(region.last)) {
            var line = text_after[region.start.hpos];
            if (region.start.vpos < line.size) {
                // カーソルが行の末尾より下にある場合は何もしないようにする。
                if (line.size == 1 && region.start.hpos > 0) {
                    // 削除するのが行の最後の文字である場合はその行ごと削除する。
                    text_after.remove_at(region.start.hpos);
                } else {
                    // カーソル位置の文字を削除する。
                    line.remove_at(region.start.vpos);
                }
            }
        } else if (region.start.hpos == region.last.hpos) {
            // region.startとregion.lastが同じ行にある場合
            var line = text_after[region.start.hpos];
            if (region.start.vpos == 0 && region.last.vpos >= line.size - 1) {
                if (text_after.size == 1 && region.start.hpos == 0) {
                    line.clear();
                } else {
                    text_after.remove(line);
                }
            } else if (region.start.vpos < line.size) {
                if (edit_mode == DIRECT_INPUT) {
                    region.last.self_add_offset(1);
                }
                line.slice_cut(region.start.vpos, region.last.vpos);
            }
        } else {
            // region.startとregion.lastが違う行にある場合
            var line1 = text_after[region.start.hpos];
            if (region.start.vpos >= line1.size) {
                region.start  = {region.start.hpos + 1, 0};
                if (region.start.hpos >= text_after.size) {
                    return region;
                } else if (region.start.comp_eq(region.last)) {
                    process_text(text_before, region, out text_after);
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
            if (p4.hpos < text_after.size) {
                var line2 = text_after[p4.hpos];
                if (p4.vpos < line2.size) {
                    var part3 = line2;
                    var part4 = part3.cut_at(p4.vpos);
                    part1.concat(part4);
                }
            }
            // 選択範囲の開始と終了の間の行を削除する。
            for (int i = region.start.hpos; i <= p4.hpos && region.start.hpos < text_after.size; i++) {
                text_after.remove_at(region.start.hpos);
            }
            // 切り取り後の行を挿入する。
            text_after.insert(region.start.hpos, part1);
        }
        // 行送りを調整する。
        EditActionUtils.wrap_line(text_after, region.start.hpos);
        region.move_to(region.start);
        return region;
    }
}
