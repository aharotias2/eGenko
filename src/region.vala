public struct Region {
    public CellPosition start;
    public CellPosition last;
    
    public void move_to(CellPosition pos) {
        start = pos;
        last = pos;
    }
    
    public Region adjust() {
        if (start.comp_eq(last)) {
            return this;
        } else if (start.comp_lt(last)) {
            return this;
        } else {
            return {last, start};
        }
    }
    
    public bool contains(CellPosition pos) {
        if (start.comp_eq(last)) {
            return start.comp_eq(pos);
        } else {
            Region reg = adjust();
            return reg.start.comp_lt(pos) && reg.last.comp_ge(pos);
        }
    }
}
