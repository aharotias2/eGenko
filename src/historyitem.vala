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

public class HistoryItem : Object {
    public Gee.List<Gee.List<TextElement>>? inserted_text { get; private set; }
    public Gee.List<Gee.List<TextElement>>? deleted_text { get; private set; }
    public CellPosition selection_start { get; private set; }
    public CellPosition selection_end { get; private set; }
    public ActionType action_type { get; private set; }
    public HistoryItem(ActionType action_type, Gee.List<Gee.List<TextElement>>? inserted_text, Gee.List<Gee.List<TextElement>>? deleted_text,
            CellPosition selection_start, CellPosition selection_end) {
        this.action_type = action_type;
        this.inserted_text = inserted_text;
        this.deleted_text = deleted_text;
        this.selection_start = selection_start;
        this.selection_end = selection_end;
    }
}

