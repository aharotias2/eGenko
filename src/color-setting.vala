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

/**
 * 原稿用紙のカラーセット。
 * オプション設定で変更できるようにする。
 * 
 * ユーザーカスタム設定はホームディレクトリの~/.genkoyoshi/themes/にテキストファイル
 * として保存する。
 */
public struct ColorSetting {
    public Gdk.RGBA background;
    public Gdk.RGBA font;
    public Gdk.RGBA border;
    public Gdk.RGBA selection_border;
    public Gdk.RGBA selection_bg;
    public Gdk.RGBA preedit_font;
    public Gdk.RGBA newline_font;
    public Gdk.RGBA space;

    private static Regex? regex_config;

    public const string[] member_names = {
        "background",
        "font",
        "border",
        "selection_border",
        "selection_bg",
        "preedit_font",
        "newline_font",
        "space"
    };

    public ColorSetting.from_json_node(Json.Node node) throws AppError {
        Json.Object object = node.get_object();
        foreach (var name in member_names) {
            bool ret = false;
            if (object.has_member(name)) {
                switch (name) {
                  case "background":
                    ret = background.parse(object.get_string_member(name));
                    break;
                  case "font":
                    ret = font.parse(object.get_string_member(name));
                    break;
                  case "border":
                    ret = border.parse(object.get_string_member(name));
                    break;
                  case "selection_border":
                    ret = selection_border.parse(object.get_string_member(name));
                    break;
                  case "selection_bg":
                    ret = selection_bg.parse(object.get_string_member(name));
                    break;
                  case "preedit_font":
                    ret = preedit_font.parse(object.get_string_member(name));
                    break;
                  case "newline_font":
                    ret = newline_font.parse(object.get_string_member(name));
                    break;
                  case "space":
                    ret = space.parse(object.get_string_member(name));
                    break;
                  default:
                    ret = false;
                    break;
                }
                if (!ret) {
                    throw new AppError.CONFIG_ERROR(_("color parse error (%s)").printf(name));
                }
            } else {
                throw new AppError.CONFIG_ERROR(_("theme is not completed."));
            }
        }
    }
    
    public Gdk.RGBA get_by_name(string name) {
        switch (name) {
          case "background": return background;
          case "font": return font;
          case "border": return border;
          case "selection_border": return selection_border;
          case "selection_bg": return selection_bg;
          case "preedit_font": return preedit_font;
          case "newline_font": return newline_font;
          case "space": return space;
        }
        return Gdk.RGBA() { red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0 };
    }
}
