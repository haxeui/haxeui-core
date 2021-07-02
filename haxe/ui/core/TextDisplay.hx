package haxe.ui.core;

import haxe.ui.backend.TextDisplayImpl;
import haxe.ui.styles.Style;
import haxe.ui.validation.IValidating;
import haxe.ui.validation.InvalidationFlags;

class TextDisplayData {
    public var multiline:Bool = false;
    public var wordWrap:Bool = false;

    public function new() {
    }
}

/**
 Class that represents a framework specific method to display read-only text inside a component
**/
class TextDisplay extends TextDisplayImpl implements IValidating {

    private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _isAllInvalid:Bool = false;
    private var _isValidating:Bool = false;

    public function new() {
        super();
    }

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

        if ((value.fontName != null && _textStyle == null) || (_textStyle != null && value.fontName != _textStyle.fontName)) {
            ToolkitAssets.instance.getFont(value.fontName, function(fontInfo) {
                _fontInfo = fontInfo;
                invalidateComponent(InvalidationFlags.STYLE);
                parentComponent.invalidateComponent(InvalidationFlags.STYLE);
            });
        } else {
            invalidateComponent(InvalidationFlags.STYLE);
        }

        _textStyle = value;
        return value;
    }

    public var text(get, set):String;
    private function get_text():String {
        return _text;
    }
    private function set_text(value:String):String {
        if (value == _text) {
            return value;
        }

        _text = value;
        _htmlText = null;
        invalidateComponent(InvalidationFlags.DATA);
        return value;
    }

    public var htmlText(get, set):String;
    private function get_htmlText():String {
        return _htmlText;
    }
    private function set_htmlText(value:String):String {
        if (value == _htmlText) {
            return value;
        }

        _htmlText = value;
        _text = null;
        invalidateComponent(InvalidationFlags.DATA);
        return value;
    }

    public var left(get, set):Float;
    private function get_left():Float {
        return _left;
    }
    private function set_left(value:Float):Float {
        if (value == _left) {
            return value;
        }

        invalidateComponent(InvalidationFlags.POSITION);
        _left = value;
        return value;
    }

    public var top(get, set):Float;
    private function get_top():Float {
        return _top;
    }
    private function set_top(value:Float):Float {
        if (value == _top) {
            return value;
        }

        invalidateComponent(InvalidationFlags.POSITION);
        _top = value;
        return value;
    }

    public var width(get, set):Float;
    private function set_width(value:Float):Float {
        if (_width == value) {
            return value;
        }

        invalidateComponent(InvalidationFlags.DISPLAY);
        _width = value;
        return value;
    }

    private function get_width():Float {
        return _width;
    }

    public var height(get, set):Float;
    private function set_height(value:Float):Float {
        if (_height == value) {
            return value;
        }

        invalidateComponent(InvalidationFlags.DISPLAY);
        _height = value;
        return value;
    }

    private function get_height():Float {
        return _height;
    }

    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        if (_text == null && _htmlText == null) {
            return 0;
        }

        if (_text != null && _text.length == 0) {
            return 0;
        }

        if (_htmlText != null && _htmlText.length == 0) {
            return 0;
        }

        if (isComponentInvalid() == true) {
            validateComponent();
        }

        return _textWidth;
    }

    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
        if (_text == null && _htmlText == null) {
            return 0;
        }

        if (_text != null && _text.length == 0) {
            return 0;
        }

        if (_htmlText != null && _htmlText.length == 0) {
            return 0;
        }

        if (isComponentInvalid() == true) {
            validateComponent();
        }

        return _textHeight;
    }

    public var multiline(get, set):Bool;
    private function get_multiline():Bool {
        return _displayData.multiline;
    }
    private function set_multiline(value:Bool):Bool {
        if (value == _displayData.multiline) {
            return value;
        }

        invalidateComponent(InvalidationFlags.STYLE);
        _displayData.multiline = value;
        return value;
    }

    public var wordWrap(get, set):Bool;
    private function get_wordWrap():Bool {
        return _displayData.wordWrap;
    }
    private function set_wordWrap(value:Bool):Bool {
        if (value == _displayData.wordWrap) {
            return value;
        }

        invalidateComponent(InvalidationFlags.STYLE);
        _displayData.wordWrap = value;
        return value;
    }

    public function isComponentInvalid(flag:String = InvalidationFlags.ALL):Bool {
        if (_isAllInvalid == true) {
            return true;
        }

        if (flag == InvalidationFlags.ALL) {
            for (value in _invalidationFlags) {
                return true;
            }

            return false;
        }

        return _invalidationFlags.exists(flag);
    }

    public function invalidateComponent(flag:String = InvalidationFlags.ALL) {
        if (flag == InvalidationFlags.ALL) {
            _isAllInvalid = true;
            parentComponent.invalidateComponent(InvalidationFlags.TEXT_DISPLAY);
        } else if (!_invalidationFlags.exists(flag)) {
            _invalidationFlags.set(flag, true);
            parentComponent.invalidateComponent(InvalidationFlags.TEXT_DISPLAY);
        }
    }

    private var _depth:Int = -1;
    @:dox(hide)
    public var depth(get, set):Int;
    private function get_depth():Int {
        return _depth;
    }
    private function set_depth(value:Int):Int {
        if (_depth == value) {
            return value;
        }

        _depth = value;

        return value;
    }

    public function updateComponentDisplay() {
    }

    public function validateComponent(nextFrame:Bool = true) {
        if (_isValidating == true || isComponentInvalid() == false) {
            return;
        }

        _isValidating = true;

        validateComponentInternal();

        #if (haxe_ver < 4)
        _invalidationFlags = new Map<String, Bool>();
        #else
        _invalidationFlags.clear();
        #end

        _isAllInvalid = false;
        _isValidating = false;
    }

    private function validateComponentInternal() {
        var dataInvalid = isComponentInvalid(InvalidationFlags.DATA);
        var styleInvalid = isComponentInvalid(InvalidationFlags.STYLE);
        var positionInvalid = isComponentInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isComponentInvalid(InvalidationFlags.DISPLAY);
        var measureInvalid = isComponentInvalid(InvalidationFlags.MEASURE);

        if (dataInvalid) {
            validateData();
        }

        if (styleInvalid) {
            measureInvalid = validateStyle() || measureInvalid;
        }

        if (positionInvalid || styleInvalid) {
            validatePosition();
        }

        if (displayInvalid) {
            validateDisplay();
        }

        if (dataInvalid || displayInvalid || measureInvalid) {
            var oldTextWidth:Float = textWidth;
            var oldTextHeight:Float = textHeight;
            measureText();

            if (textWidth != oldTextWidth || textHeight != oldTextHeight) {
                parentComponent.invalidateComponent(InvalidationFlags.LAYOUT);
            }
        }
    }
}