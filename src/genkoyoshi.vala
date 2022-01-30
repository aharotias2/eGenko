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
 * 原稿用紙をウィジェット。
 * 画面の描画と、ボタン押下イベント、キー入力イベントを処理する。
 */
public class GenkoYoshi : Gtk.DrawingArea {
    /**
     * コンテキストメニューの表示を要求する。
     */
    public signal void require_context_menu(Gdk.EventButton event);

    public signal void page_changed(int page, int total_pages);

    /**
     * ページ
     */
    public int page { get; set; default = 0; }

    /**
     * 原稿用紙を描画する際に使うフォントの設定
     */
    public FontSetting font { get; set; default = FontSetting() {
            name = "Sans Regular 10",
            family = "Sans",
            weight = NORMAL,
            style = NORMAL
        };
    }

    /**
     * 原稿用紙を描画する際に使うカラーパレットのようなもの。
     */
    public ColorSetting color { get; set; default = ColorSetting() {
            background = { 1.0, 1.0, 1.0, 1.0 },
            font = { 0.1, 0.1, 0.1, 1.0 },
            border = { 0.7, 0.7, 0.0, 1.0 },
            selection_border = { 0.5, 0.5, 1.0, 1.0 },
            selection_bg = { 0.95, 0.95, 1.0, 1.0 },
            preedit_font = { 0.5, 0.5, 0.0, 1.0 },
            is_newline_visible = true,
            newline_font = { 0.5, 0.5, 1.0, 1.0 },
            is_space_visible = true,
            space = { 0.5, 0.5, 1.0, 1.0 }
        };
    }

    /**
     * テキスト編集処理を行うオブジェクト。
     * GenkoyoshiクラスではこのTextModelの描画とイベント処理に徹するようにする。
     */
    public TextModel model {
        get {
            return model_value;
        }
        set {
            model_value = value;
            model_value.changed.connect(() => {
                queue_draw();
            });
            model_value.cursor_moved.connect((cursor_position) => {
                int new_page = cursor_position.hpos / X_LENGTH;
                set_preedit_location();
                debug("cursor_moved to {%d, %d}", cursor_position.hpos, cursor_position.vpos);
                if (new_page != page) {
                    page = new_page;
                    page_changed(page, model_value.count_pages());
                }
                queue_draw();
            });
        }
    }

    private Gtk.IMContext im;
    private TextModel model_value;
    private int cell_width = 20;
    private int side_width = 5;
    private int separator_width = 20;
    private int padding_left = 0;
    private int padding_top = 0;
    private int border_width = 1;
    private int saved_width = 0;
    private int saved_height = 0;
    private Gdk.Point[,] position;
    private bool is_fit_to_window = true;
    private bool is_button_pressed = false;

    public GenkoYoshi() {
        model = new TextModel();
        init();
    }

    public GenkoYoshi.with_model(TextModel model) {
        this.model = model;
        init();
    }

    /**
     * 初期化処理
     * 入力メソッドのイベントの初期化等を行う。
     */
    private void init() {
        can_focus = true;
        focus_on_click = true;

        im = new Gtk.IMMulticontext();
        {
            im.set_use_preedit(true);
            im.set_client_window(get_window());
            im.preedit_start.connect(() => {
                model.start_preedit();
            });
            im.preedit_end.connect(() => {
                model.end_preedit();
            });
            im.preedit_changed.connect(() => {
                Pango.AttrList attrs;
                string preedit_string;
                int cursor_pos;
                im.get_preedit_string(out preedit_string, out attrs, out cursor_pos);
                model.preedit_changed(preedit_string);
                queue_draw();
            });
            im.commit.connect((new_text) => {
                model.insert_string(new_text);
                queue_draw();
            });
        }

        position = new Gdk.Point[X_LENGTH, Y_LENGTH];

        is_fit_to_window = true;

        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                  | Gdk.EventMask.BUTTON_RELEASE_MASK
                  | Gdk.EventMask.POINTER_MOTION_MASK
                  | Gdk.EventMask.KEY_PRESS_MASK
                  | Gdk.EventMask.LEAVE_NOTIFY_MASK
                  | Gdk.EventMask.ENTER_NOTIFY_MASK
                  | Gdk.EventMask.FOCUS_CHANGE_MASK);
    }

    /**
     * 次のページに移動する。
     */
    public void next_page() {
        page++;
        page_changed(page, model_value.count_pages());
        model.set_cursor({model.get_selection_last().hpos + X_LENGTH, model.get_selection_last().vpos});
        queue_draw();
    }

    /**
     * 前のページに移動する。
     */
    public void prev_page() {
        if (page > 0) {
            page--;
            page_changed(page, model_value.count_pages());
            model.set_cursor({model.get_selection_last().hpos - X_LENGTH, model.get_selection_last().vpos});
            queue_draw();
        }
    }

    /**
     * サイズが変更された時の処理。
     */
    public override void size_allocate(Gtk.Allocation allocation) {
        base.size_allocate(allocation);
        if (allocation.width == saved_width && allocation.height == saved_height) {
            return;
        } else {
            saved_width = allocation.width;
            saved_height = allocation.height;
        }
        debug("GenkoYoshi size allocated.");
        debug("New allocation: x = %d, y = %d, width = %d, height = %d", allocation.x, allocation.y, allocation.width, allocation.height);
        if (is_fit_to_window) {
            debug("GenkoYoshi is fit to this window.");
            double rate1 = 2.0 / 3.1;
            double rate2 = (double) allocation.height / (double) allocation.width;
            if (rate1 < rate2) {
                cell_width = allocation.width / 35;
            } else {
                cell_width = allocation.height / 25;
            }
            side_width = cell_width / 2;
            separator_width = cell_width;
            padding_left = (
                    allocation.width
                    - (
                        (
                            cell_width
                            + border_width
                        )
                        * X_LENGTH
                        + (
                            side_width
                            + border_width
                        )
                        * X_LENGTH
                        + separator_width
                        + border_width
                    )
                )
                / 2;
            padding_top = (
                    allocation.height
                    - (
                        (
                            cell_width
                            + border_width
                        )
                        * Y_LENGTH
                        + border_width
                    )
                )
                / 2;
            position[X_LENGTH - 1, 0] = { padding_left, padding_top };
            for (int i = X_LENGTH - 1; i >= 0; i--) {
                for (int j = 0; j < Y_LENGTH; j++) {
                    if (i == X_LENGTH - 1 && j == 0) {
                        continue;
                    }
                    if (i == 19) {
                        position[i, j].x = padding_left;
                    } else if (i == 9) {
                        position[i, j].x = border_width
                                + separator_width
                                + position[i + 1, j].x
                                + border_width
                                + cell_width
                                + border_width
                                + side_width;
                    } else {
                        position[i, j].x = position[i + 1, j].x
                                + border_width
                                + cell_width
                                + border_width
                                + side_width;
                    }
                    if (j == 0) {
                        position[i, j].y = padding_top;
                    } else {
                        position[i, j].y = position[i, j - 1].y + border_width + cell_width;
                    }
                }
            }
            debug("padding_left: %d, padding_top: %d, cell_width: %d, border_width: %d, side_width: %d, separator_width: %d",
                    padding_left, padding_top, cell_width, border_width, side_width, separator_width);

        }
        queue_draw();
    }

    /**
     * 描画イベントの処理
     */
    public override bool draw(Cairo.Context cairo) {
        Gtk.Allocation allocation;
        get_allocation(out allocation);

        cairo.set_source_rgba(color.background.red, color.background.green, color.background.blue, color.background.alpha);
        cairo.rectangle(0.0, 0.0, get_allocated_width(), get_allocated_height());
        cairo.fill();

        cairo.set_source_rgba(color.border.red, color.border.green, color.border.blue, color.border.alpha);
        cairo.set_line_width(border_width * 2);

        cairo.rectangle(
            (double) position[X_LENGTH - 1, 0].x - (double) cell_width * 0.15,
            (double) position[X_LENGTH - 1, 0].y - (double) cell_width * 0.15,
            (double) (position[0, Y_LENGTH - 1].x + cell_width + border_width + side_width - padding_left) + border_width + (double) cell_width * 0.3,
            (double) (position[0, Y_LENGTH - 1].y + cell_width - padding_top + border_width + (double) cell_width * 0.3)
        );
        cairo.stroke();

        cairo.set_line_width(border_width);

        cairo.rectangle(
            (double) position[X_LENGTH - 1, 0].x,
            (double) position[X_LENGTH - 1, 0].y,
            (double) (position[0, Y_LENGTH - 1].x + cell_width + border_width + side_width - padding_left),
            (double) (position[0, Y_LENGTH - 1].y + cell_width - padding_top)
        );
        cairo.stroke();

        for (int v = X_LENGTH - 1; v >= 0; v--) {
            if (v == 10) {
                cairo.move_to(
                    (double) position[v, 0].x + cell_width + border_width + side_width,
                    (double) position[v, 0].y
                );
                cairo.line_to(
                    (double) position[v, Y_LENGTH - 1].x + cell_width + border_width + side_width,
                    (double) (position[v, Y_LENGTH - 1].y + cell_width)
                );
                cairo.stroke();
            }
            if (v < X_LENGTH - 1) {
                cairo.move_to(
                    (double) position[v, 0].x,
                    (double) position[v, 0].y
                );
                cairo.line_to(
                    (double) position[v, Y_LENGTH - 1].x,
                    (double) (position[v, Y_LENGTH - 1].y + cell_width)
                );
                cairo.stroke();
            }
            cairo.move_to(
                (double) position[v, 0].x + cell_width,
                (double) position[v, 0].y
            );
            cairo.line_to(
                (double) position[v, Y_LENGTH - 1].x + cell_width,
                (double) position[v, Y_LENGTH - 1].y + cell_width
            );
            cairo.stroke();
            for (int h = 1; h < Y_LENGTH; h++) {
                cairo.move_to(
                    (double) position[v, h].x,
                    (double) position[v, h].y
                );
                cairo.line_to(
                    (double) position[v, h].x + cell_width,
                    (double) position[v, h].y
                );
                cairo.stroke();
            }
        }

        // 中央のアクセントを描画する
        draw_accent(cairo);

        // 選択範囲を描画
        draw_selection(cairo);

        try {
            // 文字を描画する
            draw_text(cairo);
        } catch (AppError e) {
            printerr("%s\n", e.message);
            Process.exit(e.code);
        }

        return true;
    }

    /**
     * 選択範囲、またはカーソルを描画する。
     */
    private void draw_selection(Cairo.Context cairo) {
        cairo.save();
        cairo.set_line_width(3.0);
        for (int h = 0; h < Y_LENGTH; h++) {
            for (int v = 0; v < X_LENGTH; v++) {
                if (model.is_in_selection({page * X_LENGTH + h, v})) {
                    cairo.rectangle(
                        position[h, v].x,
                        position[h, v].y,
                        cell_width,
                        cell_width
                    );
                    cairo.set_source_rgba(
                        color.selection_bg.red,
                        color.selection_bg.green,
                        color.selection_bg.blue,
                        color.selection_bg.alpha
                    );
                    cairo.fill();
                    cairo.set_source_rgba(
                        color.selection_border.red,
                        color.selection_border.green,
                        color.selection_border.blue,
                        color.selection_border.alpha
                    );
                    cairo.move_to(
                        position[h, v].x + cell_width,
                        position[h, v].y - 1.5
                    );
                    cairo.line_to(
                        position[h, v].x + cell_width,
                        position[h, v].y + cell_width + 1.5
                    );
                    cairo.move_to(
                        position[h, v].x,
                        position[h, v].y - 1.5
                    );
                    cairo.line_to(
                        position[h, v].x,
                        position[h, v].y + cell_width + 1.5
                    );
                    if (v == 0 || !model.is_in_selection({page * X_LENGTH + h, v - 1})) {
                        cairo.set_line_width(3.0);
                        cairo.move_to(
                            position[h, v].x - 1.5,
                            position[h, v].y
                        );
                        cairo.line_to(
                            position[h, v].x + cell_width + 1.5,
                            position[h, v].y
                        );
                    }
                    if (v == Y_LENGTH - 1 || !model.is_in_selection({page * X_LENGTH + h, v + 1})) {
                        cairo.set_line_width(3.0);
                        cairo.move_to(
                            position[h, v].x - 1.5,
                            position[h, v].y + cell_width
                        );
                        cairo.line_to(
                            position[h, v].x + cell_width + 1.5,
                            position[h, v].y + cell_width
                        );
                    }

                    cairo.stroke();
                }
            }
        }
        cairo.restore();
    }

    /**
     * 原稿用紙中央のアクセントを描画する。
     */
    private void draw_accent(Cairo.Context cairo) {
        double x0 = position[10, 3].x + border_width + cell_width + border_width + side_width + 2;
        double y0 = position[10, 3].y + cell_width / 2;
        double x1 = x0 + separator_width - 4;
        double y1 = y0;
        double x2 = x1;
        double y2 = y1 + get_allocated_height() * 0.015;
        double x3 = x0 + (separator_width - 4) / 2;
        double y3 = y0 + (y2 - y1) / 2;
        double x4 = x0;
        double y4 = y2;
        double y6 = y0 - get_allocated_height() * 0.003;

        cairo.set_line_width(0.0);

        cairo.move_to(x0, y0);
        cairo.line_to(x1, y1);
        cairo.line_to(x2, y2);
        cairo.line_to(x3, y3);
        cairo.line_to(x4, y4);
        cairo.fill();

        double y5 = position[10, 13].y + cell_width / 2;
        cairo.set_line_width(1.0);

        cairo.move_to(x0, y6);
        cairo.line_to(x1, y6);
        cairo.stroke();

        cairo.set_line_width(2.0);

        cairo.move_to(x0, y5);
        cairo.line_to(x1, y5);
        cairo.stroke();
    }

    private void draw_text(Cairo.Context cairo) throws AppError {
        cairo.save();
        cairo.select_font_face(font.family, font.style, font.weight);
        cairo.set_font_size((double) cell_width * 0.7);
        cairo.set_source_rgba(color.font.red, color.font.green, color.font.blue, color.font.alpha);
        cairo.set_line_width(1.0);
        for (int x = 0; x < X_LENGTH; x++) {
            for (int y = 0; y < Y_LENGTH; y++) {
                TextElement? elem = model.get_element(page * X_LENGTH + x, y);
                if (elem == null) {
                    continue;
                } else {
                    if (elem.is_preedit) {
                        cairo.set_source_rgba(color.preedit_font.red, color.preedit_font.green, color.preedit_font.blue, color.preedit_font.alpha);
                    }
                    cairo.move_to(
                        position[x, y].x + cell_width * 0.15,
                        position[x, y].y + cell_width * 0.85
                    );
                    if (elem.str == "\n") {
                        // 改行文字を表示する処理
                        // is_newline_visibleが設定されている場合は改行を表示する。
                        if (color.is_newline_visible) {
                            cairo.set_source_rgba(color.newline_font.red, color.newline_font.green, color.newline_font.blue, color.newline_font.alpha);
                            cairo.show_text("←");
                            cairo.set_source_rgba(color.font.red, color.font.green, color.font.blue, color.font.alpha);
                            continue;
                        }
                    } else if (elem.str == "　") {
                        // 空白文字を表示する処理
                        // is_space_visibleが設定されている場合は空白文字を表示する。
                        if (color.is_space_visible) {
                            cairo.set_source_rgba(color.space.red, color.space.green, color.space.blue, color.space.alpha);
                            cairo.show_text("□");
                            cairo.set_source_rgba(color.font.red, color.font.green, color.font.blue, color.font.alpha);
                            continue;
                        }
                    } else if (elem.str == " ") {
                        // 半角空白文字を表示する処理
                        // is_space_visibleが設定されている場合は空白文字を表示する。
                        if (color.is_space_visible) {
                            cairo.set_source_rgba(color.space.red, color.space.green, color.space.blue, color.space.alpha);
                            cairo.rectangle(
                                position[x, y].x + cell_width * 0.25,
                                position[x, y].y + cell_width * 0.25,
                                cell_width * 0.25,
                                cell_width * 0.50
                            );
                            cairo.stroke();
                            cairo.set_source_rgba(color.font.red, color.font.green, color.font.blue, color.font.alpha);
                            continue;
                        }
                    } else {
                        switch (elem.conv_type) {
                          case ROTATE:
                            // 文字を時計回り90°回転して位置を上手い具合に調整する処理
                            // この辺がちょうどいいっぽい。
                            cairo.rel_move_to(
                                cell_width * 0.1, -(cell_width * 0.65)
                            );
                            cairo.rotate(Math.PI * 0.5);
                            cairo.show_text(elem.str);
                            cairo.rotate(Math.PI * 3.5);
                            break;
                          case UPRIGHT:
                            // セルの右上に寄せる文字の処理
                            Cairo.TextExtents extents;
                            cairo.text_extents(elem.str, out extents);
                            // 位置を上手い具合に調整する。
                            cairo.move_to(
                                position[x, y].x + cell_width * 0.85 - extents.width - extents.x_bearing,
                                position[x, y].y + cell_width * 0.15 + extents.height
                            );
                            cairo.show_text(elem.str);
                            break;
                          case NORMAL:
                            // そのまま文字を表示する処理
                            cairo.show_text(elem.str);
                            break;
                        }
                    }
                    if (elem.is_preedit) {
                        // 文字の色を下に戻す
                        cairo.set_source_rgba(color.font.red, color.font.green, color.font.blue, color.font.alpha);
                    }
                }
            }
        }

        cairo.restore();
    }

    /**
     * マウスボタン押下時イベント処理
     *
     * カーソル移動を行う
     */
    public override bool button_press_event(Gdk.EventButton event) {
        if (!is_focus) {
            grab_focus();
        }
        if (event.button == Gdk.BUTTON_SECONDARY) {
            require_context_menu(event);
        } else {
            is_button_pressed = true;
            for (int x = 0; x < X_LENGTH; x++) {
                for (int y = 0; y < Y_LENGTH; y++) {
                    if (position[x, y].x <= event.x && event.x < position[x, y].x + cell_width
                            && position[x, y].y <= event.y && event.y < position[x, y].y + cell_width) {
                        model.set_cursor({page * X_LENGTH + x, y});
                        im.reset();
                        queue_draw();
                        return false;
                    }
                }
            }
        }
        return false;
    }

    /**
     * マウスボタンが離された時の処理
     *
     * 選択範囲の変更処理を行う
     */
    public override bool button_release_event(Gdk.EventButton event) {
        is_button_pressed = false;
        for (int x = 0; x < X_LENGTH; x++) {
            for (int y = 0; y < Y_LENGTH; y++) {
                if (position[x, y].x <= event.x && event.x < position[x, y].x + cell_width
                        && position[x, y].y <= event.y && event.y < position[x, y].y + cell_width) {
                    model.set_selection_last({page * X_LENGTH + x, y});
                    queue_draw();
                    return false;
                }
            }
        }
        return false;
    }

    public override bool enter_notify_event(Gdk.EventCrossing event) {
        return true;
    }

    public override bool leave_notify_event(Gdk.EventCrossing event) {
        is_button_pressed = false;
        return false;
    }

    public override bool motion_notify_event(Gdk.EventMotion event) {
        if (is_button_pressed) {
            for (int x = 0; x < X_LENGTH; x++) {
                for (int y = 0; y < Y_LENGTH; y++) {
                    if (position[x, y].x <= event.x && event.x < position[x, y].x + cell_width
                            && position[x, y].y <= event.y && event.y < position[x, y].y + cell_width) {
                        model.set_selection_last({x, y});
                        queue_draw();
                        return false;
                    }
                }
            }

            queue_draw();
        }
        return false;
    }

    public override bool focus_in_event(Gdk.EventFocus event) {
        im.focus_in();
        return true;
    }

    public override bool focus_out_event(Gdk.EventFocus event) {
        im.focus_out();
        return true;
    }

    public override bool key_press_event(Gdk.EventKey event) {
        if (!is_focus) {
            grab_focus();
        }
        bool is_shift_masked = SHIFT_MASK in event.state;
        if (CONTROL_MASK in event.state) {
            switch (event.keyval) {
              case Gdk.Key.Up:
                model.move_to_beginning_of_line();
                break;
              case Gdk.Key.Down:
                model.move_to_end_of_line();
                break;
              case Gdk.Key.Right:
                model.move_to_rightend_of_page(page);
                break;
              case Gdk.Key.Left:
                model.move_to_leftend_of_page(page);
                break;
              default:
                return im.filter_keypress(event);
            }
            return false;
        } else {
            if (model.edit_mode == PREEDITING) {
                im.filter_keypress(event);
            } else {
                switch (event.keyval) {
                  case Gdk.Key.Up:
                    model.move_backward(1, is_shift_masked);
                    break;
                  case Gdk.Key.Down:
                    model.move_foreward(1, is_shift_masked);
                    break;
                  case Gdk.Key.Right:
                    model.move_to_right(1, is_shift_masked);
                    break;
                  case Gdk.Key.Left:
                    model.move_to_left(1, is_shift_masked);
                    break;
                  case Gdk.Key.Page_Down:
                    next_page();
                    break;
                  case Gdk.Key.Page_Up:
                    prev_page();
                    break;
                  case Gdk.Key.BackSpace:
                    model.delete_char_backward();
                    break;
                  case Gdk.Key.Delete:
                    model.delete_char();
                    break;
                  case Gdk.Key.Return:
                    model.insert_newline();
                    break;
                  default:
                    return im.filter_keypress(event);
                }
            }
        }
        return true;
    }

    private void set_preedit_location() {
        var region = model.get_selection();
        var pixel_position = position[region.start.hpos, region.start.vpos];
        debug("set_preedit_location: [%d, %d, %d, %d]",
                pixel_position.x, pixel_position.y, cell_width, cell_width);
        var rect = Gdk.Rectangle() {
            x = pixel_position.x,
            y = pixel_position.y,
            width = cell_width,
            height = cell_width
        };
        im.set_cursor_location(rect);
    }
}
