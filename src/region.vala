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

public struct Region {
    public CellPosition start;
    public CellPosition last;
    
    public void move_to(CellPosition pos) {
        start = pos;
        last = pos;
    }

    public Region add_hpos(int hpos) {
        var result = this;
        result.start.hpos += hpos;
        result.last.hpos += hpos;
        return result;
    }
    
    public Region subtract_hpos(int hpos) {
        var result = this;
        result.start.hpos -= hpos;
        result.last.hpos -= hpos;
        return result;
    }
    
    public Region asc_order() {
        if (start.comp_eq(last)) {
            return this;
        } else if (start.comp_lt(last)) {
            return this;
        } else {
            return {last, start};
        }
    }

    public Region desc_order() {
        if (start.comp_eq(last)) {
            return this;
        } else if (start.comp_gt(last)) {
            return this;
        } else {
            return {last, start};
        }
    }
    
    public bool contains(CellPosition pos) {
        if (start.comp_eq(last)) {
            return start.comp_eq(pos);
        } else {
            Region reg = asc_order();
            return reg.start.comp_lt(pos) && reg.last.comp_ge(pos);
        }
    }
}
