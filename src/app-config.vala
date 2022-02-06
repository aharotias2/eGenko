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

public class AppConfig : Object {
    public File user_config_dir { get; private set; }
    public File user_config_file { get; private set; }
    public Gee.Map<string, ColorSetting?> theme_map { get; private set; }
    public string selected_theme_name { get; set; }
    public bool is_space_visible = true;
    public bool is_newline_visible = true;
    public FontSetting font_setting;

    private bool does_user_config_dir_exists = false;
    private bool does_user_config_file_exists = false;

    public AppConfig() {
        var home_dir = Environment.get_home_dir();
        var config_root = ".config";
        var user_config_dir_path = Path.build_path(Path.DIR_SEPARATOR_S, home_dir, config_root, APP_ID);
        user_config_dir = File.new_for_path(user_config_dir_path);
        does_user_config_dir_exists = user_config_dir.query_exists();
        var user_config_file_path = Path.build_path(Path.DIR_SEPARATOR_S, user_config_dir_path, "app.conf");
        user_config_file = File.new_for_path(user_config_file_path);
        does_user_config_file_exists = user_config_file.query_exists();
    }

    public void write_user_config_file() throws Error {
        if (!does_user_config_dir_exists) {
            create_user_config_dir();
        }
        Json.Builder builder = new Json.Builder();
        builder.begin_object();
        {
            builder.set_member_name("initial_theme_name");
            builder.add_string_value(selected_theme_name);
            builder.set_member_name("is_newline_visible");
            builder.add_boolean_value(is_newline_visible);
            builder.set_member_name("is_space_visible");
            builder.add_boolean_value(is_space_visible);
            builder.set_member_name("themes");
            builder.begin_object();
            foreach (var key in theme_map.keys) {
                if (key == "Default" || key == "Dark" || key == "Console") {
                    continue;
                }
                var theme = theme_map[key];
                builder.set_member_name(key);
                builder.begin_object();
                foreach (var name in ColorSetting.member_names) {
                    builder.set_member_name(name);
                    builder.add_string_value(theme.get_by_name(name).to_string());
                }
                builder.end_object();
            }
            builder.end_object();
            builder.set_member_name("font");
            builder.begin_object();
            {
                builder.set_member_name("name");
                builder.add_string_value(font_setting.name);
                builder.set_member_name("family");
                builder.add_string_value(font_setting.family);
            }
            builder.end_object();
        }
        builder.end_object();

        Json.Generator generator = new Json.Generator();
        generator.set_pretty(true);
        generator.set_indent(4);
        generator.set_indent_char(' ');
        generator.set_root(builder.get_root());
        generator.to_file(user_config_file.get_path());
    }

    public void read_user_config_file() throws Error {
        init_theme_map();
        selected_theme_name = "Default";
        if (user_config_file.query_exists()) {
            does_user_config_file_exists = true;
            Json.Parser parser = new Json.Parser();
            parser.load_from_file(user_config_file.get_path());
            var json_root = parser.get_root();
            var root_object = json_root.get_object();
            selected_theme_name = root_object.get_string_member("initial_theme_name");
            read_themes(root_object.get_object_member("themes"));
            if (!theme_map.has_key(selected_theme_name)) {
                selected_theme_name = "Default";
            }
            is_newline_visible = root_object.get_boolean_member("is_newline_visible");
            is_space_visible = root_object.get_boolean_member("is_space_visible");
            font_setting = FontSetting.from_json_object(root_object.get_object_member("font"));
        }
    }

    private void init_theme_map() {
        theme_map = new Gee.HashMap<string, ColorSetting?>();
        theme_map["Default"] = PresetColorSetting.THEME_DEFAULT;
        theme_map["Dark"] = PresetColorSetting.THEME_DARK;
        theme_map["Console"] = PresetColorSetting.THEME_CONSOLE;
    }

    private void read_themes(Json.Object themes_object) {
        foreach (string member_name in themes_object.get_members()) {
            try {
                theme_map[member_name] = ColorSetting.from_json_node(themes_object.get_member(member_name));
            } catch (AppError e) {
                printerr("%s\n", e.message);
            }
        }
    }

    private bool create_user_config_dir() {
        if (!user_config_dir.query_exists()) {
            try {
                user_config_dir.make_directory_with_parents();
                print("make directory (%s)\n", user_config_dir.get_path());
                does_user_config_dir_exists = true;
                return true;
            } catch (Error e) {
                does_user_config_dir_exists = false;
                return false;
            }
        } else {
            return false;
        }
    }
}
