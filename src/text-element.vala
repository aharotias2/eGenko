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

public class TextElement : Object {
    public string? str { get; construct; }
    public ConvType conv_type { get; construct; }
    public uint32 unicode_codepoint { get; construct; }
    public int size {
        get {
            return str.length;
        }
    }
    public bool is_preedit { get; set; }
    public bool has_hurigana { get; set; }
    public int hurigana_span { get; set; }
    public SimpleList<TextElement> hurigana { get; set; }
    public bool is_bold { get; set; default = false; }
    public bool is_dotted { get; set; default = false; }

    public TextElement(string src) {
        try {
            uint32 codepoint = Utf8Utils.utf8_to_codepoint((char[]) src.data);
            ConvType conv_type = VerticalFormMap.get_convtype(codepoint);
            Object(
                str: src,
                is_preedit: false,
                has_hurigana: false,
                hurigana_span: 0,
                hurigana: new SimpleList<TextElement>(),
                unicode_codepoint: codepoint,
                conv_type: conv_type
            );
        } catch (Utf8Utils.ParseError e) {
            printerr("CRITICAL: %s\n", e.message);
            Process.exit(127);
        }
    }

    public TextElement clone() {
        TextElement e = new TextElement(this.str);
        e.is_preedit = is_preedit;
        e.has_hurigana = has_hurigana;
        e.hurigana_span = hurigana_span;
        e.hurigana = hurigana;
        e.is_bold = is_bold;
        e.is_dotted = is_dotted;
        return e;
    }
}
