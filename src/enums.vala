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

public enum Availability {
    ENABLED,
    DISABLED
}

public enum ConvType {
    UPRIGHT,
    ROTATE,
    NORMAL;
    
    public static ConvType from_string(string str) {
        switch (str) {
          case "Tr":
            return ROTATE;
          case "Tu":
            return UPRIGHT;
          case "Normal":
            return NORMAL;
          default:
            assert_not_reached();
        }
    }
    
    public string to_string() {
        switch (this) {
          case UPRIGHT:
            return "Tu";
          case ROTATE:
            return "Tr";
          case NORMAL: default:
            return "Normal";
        }
    }
}

public enum EditMode {
    DIRECT_INPUT,
    PREEDITING
}

public enum SaveMode {
    OVERWRITE,
    RENAME
}

public enum WrapMode {
    WRAP,
    NOWRAP
}
