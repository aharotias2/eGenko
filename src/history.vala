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

public class History : Object {
    private Gee.Deque<Gee.LinkedList<EditAction>> data;
    
    public History() {
        data = new Gee.ArrayQueue<Gee.LinkedList<EditAction>>();
    }
    
    public bool has_history() {
        return data.size > 0;
    }
    
    public Gee.LinkedList<EditAction> new_edit_action() {
        var new_action_list = new Gee.LinkedList<EditAction>();
        data.offer_tail(new_action_list);
        return new_action_list;
    }

    public Gee.LinkedList<EditAction> get_last_action() {
        return data.peek_tail();
    }
        
    public void push_action(Gee.LinkedList<EditAction> action_list) {
        data.offer_tail(action_list);
    }

    public Gee.LinkedList<EditAction> pop_action() {
        return data.poll_tail();
    }
    
    public void clear() {
        data.clear();
    }
}
