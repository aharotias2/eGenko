public class ColorSettingDialog : Gtk.Dialog {
    public string get_theme_name() {
        return theme_name_entry.get_active_text();
    }
    
    public ColorSetting get_color_setting() {
        return ColorSetting() {
            background = choose_background_button.get_rgba(),
            font = choose_font_button.get_rgba(),
            border = choose_border_button.get_rgba(),
            selection_border = choose_selection_border_button.get_rgba(),
            selection_bg = choose_selection_bg_button.get_rgba(),
            preedit_font = choose_preedit_font_button.get_rgba(),
            newline_font = choose_newline_button.get_rgba(),
            space = choose_space_button.get_rgba()
        };
    }

    public AppConfig config { get; construct set; }    
    private Gtk.ComboBoxText theme_name_entry;
    private Gtk.ColorButton choose_background_button;
    private Gtk.ColorButton choose_font_button;
    private Gtk.ColorButton choose_border_button;
    private Gtk.ColorButton choose_selection_border_button;
    private Gtk.ColorButton choose_selection_bg_button;
    private Gtk.ColorButton choose_preedit_font_button;
    private Gtk.ColorButton choose_newline_button;
    private Gtk.ColorButton choose_space_button;
    
    public ColorSettingDialog(AppConfig config) {
        Object(
            config: config
        );
    }
    
    construct {
        var content_area = get_content_area();
        {
            var theme_name_hbox = new Gtk.Box(HORIZONTAL, 0);
            {
                var theme_name_label = new Gtk.Label(_("Theme Name"));
                theme_name_entry = new Gtk.ComboBoxText.with_entry();
                theme_name_entry.changed.connect(() => {
                    string theme_name = theme_name_entry.get_active_text();
                    if (config.theme_map.has_key(theme_name)) {
                        ColorSetting colors = config.theme_map[theme_name];
                        choose_background_button.set_rgba(colors.background);
                        choose_font_button.set_rgba(colors.font);
                        choose_border_button.set_rgba(colors.border);
                        choose_selection_border_button.set_rgba(colors.selection_border);
                        choose_selection_bg_button.set_rgba(colors.selection_bg);
                        choose_preedit_font_button.set_rgba(colors.preedit_font);
                        choose_newline_button.set_rgba(colors.newline_font);
                        choose_space_button.set_rgba(colors.space);
                    }
                });
                
                theme_name_hbox.pack_start(theme_name_label, false, false);
                theme_name_hbox.pack_start(theme_name_entry, true, true);
            }
            
            var buttons = new Gtk.FlowBox();
            {
                var box1 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_background_label = new Gtk.Label(_("Background"));
                    choose_background_button = new Gtk.ColorButton();
                    box1.pack_start(choose_background_label, false, false);
                    box1.pack_start(choose_background_button, false, false);
                }
                var box2 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_font_label = new Gtk.Label(_("Font"));
                    choose_font_button = new Gtk.ColorButton();
                    box2.pack_start(choose_font_label, false, false);
                    box2.pack_start(choose_font_button, false, false);
                }
                var box3 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_border_label = new Gtk.Label(_("Borders"));
                    choose_border_button = new Gtk.ColorButton();
                    box3.pack_start(choose_border_label, false, false);
                    box3.pack_start(choose_border_button, false, false);
                }
                var box4 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_selection_border_label = new Gtk.Label(_("Selection Borders"));
                    choose_selection_border_button = new Gtk.ColorButton();
                    box4.pack_start(choose_selection_border_label, false, false);
                    box4.pack_start(choose_selection_border_button, false, false);
                }
                var box5 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_selection_bg_label = new Gtk.Label(_("Selection Background"));
                    choose_selection_bg_button = new Gtk.ColorButton();
                    box5.pack_start(choose_selection_bg_label, false, false);
                    box5.pack_start(choose_selection_bg_button, false, false);
                }
                var box6 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_preedit_font_label = new Gtk.Label(_("Preedit Font"));
                    choose_preedit_font_button = new Gtk.ColorButton();
                    box6.pack_start(choose_preedit_font_label, false, false);
                    box6.pack_start(choose_preedit_font_button, false, false);
                }
                var box7 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_newline_label = new Gtk.Label(_("Newlines"));
                    choose_newline_button = new Gtk.ColorButton();
                    box7.pack_start(choose_newline_label, false, false);
                    box7.pack_start(choose_newline_button, false, false);
                }
                var box8 = new Gtk.Box(VERTICAL, 0);
                {
                    var choose_space_label = new Gtk.Label(_("Spaces"));
                    choose_space_button = new Gtk.ColorButton();
                    box8.pack_start(choose_space_label, false, false);
                    box8.pack_start(choose_space_button, false, false);
                }
                buttons.insert(box1, 0);
                buttons.insert(box2, 1);
                buttons.insert(box3, 2);
                buttons.insert(box4, 3);
                buttons.insert(box5, 4);
                buttons.insert(box6, 5);
                buttons.insert(box7, 6);
                buttons.insert(box8, 7);
            }
            
            content_area.pack_start(theme_name_hbox, false, false);
            content_area.pack_start(buttons, false, false);
        }
        
        use_header_bar = 1;
        add_button(_("Cancel"), Gtk.ResponseType.CANCEL);
        add_button(_("Apply"), Gtk.ResponseType.APPLY);
        add_button(_("Save"), Gtk.ResponseType.ACCEPT);
        
        set_preset_colors();
    }
    
    public void set_preset_colors() {
        foreach (var key in config.theme_map.keys) {
            theme_name_entry.append_text(key);
        }
    }
}
