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

public class GenkoyoshiAppWindow : Gtk.ApplicationWindow {
    public signal void require_quit();
    public signal void require_open_file();
    
    private GenkoYoshi genkoyoshi;
    private Gtk.Toolbar toolbar;
    private Gtk.Menu context_edit_menu;
    private Gtk.Label page_label;
    private Gtk.Button prev_page_button;
    private Gtk.Button next_page_button;
    
    public GenkoyoshiAppWindow(Gtk.Application app) {
        show_menubar = false;
        application = app;
        init_action_map();
        
        var headerbar = new Gtk.HeaderBar();
        {
            if (!show_menubar) {
                /* previous, next, open, and save buttons at the left of the headerbar */
                var header_buttons = new Gtk.Box(HORIZONTAL, 5);
                {
                    var navigation_box = new Gtk.ButtonBox(HORIZONTAL) {
                            layout_style = EXPAND };
                    {
                        next_page_button = new Gtk.Button.from_icon_name("go-previous-symbolic",
                                SMALL_TOOLBAR);
                        {
                            next_page_button.action_name = "win.next-page";
                        }

                        prev_page_button = new Gtk.Button.from_icon_name("go-next-symbolic",
                                SMALL_TOOLBAR);
                        {
                            prev_page_button.action_name = "win.prev-page";
                        }

                        navigation_box.pack_start(next_page_button);
                        navigation_box.pack_start(prev_page_button);
                    }

                    page_label = new Gtk.Label("1/1");
                    
                    header_buttons.pack_start(navigation_box, false, false);
                    header_buttons.pack_start(page_label, false, false);
                }

                var menu_button = new Gtk.MenuButton();
                {
                    menu_button.set_menu_model(application.get_menu_by_id("hamburger-menu"));
                    menu_button.image = new Gtk.Image.from_icon_name("open-menu-symbolic", SMALL_TOOLBAR);
                }

                headerbar.pack_start(header_buttons);
                headerbar.pack_end(menu_button);
            }
            
            headerbar.show_close_button =true;
        }
        
        var vbox1 = new Gtk.Box(VERTICAL, 0);
        {
            Gtk.MenuBar menubar;
            if (show_menubar) {
                menubar = new Gtk.MenuBar.from_model(application.get_menubar());
            
                toolbar = new Gtk.Toolbar();
                {
                    var next_button = new Gtk.ToolButton(new Gtk.Image.from_icon_name("go-previous", Gtk.IconSize.SMALL_TOOLBAR), _("Next"));
                    next_button.clicked.connect(() => {
                        genkoyoshi.next_page();
                    });
                    var prev_button = new Gtk.ToolButton(new Gtk.Image.from_icon_name("go-next", Gtk.IconSize.SMALL_TOOLBAR), _("Previous"));
                    prev_button.clicked.connect(() => {
                        genkoyoshi.prev_page();
                    });

                    toolbar.insert(next_button, 0);
                    toolbar.insert(prev_button, 1);
                }
            } else{
                menubar = new Gtk.MenuBar();
                toolbar = new Gtk.Toolbar();
            }

            genkoyoshi = new GenkoYoshi();
            {
                genkoyoshi.require_context_menu.connect((event) => {
                    context_edit_menu.popup_at_pointer(event);
                });
                genkoyoshi.page_changed.connect((page, total_pages) => {
                    page_label.label = "%d/%d".printf(page + 1, total_pages);
                    prev_page_button.sensitive = page > 0;
                });
            }

            if (show_menubar) {
                vbox1.pack_start(menubar, false, false);
                vbox1.pack_start(toolbar, false, false);
            }

            vbox1.pack_start(genkoyoshi, true, true);
        }

        if (!show_menubar) {
            set_titlebar(headerbar);
            prev_page_button.sensitive = false;
        }
        
        add(vbox1);
        set_size_request(800, 600);
        set_title("原稿用紙");
        show_all();
        
        context_edit_menu = new Gtk.Menu.from_model(application.get_menu_by_id("edit-menu")) {
            attach_widget = this
        };
    }
    
    private void init_action_map() {
        var open_action = new SimpleAction("open", null);
        open_action.activate.connect(open_file);
        add_action(open_action);
        
        var choose_font_action = new SimpleAction("choose-font", null);
        choose_font_action.activate.connect(choose_font);
        add_action(choose_font_action);
        
        var save_action = new SimpleAction("save", VariantType.BOOLEAN);
        save_action.activate.connect((param) => {
            if (param.get_boolean()) {
                do_save_as();
            } else {
                do_save();
            }
        });
        add_action(save_action);
        
        var undo_action = new SimpleAction("undo", null);
        undo_action.activate.connect(() => do_undo());
        add_action(undo_action);
        
        var redo_action = new SimpleAction("redo", null);
        redo_action.activate.connect(() => do_redo());
        add_action(redo_action);
        
        var cut_action = new SimpleAction("cut", null);
        cut_action.activate.connect(() => do_cut());
        add_action(cut_action);
        
        var copy_action = new SimpleAction("copy", null);
        copy_action.activate.connect(() => do_copy());
        add_action(copy_action);
        
        var paste_action = new SimpleAction("paste", null);
        paste_action.activate.connect(() => do_paste());
        add_action(paste_action);
        
        var select_all_action = new SimpleAction("select-all", null);
        select_all_action.activate.connect(() => do_select_all());
        add_action(select_all_action);
        
        var delete_action = new SimpleAction("delete", null);
        delete_action.activate.connect(() => do_delete());
        add_action(delete_action);
        
        var next_page_action = new SimpleAction("next-page", null);
        next_page_action.activate.connect(() => genkoyoshi.next_page());
        add_action(next_page_action);

        var prev_page_action = new SimpleAction("prev-page", null);
        prev_page_action.activate.connect(() => genkoyoshi.prev_page());
        add_action(prev_page_action);
        
        choose_font_action = new SimpleAction("choose-font", null);
        choose_font_action.activate.connect(() => choose_font());
        add_action(choose_font_action);
    }
    
    /**
     * キー押下イベント処理。
     * コントロールキーを使ったショートカットキーの処理を実行する。
     * ショートカットに該当しない場合は原稿用紙ウィジェットに
     * 処理を受け渡す。
     */        
    public override bool key_press_event(Gdk.EventKey event) {
        if (CONTROL_MASK in event.state) {
            switch (event.keyval) {
              case Gdk.Key.z:
                do_undo();
                break;
              case Gdk.Key.y:
                do_redo();
                break;
              case Gdk.Key.a:
                do_select_all();
                break;
              case Gdk.Key.c:
                do_copy();
                return true;
              case Gdk.Key.x:
                do_cut();
                return true;
              case Gdk.Key.d:
                do_delete();
                return true;
              case Gdk.Key.v:
                do_paste();
                return true;
            }
        }

        return genkoyoshi.key_press_event(event);
    }

    /**
     * ファイルを開く。
     */
    private void open_file() {
        try {
            var dialog = new Gtk.FileChooserDialog(_("Open file"), this, OPEN, _("Cancel"), Gtk.ResponseType.CANCEL, _("Open"), Gtk.ResponseType.ACCEPT);
            int res = dialog.run();
            if (res == Gtk.ResponseType.ACCEPT) {
                string filename = dialog.get_filename();
                string new_text;
                File file = File.new_for_path(filename);
                FileInfo info = file.query_info("standard::*", 0);
                if (info.get_content_type().has_prefix("text/")) {
                    FileUtils.get_contents(filename, out new_text);
                    print("contents: %s\n", new_text.substring(0, 100));
                    genkoyoshi.model.set_contents(new_text);
                } else {
                    printerr("ERROR: This is not a text file!\n");
                }
            }
            dialog.close();
        } catch (FileError e) {
            printerr("ERROR: %s\n", e.message);
        } catch (Error e) {
            printerr("ERROR: %s\n", e.message);
        }
    }

    /**
     * フォントを選択し、変更を適用する。
     */    
    private void choose_font() {
        var dialog = new Gtk.FontChooserDialog(_("Choose Font"), this);
        dialog.font = genkoyoshi.font.name;
        int res = dialog.run();
        if (res == Gtk.ResponseType.OK) {
            genkoyoshi.font = FontSetting.from_font_desc(dialog.font, dialog.font_desc);
        }
        dialog.close();
    }

    /**
     * テキストをファイルに保存する。
     */    
    private async void save_file() {
        var dialog = new Gtk.FileChooserDialog(_("Save"), this, Gtk.FileChooserAction.SAVE,
                _("Cancel"), Gtk.ResponseType.CANCEL, _("Save"), Gtk.ResponseType.ACCEPT);
        dialog.set_current_folder(Environment.get_home_dir());
        dialog.show_all();
        int dialog_response = dialog.run();
        string filename_for_save = "";
        if (dialog_response == Gtk.ResponseType.ACCEPT) {
            filename_for_save = dialog.get_filename();
        }
        dialog.close();
        Idle.add(save_file.callback);
        yield;
        if (dialog_response == Gtk.ResponseType.CANCEL) {
            printerr("Request was canceled by user\n");
            return;
        } else if (FileUtils.test(filename_for_save, FileTest.EXISTS)) {
            printerr("The file already exists.\n");
            return;
        }
        try {
            string file_contents = genkoyoshi.model.get_contents();
            FileUtils.set_contents(filename_for_save, file_contents);
        } catch (FileError e) {
            printerr("FileError: %s\n", e.message);
        }
        return;
    }

    private void do_save() {
        save_file.begin();
    }
    
    private void do_save_as() {
        save_file.begin();
    }

    private void do_undo() {
        if (genkoyoshi.model.can_undo) {
            genkoyoshi.model.do_undo();
        }
    }
    
    private void do_redo() {
        if (genkoyoshi.model.can_redo) {
            genkoyoshi.model.do_redo();
        }
    }
        
    /**
     * 選択範囲のテキストをクリップボードにコピーする。
     */    
    private void do_copy() {
        string selected_text = genkoyoshi.model.selection_to_string();
        var clipboard = Gtk.Clipboard.get_default(get_display());
        clipboard.set_text(selected_text, selected_text.length);
    }
    
    /**
     * クリップボードのテキストをカーソルまたは選択範囲位置に
     * 貼り付ける。
     */
    private void do_paste() {
        var clipboard = Gtk.Clipboard.get_default(get_display());
        clipboard.request_text((clipboard, clipped_text) => {
            if (clipped_text != null) {
                genkoyoshi.model.insert_string(clipped_text);
            }
        });
    }

    /**
     * 切り取り処理を行う。
     * 選択範囲のテキストをコピーの後削除する。
     */
    private void do_cut() {
        do_copy();
        genkoyoshi.model.delete_selection();
    }

    /**
     * 選択範囲のテキストを削除する。
     */
    private void do_delete() {
        genkoyoshi.model.delete_selection();
    }

    /**
     * 「全て選択」の処理を行う。
     */    
    private void do_select_all() {
        genkoyoshi.model.select_all();
    }
}
