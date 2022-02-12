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

namespace PresetColorSetting {
    const ColorSetting THEME_DEFAULT = {
        { 1.0, 1.0, 1.0, 1.0 }, // background
        { 0.1, 0.1, 0.1, 1.0 }, // font
        { 0.7, 0.7, 0.0, 1.0 }, // border
        { 0.5, 0.5, 1.0, 1.0 }, // selection_border
        { 0.95, 0.95, 1.0, 1.0 }, // selection_bg
        { 0.5, 0.5, 0.0, 1.0 }, // preedit_font
        { 0.5, 0.5, 1.0, 1.0 }, // newline_font
        { 0.5, 0.5, 1.0, 1.0 } // space
    };

    const ColorSetting THEME_DARK = {
        { 0.3, 0.3, 0.3, 1.0 }, // background
        { 0.9, 0.9, 0.9, 1.0 }, // font
        { 0.6, 0.6, 0.8, 1.0 }, // border
        { 0.5, 0.5, 1.0, 1.0 }, // selection_border
        { 0.4, 0.4, 0.3, 1.0 }, // selection_bg
        { 1.0, 1.0, 0.8, 1.0 }, // preedit_font
        { 0.5, 0.5, 1.0, 1.0 }, // newline_font
        { 0.5, 0.5, 1.0, 1.0 } // space
    };

    const ColorSetting THEME_CONSOLE = {
        { 0.05, 0.05, 0.05, 1.0 }, // background
        { 0.8, 0.9, 0.3, 1.0 }, // font
        { 0.1, 0.1, 0.1, 1.0 }, // border
        { 0.5, 0.5, 1.0, 1.0 }, // selection_border
        { 0.4, 0.4, 0.3, 1.0 }, // selection_bg
        { 1.0, 1.0, 1.0, 1.0 }, // preedit_font
        { 0.3, 0.5, 0.9, 1.0 }, // newline_font
        { 0.3, 0.5, 0.9, 1.0 } // space
    };
}

