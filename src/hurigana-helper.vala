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

namespace HuriganaHelper {
    public struct HuriganaPair {
        public string text;
        public string ruby;
    }
    
    public const string HURIGANA_REGEX = "\\[/([^/]+)/([^/]+)/\\]";
    public const string BOLD_REGEX = "\\[\\+(.+)\\+\\]";
    public const string DOTTED_REGEX = "\\[\\^(.+)\\^\\]";
    
    private class RegexInstanceHolder : Object {
        private static Regex hurigana_regex;
        private static Regex bold_regex;
        private static Regex dotted_regex;

        private RegexInstanceHolder() {}

        public static Regex get_hurigana_regex() {
            if (hurigana_regex == null) {
                try {
                    hurigana_regex = new Regex(HURIGANA_REGEX);
                } catch (RegexError e) {
                    printerr("Regex Error in %s\n", HURIGANA_REGEX);
                    Process.exit(127);
                }
            }
            return hurigana_regex;
        }
        
        public static Regex get_bold_regex() {
            if (bold_regex == null) {
                try {
                    bold_regex = new Regex(BOLD_REGEX);
                } catch (RegexError e) {
                    printerr("Regex Error in %s\n", BOLD_REGEX);
                    Process.exit(127);
                }
            }
            return bold_regex;
        }

        public static Regex get_dotted_regex() {
            if (dotted_regex == null) {
                try {
                    dotted_regex = new Regex(DOTTED_REGEX);
                } catch (RegexError e) {
                    printerr("Regex Error in %s\n", DOTTED_REGEX);
                    Process.exit(127);
                }
            }
            return dotted_regex;
        }
        
    }
    
    public int read_hurigana(string src, int start_offset, out string? main_text, out string? hurigana_text) {
        if (src[start_offset] != '[') {
            main_text = null;
            hurigana_text = null;
            return 0;
        }
        var regex = RegexInstanceHolder.get_hurigana_regex();
        MatchInfo matches;
        string substr = src.substring(start_offset);
        if (regex.match(substr, 0, out matches)) {
            var whole_match = matches.fetch(0);
            main_text = matches.fetch(1);
            hurigana_text = matches.fetch(2);
            return whole_match.length;
        } else {
            main_text = null;
            hurigana_text = null;
            return 0;
        }
    }
    
    public int read_bold(string src, int start_offset, out string? bold_text) {
        if (src[start_offset] != '[') {
            bold_text = null;
            return 0;
        }
        var regex = RegexInstanceHolder.get_bold_regex();
        MatchInfo matches;
        string substr = src.substring(start_offset);
        if (regex.match(substr, 0, out matches)) {
            var whole_match = matches.fetch(0);
            bold_text = matches.fetch(1);
            return whole_match.length;
        } else {
            bold_text = null;
            return 0;
        }
    }
    
    public int read_dotted(string src, int start_offset, out string? dotted_text) {
        if (src[start_offset] != '[') {
            dotted_text = null;
            return 0;
        }
        var regex = RegexInstanceHolder.get_dotted_regex();
        MatchInfo matches;
        string substr = src.substring(start_offset);
        if (regex.match(substr, 0, out matches)) {
            var whole_match = matches.fetch(0);
            dotted_text = matches.fetch(1);
            return whole_match.length;
        } else {
            dotted_text = null;
            return 0;
        }
    }
}
