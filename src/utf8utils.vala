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

namespace Utf8Utils {
    public errordomain ParseError {
        INVALID_SIGN_BITS, INVALID_BYTE_LENGTH
    }
    
    /**
     * UTF-8の先頭ビットを見て何バイトの文字になるかを判定し、
     * そのバイト数を返す。
     * UTF-8文字の先頭バイトでない場合は例外とする。
     */
    public int get_length_sign(uint8 c) throws ParseError {
        if ((c & 0x80) == 0x00) {
            // (c & 0b10000000) == 0b00000000
            return 1;
        } else if ((c & 0xE0) == 0xC0) {
            // (c & 0b11100000) == 0b11000000
            return 2;
        } else if ((c & 0xF0) == 0xE0) {
            // (c & 0b11110000) == 0b11100000
            return 3;
        } else if ((c & 0xF8) == 0xF0) {
            // (c & 0b11111000) == 0b11110000
            return 4;
        } else if ((c & 0xFC) == 0xF8) {
            // (c & 0b11111100) == 0b11111000
            return 5;
        } else {
            throw new ParseError.INVALID_SIGN_BITS("Significant bits is invalid");
        }
    }
    
    /**
     * UTF-8の文字データを判定し、ユニコードのコードポイントを算出する。
     * 引数はUTF-8の一文字分のバイト列。
     * 返値にはユニコードコードポイントを整数値で返す。
     * 引数が正しいUTF-8の一文字になっていない時には例外を投げる。
     */
    public uint32 utf8_to_codepoint(char[] utf8) throws ParseError {
        uint32 result = 0;
        int len = get_length_sign(utf8[0]);
        if (len == utf8.length) {
            if (len == 1) {
                return utf8[0];
            } else {
                int i = len - 1;
                int j = 0;
                while (i > 0) {
                    result |= (utf8[i] & 0x3F) << (6 * j);
                    i--;
                    j++;
                }
                result |= (utf8[0] & (0x7F >> len)) << (6 * (len - 1));
                return result;
            }
        } else {
            throw new ParseError.INVALID_BYTE_LENGTH("Byte lengths do not match");
        }
    }

    /**
     * ユニコードコードポイントの値を判定してUTF-8の一文字分のstringを返す。
     * 引数が0の場合は空文字列を返す。
     * 例外は発生しないと思われる。
     */    
    public string codepoint_to_utf8(uint32 codepoint) {
        if (codepoint == 0) {
            return "";
        }
        // コードポイントの値から、UTF-8で何バイトになるかを算出する。
        // UTF-8の仕様により、ユニコードの表現に必要なバイト数は決まっているので
        // UTF-8のサイズ毎のコードポイントの範囲をハードコーディングする。
        int len = 0;
        if (codepoint < 0x80) {
            // 1バイト文字は0x00..0x7Fまで
            len = 1;
        } else if (codepoint < 0x800) {
            // 2バイト文字は0x80..0x7FFまで
            len = 2;
        } else if (codepoint < 0x10000) {
            // 3バイト文字は0x800..0xFFFFまで
            len = 3;
        } else if (codepoint < 0x200000) {
            // 4バイト文字は0x10000..0x1FFFFFまで
            len = 4;
        } else {
            // 現実的に5バイト以上の文字はないと思われるが、例外をなくすために
            // 一応0x200000以上のコードポイントは5バイト文字ということにしておく。
            len = 5;
        }
        StringBuilder sb = new StringBuilder();
        if (len == 1) {
            // 1バイト文字の場合は、コードポイントの値をそのまま返値の
            // 文字列の先頭バイトに設定し、長さ1の文字列を返す。
            sb.append_c((char) codepoint);
            return sb.str;
        }
        // 2バイト以上の場合は右から6ビットごとに分割してStringBuilderに格納し、
        // 残った部分をUTF-8バイト数を表す先頭ビットに足して文字列に格納する。
        int i = len - 1;
        while (i > 0) {
            uint8 val = (uint8) (codepoint & 0x3F | 0x80);
            sb.prepend_c((char) val);
            codepoint >>= 6;
            i--;
        }
        // ~(0xFF >> len)という式はUTF-8文字のバイト数を示すビットを算出している。
        uint8 head = (uint8) (~(0xFF >> len) | codepoint);
        sb.prepend_c((char) head);
        return sb.str;
    }
}
