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
    public bool is_newline_visible;
    public Gdk.RGBA newline_font;
    public bool is_space_visible;
    public Gdk.RGBA space;
}
