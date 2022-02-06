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

public struct CellPosition {
    public int hpos;
    public int vpos;
    
    public bool comp_gt(CellPosition p) {
        return (hpos > p.hpos || (hpos == p.hpos && vpos > p.vpos));
    }
    
    public bool comp_eq(CellPosition p) {
        return (hpos == p.hpos && vpos == p.vpos);
    }
    
    public bool comp_lt(CellPosition p) {
        return (hpos < p.hpos || (hpos == p.hpos && vpos < p.vpos));
    }
    
    public bool comp_ge(CellPosition p) {
        return comp_eq(p) || comp_gt(p);
    }
    
    public bool comp_le(CellPosition p) {
        return comp_eq(p) || comp_lt(p);
    }
    
    public CellPosition add_offset(int offset) {
        return CellPosition() {
            hpos = hpos + (vpos + offset) / Y_LENGTH,
            vpos = (vpos + offset) % Y_LENGTH
        };
    }
    
    public void self_add_offset(int offset) {
        var tmp = add_offset(offset);
        hpos = tmp.hpos;
        vpos = tmp.vpos;
    }
    
    public CellPosition add(CellPosition p) {
        return CellPosition() {
            hpos = hpos + p.hpos + (vpos + p.vpos) / Y_LENGTH,
            vpos = (vpos + p.vpos) % Y_LENGTH
        };
    }
    
    public void self_add(CellPosition p) {
        var tmp = this.add(p);
        hpos = tmp.hpos;
        vpos = tmp.vpos;
    }
    
    public CellPosition subtract_offset(int offset) {
        if (vpos >= offset) {
            return CellPosition() {
                hpos = hpos,
                vpos = vpos - offset
            };
        } else {
            var result = CellPosition() {
                hpos = hpos - ((vpos - offset).abs() / Y_LENGTH + 1),
                vpos = Y_LENGTH - (vpos - offset).abs() % Y_LENGTH
            };
            if (result.hpos < 0) {
                return { 0, 0 };
            } else {
                return result;
            }
        }
    }
    
    public void self_subtract_offset(int offset) {
        var tmp = subtract_offset(offset);
        hpos = tmp.hpos;
        vpos = tmp.vpos;
    }
    
    public CellPosition subtract(CellPosition p) {
        var result = subtract_offset(p.vpos);
        result.hpos = result.hpos - p.hpos;
        if (result.hpos < 0) {
            return {0, 0};
        } else {
            return result;
        }
    }
    
    public void self_subtract(CellPosition p) {
        var tmp = subtract(p);
        hpos = tmp.hpos;
        vpos = tmp.vpos;
    }
}
