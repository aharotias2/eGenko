/*
 * This file is part of eGenko.
 *
 *     eGenko is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     eGenko is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with eGenko.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright 2022 Takayuki Tanaka
 */

public class FocusList : Object {
    private class Element : Object {
        public Gtk.Widget? widget;
        public Element? next;
        public unowned Element? prev;
    }
    
    private unowned Element? current;
    
    private Element? root;
    
    public FocusList() {
        root = new Element();
    }

    private unowned Element get_last_element() {
        unowned Element iter = root;
        while (iter.next != null) {
            iter = iter.next;
        }
        return iter;
    }
    
    public void reset_focus() {
        unowned Element iter = root.next;
        while (iter != null) {
            if (iter.widget.is_focus) {
                current = iter;
                return;
            } else {
                if (widget_can_focus(iter.widget)) {
                    iter.widget.grab_focus();
                    if (iter.widget.has_visible_focus()) {
                        current = iter;
                        return;
                    }
                }
                iter = iter.next;
            }
        }
    }
        
    public void move_focus_foreward() {
        if (root.next == null || current == null) {
            return;
        }
        unowned Element iter = current;
        do {
            if (iter.next == null) {
                iter = root.next;
            } else {
                iter = iter.next;
            }
            if (widget_can_focus(iter.widget)) {
                iter.widget.grab_focus();
                if (iter.widget.has_visible_focus()) {
                    current = iter;
                    return;
                }
            }
        } while (iter != current);
    }

    public void move_focus_backward() {
        if (root.next == null || current == null) {
            return;
        }
        unowned Element iter = current;
        do {
            if (iter.prev == root) {
                iter = get_last_element();
            } else {
                iter = iter.prev;
            }
            if (widget_can_focus(iter.widget)) {
                iter.widget.grab_focus();
                if (iter.widget.has_visible_focus()) {
                    current = iter;
                    return;
                }
            }
        } while (iter != current);
    }
        
    public void append_widget(Gtk.Widget widget) {
        if (root.next == null) {
            root.next = new Element();
            root.next.widget = widget;
            root.next.prev = root;
            current = root.next;
        } else {
            Element last_element = get_last_element();
            last_element.next = new Element();
            last_element.next.widget = widget;
            last_element.next.prev = last_element;
            last_element.next.next = null;
        }
        widget.focus_in_event.connect((direction) => handle_on_focus(widget));
    }
    
    public void insert_widget(uint index, Gtk.Widget widget) {
        unowned Element iter = root;
        uint i = 0;
        while (i < index && iter.next != null) {
            iter = iter.next;
        }
        Element new_element = new Element();
        new_element.widget = widget;
        new_element.next = iter.next;
        new_element.prev = iter;
        iter.next = new_element;
        widget.focus_in_event.connect((direction) => handle_on_focus(widget));
    }
    
    public void set_focus(Gtk.Widget widget) {
        unowned Element iter = root;
        while (iter.next != null) {
            if (iter.next.widget == widget) {
                widget.grab_focus();
                current = iter.next;
                return;
            } else {
                iter = iter.next;
            }
        }
    }
    
    private bool widget_can_focus(Gtk.Widget w) {
        return w.get_realized() && w.can_focus && w.visible;
    }
    
    private bool handle_on_focus(Gtk.Widget widget) {
        unowned Element iter = root;
        while (iter.next != null) {
            if (iter.next.widget == widget) {
                current = iter.next;
                break;
            } else {
                iter = iter.next;
            }
        }
        return false;
    }
}
