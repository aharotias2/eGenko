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

public class AppConfigDialog : Gtk.Dialog {
    public AppConfig config { get; construct set; }
    public AppConfigDialog(AppConfig config) {
        Object(
            config: config,
            modal: true
        );
    }

    construct {
        var contents_area = get_content_area();
        {
            var frame_view = new Gtk.Frame(_("View"));
            {
                var frame_view_vbox = new Gtk.Box(VERTICAL, 0);
                {
                    var check_is_newline_visible = new Gtk.CheckButton.with_label(_("show newlines.")) {
                        active = config.is_newline_visible
                    };
                    check_is_newline_visible.toggled.connect(() => {
                        print("check_is_newline_visible.activate (active: %s)\n", check_is_newline_visible.active.to_string());
                        config.is_newline_visible = check_is_newline_visible.active;
                    });

                    var check_is_space_visible = new Gtk.CheckButton.with_label(_("show spaces")) {
                        active = config.is_space_visible
                    };
                    check_is_space_visible.toggled.connect(() => {
                        print("check_is_space_visible.activate (active: %s)\n", check_is_space_visible.active.to_string());
                        config.is_space_visible = check_is_space_visible.active;
                    });

                    frame_view_vbox.pack_start(check_is_newline_visible, false, false);
                    frame_view_vbox.pack_start(check_is_space_visible, false, false);
                }

                frame_view.add(frame_view_vbox);
            }

            contents_area.pack_start(frame_view, false, false);
        }
    }
}
