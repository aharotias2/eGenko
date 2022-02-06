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

public class GenkoyoshiAppWindow : Gtk.ApplicationWindow {
    public signal void require_quit();
    public signal void require_open_file();

    private Gtk.Notebook book;
    private GenkoHolder genkoholder;
    private Gtk.Menu context_edit_menu;
    private Gtk.Label page_label;
    private Gtk.Button prev_page_button;
    private Gtk.Button next_page_button;
    private Gtk.Revealer search_bar_revealer;
    private Gtk.Revealer replace_bar_revealer;
    private Gtk.Entry search_bar_entry;
    private Gtk.Entry replace_bar_entry1;
    private Gtk.Entry replace_bar_entry2;
    private Gtk.Button search_bar_search_foreward_button;
    private Gtk.Button search_bar_search_backward_button;
    private Gtk.Button search_bar_close_button;
    private Gtk.Button replace_bar_replace_button;
    private Gtk.Button replace_bar_replace_all_button;
    private Gtk.Button replace_bar_close_button;
    private AppConfigDialog? config_dialog;

    private SimpleAction save_action;
    private SimpleAction save_as_action;
    private SimpleAction search_action;
    private SimpleAction replace_action;
    private SimpleAction change_theme_action;
    private AppConfig config;

    private FocusList focus_list;

    public GenkoyoshiAppWindow(Gtk.Application app, AppConfig config) {
        application = app;
        this.config = config;
        init_action_map();
        focus_list = new FocusList();

        var headerbar = new Gtk.HeaderBar();
        {
            var header_buttons = new Gtk.Box(HORIZONTAL, 5);
            {
                var navigation_box = new Gtk.ButtonBox(HORIZONTAL) {
                        layout_style = EXPAND };
                {
                    next_page_button = new Gtk.Button.from_icon_name("go-previous-symbolic", SMALL_TOOLBAR);
                    {
                        next_page_button.action_name = "win.next-page";
                    }

                    prev_page_button = new Gtk.Button.from_icon_name("go-next-symbolic", SMALL_TOOLBAR);
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
                
                var theme_menu_section = application.get_menu_by_id("theme-menu-section");
                foreach (var theme_name in config.theme_map.keys) {
                    if (theme_name != "Default" && theme_name != "Dark" && theme_name != "Console") {
                        theme_menu_section.append(theme_name, @"win.change-theme('$(theme_name)')");
                    }
                }
            }

            headerbar.pack_start(header_buttons);
            headerbar.pack_end(menu_button);

            headerbar.show_close_button =true;
        }

        var vbox1 = new Gtk.Box(VERTICAL, 0);
        {
            var book_overlay = new Gtk.Overlay();
            {
                book = new Gtk.Notebook();
                {
                    book.append_page(create_new_genko_holder());
                    genkoholder = get_active_page();
                    book.change_current_page.connect((page) => {
                        genkoholder = get_active_page();
                        return true;
                    });
                    book.show_border = false;
                    book.show_tabs = false;
                }

                var search_bar_revealer_box = new Gtk.Box(VERTICAL, 0);
                {
                    search_bar_revealer = new Gtk.Revealer();
                    {
                        var search_bar_box = new Gtk.Box(HORIZONTAL, 5);
                        {
                            search_bar_entry = new Gtk.Entry() { can_focus = false };
                            focus_list.append_widget(search_bar_entry);

                            var search_bar_button_box = new Gtk.ButtonBox(HORIZONTAL);
                            {
                                search_bar_search_foreward_button = new Gtk.Button.from_icon_name("go-down-symbolic", SMALL_TOOLBAR) { can_focus = false };
                                search_bar_search_foreward_button.clicked.connect(() => {
                                    genkoholder.genkoyoshi.model.search_foreward(search_bar_entry.text);
                                });

                                search_bar_search_backward_button = new Gtk.Button.from_icon_name("go-up-symbolic", SMALL_TOOLBAR) { can_focus = false };
                                search_bar_search_backward_button.clicked.connect(() => {
                                    genkoholder.genkoyoshi.model.search_backward(search_bar_entry.text);
                                });

                                search_bar_button_box.pack_start(search_bar_search_foreward_button);
                                search_bar_button_box.pack_start(search_bar_search_backward_button);
                                search_bar_button_box.layout_style = EXPAND;

                                focus_list.append_widget(search_bar_search_foreward_button);
                                focus_list.append_widget(search_bar_search_backward_button);
                            }

                            search_bar_close_button = new Gtk.Button.from_icon_name("window-close-symbolic", SMALL_TOOLBAR) { can_focus = false };
                            search_bar_close_button.clicked.connect(() => {
                                hide_search_bar();
                            });

                            search_bar_box.pack_start(search_bar_entry, false, false);
                            search_bar_box.pack_start(search_bar_button_box, false, false);
                            search_bar_box.pack_start(search_bar_close_button, false, false);
                            search_bar_box.get_style_context().add_class("search_box");

                            focus_list.append_widget(search_bar_close_button);
                        }

                        search_bar_revealer.add(search_bar_box);
                        search_bar_revealer.transition_type = SLIDE_UP;
                        search_bar_revealer.reveal_child = false;
                    }

                    search_bar_revealer_box.pack_start(search_bar_revealer, false, false);
                    search_bar_revealer_box.halign = CENTER;
                }

                var replace_bar_revealer_box = new Gtk.Box(VERTICAL, 0);
                {
                    replace_bar_revealer = new Gtk.Revealer();
                    {
                        var replace_bar_hbox = new Gtk.Box(HORIZONTAL, 5);
                        {
                            var replace_bar_vbox1 = new Gtk.Box(VERTICAL, 5);
                            {
                                replace_bar_entry1 = new Gtk.Entry() { can_focus = false };
                                replace_bar_entry2 = new Gtk.Entry() { can_focus = false };

                                replace_bar_vbox1.pack_start(replace_bar_entry1, false, false);
                                replace_bar_vbox1.pack_start(replace_bar_entry2, false, false);

                                focus_list.append_widget(replace_bar_entry1);
                                focus_list.append_widget(replace_bar_entry2);
                            }

                            var replace_bar_vbox2 = new Gtk.Box(VERTICAL, 5);
                            {
                                replace_bar_replace_button = new Gtk.Button.with_label(_("Replace")) { can_focus = false };
                                replace_bar_replace_button.clicked.connect(() => {
                                    genkoholder.genkoyoshi.model.replace(replace_bar_entry1.text, replace_bar_entry2.text);
                                });

                                replace_bar_replace_all_button = new Gtk.Button.with_label(_("Replace All")) { can_focus = false };
                                replace_bar_replace_all_button.clicked.connect(() => {
                                    genkoholder.genkoyoshi.model.set_selection({{0, 0}, {0, 0}});
                                    genkoholder.genkoyoshi.model.replace_all(replace_bar_entry1.text, replace_bar_entry2.text);
                                });

                                replace_bar_vbox2.pack_start(replace_bar_replace_button, false, false);
                                replace_bar_vbox2.pack_start(replace_bar_replace_all_button, false, false);

                                focus_list.append_widget(replace_bar_replace_button);
                                focus_list.append_widget(replace_bar_replace_all_button);
                            }

                            replace_bar_close_button = new Gtk.Button.from_icon_name("window-close-symbolic", SMALL_TOOLBAR) { can_focus = false };
                            replace_bar_close_button.clicked.connect(() => {
                                hide_replace_bar();
                            });

                            replace_bar_hbox.pack_start(replace_bar_vbox1, false, false);
                            replace_bar_hbox.pack_start(replace_bar_vbox2, false, false);
                            replace_bar_hbox.pack_start(replace_bar_close_button, false, false);
                            replace_bar_hbox.get_style_context().add_class("search_box");

                            focus_list.append_widget(replace_bar_close_button);
                        }

                        replace_bar_revealer.add(replace_bar_hbox);
                        replace_bar_revealer.transition_type = SLIDE_UP;
                        replace_bar_revealer.reveal_child = false;
                    }

                    replace_bar_revealer_box.pack_start(replace_bar_revealer, false, false);
                    replace_bar_revealer_box.halign = CENTER;
                }

                book_overlay.add(book);
                book_overlay.add_overlay(search_bar_revealer_box);
                book_overlay.set_overlay_pass_through(search_bar_revealer_box, true);
                book_overlay.add_overlay(replace_bar_revealer_box);
                book_overlay.set_overlay_pass_through(replace_bar_revealer_box, true);
            }

            vbox1.pack_start(book_overlay, true, true);
        }

        set_titlebar(headerbar);
        prev_page_button.sensitive = false;

        add(vbox1);
        set_size_request(800, 600);
        set_title(_("Untitled") + _(" - Genkoyoshi"));
        show_all();

        context_edit_menu = new Gtk.Menu.from_model(application.get_menu_by_id("context-edit-menu")) {
            attach_widget = this
        };
    }

    private GenkoHolder create_new_genko_holder() {
        var genkoholder = new GenkoHolder();
        {
            genkoholder.genkoyoshi.model.changed.connect(() => {
                if (genkoholder.has_file && !save_as_action.get_enabled()) {
                    save_as_action.set_enabled(true);
                }
                if (!save_action.get_enabled()) {
                    save_action.set_enabled(true);
                }
            });
            genkoholder.genkoyoshi.require_context_menu.connect((event) => {
                context_edit_menu.popup_at_pointer(event);
            });
            genkoholder.genkoyoshi.page_changed.connect((page, total_pages) => {
                page_label.label = "%d/%d".printf(page + 1, total_pages);
                prev_page_button.sensitive = page > 0;
            });
            genkoholder.genkoyoshi.config = config;
            genkoholder.genkoyoshi.color = config.theme_map[config.selected_theme_name];
            genkoholder.genkoyoshi.font = config.font_setting;
        }
        return genkoholder;
    }

    private void init_action_map() {
        var open_action = new SimpleAction("open", null);
        open_action.activate.connect(open_file);
        add_action(open_action);

        save_action = new SimpleAction("save", null);
        save_action.activate.connect(() => {
            debug("save_action");
            do_save();
        });
        save_action.set_enabled(false);
        add_action(save_action);

        save_as_action = new SimpleAction("save-as", null);
        save_as_action.activate.connect(() => {
            debug("save_as_action");
            do_save_as();
        });
        save_as_action.set_enabled(false);
        add_action(save_as_action);

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
        next_page_action.activate.connect(() => genkoholder.genkoyoshi.next_page());
        add_action(next_page_action);

        var prev_page_action = new SimpleAction("prev-page", null);
        prev_page_action.activate.connect(() => genkoholder.genkoyoshi.prev_page());
        add_action(prev_page_action);

        var choose_font_action = new SimpleAction("choose-font", null);
        choose_font_action.activate.connect(() => choose_font());
        add_action(choose_font_action);

        search_action = new SimpleAction("search", null);
        search_action.activate.connect(() => do_search());
        add_action(search_action);

        replace_action = new SimpleAction("replace", null);
        replace_action.activate.connect(() => do_replace());
        add_action(replace_action);

        change_theme_action = new SimpleAction.stateful("change-theme", VariantType.STRING,
                new Variant("s", config.selected_theme_name));
        change_theme_action.activate.connect((param) => {
            change_theme_action.set_state(param);
            var theme_name = param.get_string();
            var theme = config.theme_map[theme_name];
            if (theme == null) {
                return;
            }
            genkoholder.genkoyoshi.color = theme;
            config.selected_theme_name = theme_name;
            genkoholder.genkoyoshi.queue_draw();
        });
        add_action(change_theme_action);

        var show_config_dialog_action = new SimpleAction("show-config-dialog", null);
        show_config_dialog_action.activate.connect(() => {
            if (config_dialog == null) {
                config_dialog = new AppConfigDialog(config);
                config_dialog.destroy.connect(() => {
                    config_dialog = null;
                });
            }
            config_dialog.show_all();
        });
        add_action(show_config_dialog_action);
        
        var customize_theme_action = new SimpleAction("customize-theme", null);
        customize_theme_action.activate.connect(() => {
            do_customize_theme();
        });
        add_action(customize_theme_action);
    }

    /**
     * キー押下イベント処理。
     * コントロールキーを使ったショートカットキーの処理を実行する。
     * ショートカットに該当しない場合は原稿用紙ウィジェットに
     * 処理を受け渡す。
     */
    public override bool key_press_event(Gdk.EventKey event) {
        if (genkoholder.genkoyoshi.is_focus) {
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
            return genkoholder.genkoyoshi.key_press_event(event);
        } else if (event.keyval == Gdk.Key.Tab) {
            if (SHIFT_MASK in event.state) {
                focus_list.move_focus_backward();
            } else {
                focus_list.move_focus_foreward();
            }
            return true;
        } else if (event.keyval == Gdk.Key.ISO_Left_Tab) {
            focus_list.move_focus_backward();
            return true;
        } else {
            return propagate_key_event(event);
        }
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
                File file = File.new_for_path(filename);
                FileInfo info = file.query_info("standard::*", 0);
                if (info.get_content_type().has_prefix("text/")) {
                    genkoholder.genkoyoshi.model.set_contents_from_file.begin(file);
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
        dialog.font = genkoholder.genkoyoshi.font.name;
        int res = dialog.run();
        if (res == Gtk.ResponseType.OK) {
            FontSetting font_setting = FontSetting.from_font_desc(dialog.font, dialog.font_desc);
            genkoholder.genkoyoshi.font = font_setting;
            config.font_setting = font_setting;
        }
        dialog.close();
        get_active_page().queue_draw();
    }

    /**
     * テキストをファイルに保存する。
     */
    private async void save_file(SaveMode save_mode) {
        debug("enter save_file");
        string filename_for_save = "";
        try {
            var genkoholder = get_active_page();
            if (save_mode == OVERWRITE) {
                filename_for_save = genkoholder.get_filepath();
            } else if (save_mode == RENAME) {
                var dialog = new Gtk.FileChooserDialog(_("Save"), this, Gtk.FileChooserAction.SAVE,
                        _("Cancel"), Gtk.ResponseType.CANCEL, _("Save"), Gtk.ResponseType.ACCEPT);
                if (genkoholder.has_file) {
                    dialog.set_current_folder(genkoholder.get_dirname());
                } else {
                    dialog.set_current_folder(Environment.get_home_dir());
                }
                dialog.show_all();
                int dialog_response = dialog.run();
                if (dialog_response == Gtk.ResponseType.ACCEPT) {
                    filename_for_save = dialog.get_filename();
                }
                dialog.close();
                if (dialog_response == Gtk.ResponseType.CANCEL) {
                    printerr("Request was canceled by user\n");
                    return;
                }
            }
            Idle.add(save_file.callback);
            yield;
            if (save_mode != OVERWRITE && FileUtils.test(filename_for_save, FileTest.EXISTS)) {
                Gtk.DialogFlags flags = Gtk.DialogFlags.DESTROY_WITH_PARENT;
                Gtk.MessageDialog alert = new Gtk.MessageDialog(this, flags, Gtk.MessageType.INFO, Gtk.ButtonsType.OK_CANCEL,
                        _("File already exists. Do you want to overwrite it?"));
                int res = alert.run();
                alert.close();
                if (res == Gtk.ResponseType.CANCEL) {
                    printerr("Request was canceled by user\n");
                    return;
                }
                Idle.add(save_file.callback);
                yield;
            }
            string file_contents = genkoholder.genkoyoshi.model.get_contents();
            FileUtils.set_contents(filename_for_save, file_contents);
            if (!genkoholder.has_file || save_mode == RENAME) {
                genkoholder.set_filepath(filename_for_save);
                debug("%s (%s)", filename_for_save, File.new_for_path(filename_for_save).get_basename());
                set_title(genkoholder.get_filename() + _(" - GenkoYoshi"));
            }
            save_action.set_enabled(false);
            save_as_action.set_enabled(true);
        } catch (FileError e) {
            printerr("FileError: %s\n", e.message);
        } catch (AppError e) {
            printerr("AppError: %s\n", e.message);
        }
        return;
    }

    private GenkoHolder get_active_page() {
        return (!) book.get_nth_page(book.get_current_page()) as GenkoHolder;
    }

    private void do_save() {
        debug("do_save");
        save_file.begin(genkoholder.has_file ? SaveMode.OVERWRITE : SaveMode.RENAME);
    }

    private void do_save_as() {
        debug("do_save_as");
        save_file.begin(RENAME);
    }

    private void do_undo() {
        if (genkoholder.genkoyoshi.model.can_undo) {
            genkoholder.genkoyoshi.model.do_undo();
        }
    }

    private void do_redo() {
        if (genkoholder.genkoyoshi.model.can_redo) {
            genkoholder.genkoyoshi.model.do_redo();
        }
    }

    /**
     * 選択範囲のテキストをクリップボードにコピーする。
     */
    private void do_copy() {
        string selected_text = genkoholder.genkoyoshi.model.selection_to_string();
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
                genkoholder.genkoyoshi.model.insert_string(clipped_text);
            }
        });
    }

    /**
     * 切り取り処理を行う。
     * 選択範囲のテキストをコピーの後削除する。
     */
    private void do_cut() {
        do_copy();
        genkoholder.genkoyoshi.model.delete_selection();
    }

    /**
     * 選択範囲のテキストを削除する。
     */
    private void do_delete() {
        genkoholder.genkoyoshi.model.delete_selection();
    }

    /**
     * ダイアログを表示し、カラーテーマをカスタマイズする。
     */
    private void do_customize_theme() {
        var color_setting_dialog = new ColorSettingDialog(config);
        color_setting_dialog.show_all();
        int res = color_setting_dialog.run();
        if (res == Gtk.ResponseType.ACCEPT || res == Gtk.ResponseType.APPLY) {
            string new_theme_name = color_setting_dialog.get_theme_name();
            if (new_theme_name != "") {
                var theme_menu = application.get_menu_by_id("theme-menu-section");
                if (!config.theme_map.has_key(new_theme_name)) {
                    theme_menu.append(new_theme_name, @"win.change-theme('$(new_theme_name)')");
                }
                if (new_theme_name != "Default" && new_theme_name != "Dark" && new_theme_name != "Console") {
                    config.theme_map[new_theme_name] = color_setting_dialog.get_color_setting();
                }
                if (res == Gtk.ResponseType.APPLY) {
                    config.selected_theme_name = new_theme_name;
                    genkoholder.genkoyoshi.color = config.theme_map[new_theme_name];
                    genkoholder.genkoyoshi.queue_draw();
                }
            }
        }
        color_setting_dialog.close();
    }
    
    /**
     * 「全て選択」の処理を行う。
     */
    private void do_select_all() {
        genkoholder.genkoyoshi.model.select_all();
    }

    private void do_search() {
        if (replace_bar_revealer.child_revealed) {
            hide_replace_bar();
        }
        show_search_bar();
        focus_list.set_focus(search_bar_entry);
    }

    private void do_replace() {
        if (search_bar_revealer.child_revealed) {
            hide_search_bar();
        }
        show_replace_bar();
        focus_list.set_focus(replace_bar_entry1);
    }

    private void show_search_bar() {
        search_bar_revealer.reveal_child = true;
        search_bar_entry.can_focus = true;
        search_bar_search_foreward_button.can_focus = true;
        search_bar_search_backward_button.can_focus = true;
        search_bar_close_button.can_focus = true;
    }

    private void hide_search_bar() {
        search_bar_revealer.reveal_child = false;
        search_bar_entry.can_focus = false;
        search_bar_search_foreward_button.can_focus = false;
        search_bar_search_backward_button.can_focus = false;
        search_bar_close_button.can_focus = false;
    }

    private void show_replace_bar() {
        replace_bar_revealer.reveal_child = true;
        replace_bar_entry1.can_focus = true;
        replace_bar_entry2.can_focus = true;
        replace_bar_replace_button.can_focus = true;
        replace_bar_replace_all_button.can_focus = true;
        replace_bar_close_button.can_focus = true;
    }

    private void hide_replace_bar() {
        replace_bar_revealer.reveal_child = false;
        replace_bar_entry1.can_focus = false;
        replace_bar_entry2.can_focus = false;
        replace_bar_replace_button.can_focus = false;
        replace_bar_replace_all_button.can_focus = false;
        replace_bar_close_button.can_focus = false;
    }
}
