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

public struct FontSetting {
    public string name;
    public string family;
    public Cairo.FontWeight weight;
    public Cairo.FontSlant style;

    public FontSetting.from_font_desc(string font, Pango.FontDescription font_desc) {
        name = font;
        family = font_desc.get_family();
        switch (font_desc.get_weight()) {
          case BOLD:
          case SEMIBOLD:
          case ULTRABOLD:
          case ULTRAHEAVY:
          case HEAVY:
            weight = BOLD;
            break;
          default:
            weight = NORMAL;
            break;
        }
        switch (font_desc.get_style()) {
          case NORMAL:
            style = NORMAL;
            break;
          case ITALIC:
            style = ITALIC;
            break;
          case OBLIQUE:
            style = OBLIQUE;
            break;
        }
    }

    public FontSetting.from_json_object(Json.Object json_object) {
        name = json_object.get_string_member("name");
        family = json_object.get_string_member("family");
        weight = NORMAL;
        style = NORMAL;
    }

    public Json.Object to_json_object() {
        Json.Object json_object = new Json.Object();
        json_object.set_string_member("name", name);
        json_object.set_string_member("family", family);
        return json_object;
    }
}
