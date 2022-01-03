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

public class InsertTextAction : AbstractEditAction {
    private unowned Gee.List<SimpleList<TextElement>> text;
    private Region before_selection;
    private Region after_selection;
    private Region before_local_selection;
    private Region after_local_selection;
    private Region before_paragraph_region;
    private Region after_paragraph_region;
    private Gee.List<SimpleList<TextElement>> before_text;
    private Gee.List<SimpleList<TextElement>> after_text;
    
    public InsertTextAction(Gee.List<SimpleList<TextElement>> text, Region selection,
            Gee.List<SimpleList<TextElement>> text_piece, EditMode edit_mode) {
        this.text = text;
        this.before_selection = selection;
        before_paragraph_region = paragraph_containing_region(this.text, before_selection);
        before_local_selection = selection.subtract_hpos(before_paragraph_region.start.hpos);
        before_text = copy_paragraphs(this.text, before_paragraph_region);
        after_text = text_copy_all(before_text);
        after_local_selection = insert_text(after_text, before_local_selection, text_piece, edit_mode);
        after_selection = after_local_selection.add_hpos(before_paragraph_region.start.hpos);
        after_paragraph_region = {
            {before_paragraph_region.start.hpos, 0},
            {before_paragraph_region.start.hpos + after_text.size, 0}
        };
    }
    
    public override Region perform() {
        text.remove_all(text[before_paragraph_region.start.hpos:before_paragraph_region.last.hpos]);
        text.insert_all(after_paragraph_region.start.hpos, after_text);
        return after_selection;
    }
    
    public override Region undo() {
        text.remove_all(text[after_paragraph_region.start.hpos:after_paragraph_region.last.hpos]);
        text.insert_all(before_paragraph_region.start.hpos, before_text);
        return before_selection;
    }
}
