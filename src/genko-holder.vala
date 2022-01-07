public class GenkoHolder : Gtk.Bin {
    public const string MESSAGE_NO_FILE_SPECIFIED = "ファイルが指定されていません。";
    public GenkoYoshi genkoyoshi { get; set; }

    public bool has_file { get; private set; default = false; }

    public string get_filename() throws AppError {
        if (has_file) {
            return file.get_basename();
        } else {
            throw new AppError.NO_FILE_SPECIFIED(MESSAGE_NO_FILE_SPECIFIED);
        }
    }

    public string get_filepath() throws AppError {
        if (has_file) {
            return file.get_path();
        } else {
            throw new AppError.NO_FILE_SPECIFIED(MESSAGE_NO_FILE_SPECIFIED);
        }
    }

    public void set_filepath(string new_filepath) {
        file = File.new_for_path(new_filepath);
        has_file = true;
    }

    public string get_dirname() throws AppError {
        if (has_file) {
            return file.get_parent().get_path();
        } else {
            throw new AppError.NO_FILE_SPECIFIED(MESSAGE_NO_FILE_SPECIFIED);
        }
    }

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

    public GenkoHolder.with_genkoyoshi(GenkoYoshi genkoyoshi) {
        this.genkoyoshi = genkoyoshi;
        add(genkoyoshi);
    }

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
