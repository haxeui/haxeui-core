package haxe.ui.core;

import haxe.ui.backend.TextInputBase;
import haxe.ui.styles.Style;

/**
 Class that represents a framework specific method to display editable text inside a component
**/
class TextInput extends TextInputBase {
    public function new() {
        super();
    }

    private var _textStyle:Style;
    /**
     The style to use for this text
    **/
    public var textStyle(get, set):Style;
    private function get_textStyle():Style {
        return _textStyle;
    }

    private function set_textStyle(value:Style):Style {
        if (value == null) {
            return value;
        }

        applyStyle(value);

        return value;
    }
}