public class History : Object {
    private Gee.Deque<Gee.Deque<HistoryItem>> data;
    
    public History() {
        data = new Gee.ArrayQueue<Gee.Deque<HistoryItem>>();
    }
    
    public bool has_history() {
        return data.size > 0;
    }
    
    public void new_action() {
        data.offer_head(new Gee.ArrayQueue<HistoryItem>());
    }
    
    public void push_action(ActionType type, CellPosition selection_start, CellPosition selection_end, Gee.List<SimpleList<TextElement>> text) {
        data.peek_head().offer_head(new HistoryItem(type, selection_start, selection_end, text));
    }

    public Gee.Deque<HistoryItem> pop_action() {
        return data.poll_head();
    }
    
    public void append_line(SimpleList<TextElement> text_line) {
        var list = new Gee.ArrayList<SimpleList<TextElement>>();
        //list.add(text_line.copy_all());
        data.poll_head().offer_head(new HistoryItem(APPEND_LINE, {-1, -1}, {-1, -1}, list));
    }
    
    public bool next() {
        if (data.size > 0 && data.peek_head().size > 0) {
            return true;
        } else {
            if (data.size > 0) {
                data.poll_head();
            }
            return false;
        }
    }
    
    public new HistoryItem get() {
        return data.peek_head().poll_head();
    }

    public void retrieve_one_action(History other_history)
      requires (other_history.has_history()) {
        data.offer_head(other_history.pop_action());
    }
}
