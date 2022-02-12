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

/**
 * 縦書きの時形を変えないといけないフォントについて処理を行う。
 */
namespace VerticalFormMap {
    /**
     * ユニコードのコードポイントを判定し、縦書きの時にどのような変形をするかを表す
     * ConvTypeの値を返す。
     * 変形が必要ない時はConvType.NORMALを返す。
     */
    public ConvType get_convtype(uint32 codepoint) {
        var map = MapHolder.get_instance();
        if (map.has_key(codepoint)) {
            return map[codepoint];
        } else {
            return ConvType.NORMAL;
        }
    }

    /**
     * 縦書きの時の変形パターンをリソースから読み取り、HashMapに保持するクラス。
     * 内部で使用するため、外部からはアクセスしない。
     */
    private class MapHolder : Object {
        private static Gee.Map<uint32, ConvType>? vertical_form_map;
        
        private MapHolder() {}
        
        public static Gee.Map<uint32, ConvType> get_instance() {
            if (vertical_form_map == null) {
                init_vertical_form_map();
            }
            return vertical_form_map;
        }
        
        private static void init_vertical_form_map() {
            try {
                vertical_form_map = new Gee.HashMap<uint32, ConvType>();
                // JSON形式のリソースを読み込む
                File res = File.new_for_uri("resource:///com/github/aharotias2/eGenko/vertical-setting.json");
                var parser = new Json.Parser();
                parser.load_from_stream(res.read());
                var root = parser.get_root().get_object();
                var vertical_setting_member = root.get_object_member("vertical-setting");
                // 縦書きの時はセルの右上に配置する文字を格納する
                var tu = vertical_setting_member.get_array_member("Tu");
                tu.foreach_element((array, index, element) => {
                    try {
                        uint32 codepoint = Utf8Utils.utf8_to_codepoint((char[]) element.get_string().data);
                        vertical_form_map[codepoint] = ConvType.UPRIGHT;
                    } catch (Utf8Utils.ParseError e) {
                        Process.exit(99);
                    }
                });
                // 縦書きの時回転して向きを変える文字を格納する。
                var tr = vertical_setting_member.get_array_member("Tr");
                tr.foreach_element((array, index, element) => {
                    try {
                        uint32 codepoint = Utf8Utils.utf8_to_codepoint((char[]) element.get_string().data);
                        vertical_form_map[codepoint] = ConvType.ROTATE;
                    } catch (Utf8Utils.ParseError e) {
                        Process.exit(99);
                    }
                });
            } catch (Error e) {
                // この処理で例外がある場合、ロジックに問題があるので異常終了する。
                printerr("ERROR (%d): %s\n", e.code, e.message);
                Process.exit(127);
            }
        }
    }
}
