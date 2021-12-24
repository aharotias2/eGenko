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

public class GenkoYoshiApp : Gtk.Application {
    public GenkoYoshiApp() {
        Object(
            application_id: APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }
    
    private void quit_application() {
        quit();
    }
    
    public override void activate() {
        var window = new GenkoyoshiAppWindow(this);
        window.require_quit.connect(() => {
            quit_application();
        });
    }

    private static void setup_locale() {
        Intl.setlocale(LocaleCategory.ALL, Environment.get_variable("LANG"));
        Intl.bindtextdomain(APP_ID, DATADIR + "/locale");
        Intl.bind_textdomain_codeset(APP_ID, "UTF-8");
        Intl.textdomain(APP_ID);
    }
            
    public static int main(string[] argv) {
        setup_locale();
        var app = new GenkoYoshiApp();
        return app.run();
    }
}
