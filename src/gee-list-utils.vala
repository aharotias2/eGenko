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

delegate void ForeachReverseCallback<T>(T element);

void foreach_reverse<T>(Gee.BidirList<T> list, ForeachReverseCallback<T> func) {
    var iter = list.bidir_list_iterator();
    iter.last();
    while (true) {
        func(iter.get());
        if (iter.has_previous()) {
            iter.previous();
        } else {
            break;
        }
    }
}
