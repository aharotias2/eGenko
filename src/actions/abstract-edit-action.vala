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
 * このクラスはテキスト編集作業をアンドゥ可能な状態で実行するためのクラスで、
 * デザインパターンの「Template Method」パターンに近い方法でそれを実現する。
 * 
 * このクラスは抽象クラスとなっており、EditActionインターフェースの「perform」「undo」「redo」は実装している。
 * 
 * このクラスを継承して独自の処理を実装するには「process_text」メソッドをオーバーライドすること。
 * process_textはperformメソッドから呼び出され、選択範囲の周囲のテキストをコピーして渡すので
 * それを編集してtext_afterに設定する。この時text_beforeを変更しないこと。
 * 
 * またコンストラクタでこのクラスのコンストラクタを呼び出し「text」と「selection_before」フィールドを
 * 設定しないと正常には動作しないので注意すること。
 * 
 * 処理の際に共通して使用できるメソッドは「EditActionUtils」名前空間にまとめてある。
 * 
 * 以上ややこしいクラス設計であるのでもう少し良いアイディアがあれば改良する予定。
 */
public abstract class AbstractEditAction : EditAction, Object {
    private unowned Gee.List<SimpleList<TextElement>> text;
    private Region selection_before;
    private Region selection_after;
    private Region paragraph_region_before;
    private Region paragraph_region_after;
    private Gee.List<SimpleList<TextElement>> text_before;
    private Gee.List<SimpleList<TextElement>> text_after;
    private bool has_performed;
    
    /**
     * このクラスを継承するクラスはこのコンストラクタを呼び出し、textとselection_beforeを設定しないといけない。
     */
    protected AbstractEditAction(Gee.List<SimpleList<TextElement>> text, Region selection_before) {
        this.text = text;
        this.selection_before = selection_before;
        has_performed = false;
    }
    
    /**
     * このメソッドを実装して「text_before」をコピーして編集し、「text_after」に格納する。
     * 戻り値は編集が終わった時の選択範囲の位置を設定する。
     * 
     * local_selection_beforeはコンストラクタのselection_before.start.hposからの相対位置になる。
     * selection_beforeが3行目開始の場合、textの3行目から切り出しtext_beforeに設定する。
     * その為local_selection_before.start.hposは必ず0になる。
     */
    protected abstract Region process_text(Gee.List<SimpleList<TextElement>> text_before,
            Region local_selection_before, out Gee.List<SimpleList<TextElement>> text_after);
    
    /**
     * テキスト編集処理を実行する。
     * 抽象メソッドのprocess_textを呼び出す。
     * 呼び出し側のtextを変化させる (副作用あり)
     */
    public Region perform() {
        paragraph_region_before = paragraph_containing_region(this.text, selection_before);
        var local_selection_before = selection_before.subtract_hpos(paragraph_region_before.start.hpos);
        text_before = copy_paragraphs(this.text, paragraph_region_before);
        var local_selection_after = process_text(text_before, local_selection_before, out text_after);
        selection_after = local_selection_after.add_hpos(paragraph_region_before.start.hpos);
        paragraph_region_after = {
            {paragraph_region_before.start.hpos, 0},
            {paragraph_region_before.start.hpos + text_after.size, 0}
        };
        has_performed = true;
        return redo();
    }

    /**
     * アンドゥ処理は、performが実行された時に保存されたtext_afterをtext_beforeに入れ替える。
     * こちらのメソッドも当然副作用あり (呼出側のtextを変更する)
     */
    public Region undo() requires(has_performed) {
        text.remove_all(text[paragraph_region_after.start.hpos:paragraph_region_after.last.hpos]);
        text.insert_all(paragraph_region_before.start.hpos, text_before);
        return selection_before;
    }
    
    /**
     * リドゥ処理は、performが実行された時に保存されたtext_beforeをtext_afterに入れ替える。
     * こちらのメソッドも当然副作用あり (呼出側のtextを変更する)
     */
    public Region redo() requires(has_performed) {
        text.remove_all(text[paragraph_region_before.start.hpos:paragraph_region_before.last.hpos]);
        text.insert_all(paragraph_region_after.start.hpos, text_after);
        return selection_after;
    }

    /**
     * paragraph_regionが示す範囲をtextからコピーする。
     * コピー範囲はparagraph_region.start.hposからparagraph_region.last.hpos - 1までのインデックスを指定する。
     */
    protected static Gee.List<SimpleList<TextElement>> copy_paragraphs(Gee.List<SimpleList<TextElement>> text,
            Region paragraph_region) {
        var result = new Gee.ArrayList<SimpleList<TextElement>>();
        for (int i = paragraph_region.start.hpos; i < paragraph_region.last.hpos; i++) {
            result.add(text[i].copy_all());
        }
        return result;
    }

    /**
     * copy_paragraphsメソッドで使用するtextのコピー範囲を返す。
     * 引数のregionは画面上の選択範囲・カーソル位置を想定し、
     * region.start.hposの行からregion.last.hpos + 1の行から次の改行までを選択する。
     * 次の改行がなくファイル終端に達した場合はファイル終端までをコピーする。
     */
    protected static Region paragraph_containing_region(Gee.List<SimpleList<TextElement>> text, Region region)
            requires(text.size > 0) {
        region = region.asc_order();
        var result = Region();
        if (region.start.hpos < text.size) {
            result.start = {region.start.hpos, 0};
        } else {
            result.start = {text.size - 1, 0};
        }
        if (region.last.hpos == text.size - 1) {
            result.last = {text.size, 0};
        } else if (region.last.hpos >= text.size) {
            result.last = {text.size, 0};
        } else {
            for (result.last = {region.last.hpos + 1, 0};;) {
                if (result.last.hpos == text.size - 1) {
                    result.last.hpos++;
                    break;
                } else if (text[result.last.hpos].get_last().str == "\n") {
                    result.last.hpos++;
                    break;
                } else {
                    result.last.hpos++;
                }
            }
        }
        return result;
    }
}
