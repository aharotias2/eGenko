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
 * 原稿用紙ウィジェットにファイルを紐付けるためのウィジェット・クラス。
 * 原稿用紙ウィジェットからファイル管理処理を分離するために作成した。
 */
public class GenkoHolder : Gtk.Bin {
    public const string MESSAGE_NO_FILE_SPECIFIED = "ファイルが指定されていません。";
    public GenkoYoshi genkoyoshi { get; set; }

    /**
     * 原稿用紙にファイルが紐付いている場合にはtrueを、ファイルが紐付いていない場合にはfalseを返す。
     */
    public bool has_file { get; private set; default = false; }

    /**
     * 原稿用紙にファイルが紐付いている場合には、そのファイル名 (ディレクトリを含まない) を返す
     * ファイルがない場合は例外を投げる。
     */
    public string get_filename() throws AppError {
        if (has_file) {
            return file.get_basename();
        } else {
            throw new AppError.NO_FILE_SPECIFIED(MESSAGE_NO_FILE_SPECIFIED);
        }
    }

    /**
     * 原稿用紙にファイルが紐付いている場合には、そのファイルパス (ディレクトリを含む) を返す
     * ファイルがない場合は例外を投げる。
     */
    public string get_filepath() throws AppError {
        if (has_file) {
            return file.get_path();
        } else {
            throw new AppError.NO_FILE_SPECIFIED(MESSAGE_NO_FILE_SPECIFIED);
        }
    }

    /**
     * 原稿用紙にファイルを紐付ける。
     * このメソッド呼び出し後、has_fileはtrueを返すようになる。
     */
    public void set_filepath(string new_filepath) {
        file = File.new_for_path(new_filepath);
        has_file = true;
    }

    /**
     * 原稿用紙にファイルが紐付いている場合には、そのディレクトリパスを返す
     * ファイルがない場合は例外を投げる。
     */
    public string get_dirname() throws AppError {
        if (has_file) {
            return file.get_parent().get_path();
        } else {
            throw new AppError.NO_FILE_SPECIFIED(MESSAGE_NO_FILE_SPECIFIED);
        }
    }

    /**
     * 原稿用紙に紐付けたファイルが存在していることを確認する。
     * 存在する場合にはtrueを、存在しない場合にはfalseを返す。
     */
    public bool file_exists() throws AppError {
        if (has_file) {
            return file.query_exists();
        } else {
            throw new AppError.NO_FILE_SPECIFIED(MESSAGE_NO_FILE_SPECIFIED);
        }
    }

    public signal void require_context_menu(Gdk.EventButton event);
    public signal void page_changed(int page, int total_page);

    private File file;

    /**
     * 引数無しでコンストラクタを使う場合、ファイルに紐付かない、空の
     * 原稿用紙を内部で生成する。
     */
    public GenkoHolder() {
        genkoyoshi = new GenkoYoshi();
        genkoyoshi.require_context_menu.connect((event) => {
            require_context_menu(event);
        });
        genkoyoshi.page_changed.connect((page, total_pages) => {
            page_changed(page, total_pages);
        });
        add(genkoyoshi);
    }

    /**
     * 原稿用紙ウィジェットを外部から設定する場合にはこのコンストラクタを使う。
     */
    public GenkoHolder.with_genkoyoshi(GenkoYoshi genkoyoshi) {
        this.genkoyoshi = genkoyoshi;
        add(genkoyoshi);
    }

    /**
     * 最初からファイルを紐付ける場合にはこのコンストラクタを使う。
     */
    public GenkoHolder.with_file(File file) {
        this.file = file;
        genkoyoshi = new GenkoYoshi.with_model(new TextModel.from_file(file));
        genkoyoshi.require_context_menu.connect((event) => {
            require_context_menu(event);
        });
        genkoyoshi.page_changed.connect((page, total_pages) => {
            page_changed(page, total_pages);
        });
        add(genkoyoshi);
    }
}
