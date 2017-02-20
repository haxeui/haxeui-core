package haxe.ui.core;

import haxe.ui.validation.InvalidationFlags;
import haxe.ui.backend.TextDisplayBase;
import haxe.ui.styles.Style;

/**
 Class that represents a framework specific method to display read-only text inside a component
**/
class TextDisplay extends TextDisplayBase {

    private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _isAllInvalid:Bool = false;
    private var _isValidating:Bool = false;

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

        if (value.color != null) {
            color = value.color;
        }

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

        invalidate(InvalidationFlags.DATA);
        _text = value;
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

        invalidate(InvalidationFlags.POSITION);
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

        invalidate(InvalidationFlags.POSITION);
        _top = value;
        return value;
    }

    public var width(get, set):Float;
    public function set_width(value:Float):Float {
        if (_width == value) {
            return value;
        }

        invalidate(InvalidationFlags.DISPLAY);
        _width = value;
        return value;
    }

    public function get_width():Float {
        return _width;
    }

    public var height(get, set):Float;
    public function set_height(value:Float):Float {
        if (_height == value) {
            return value;
        }

        invalidate(InvalidationFlags.DISPLAY);
        _height = value;
        return value;
    }

    public function get_height():Float {
        return _height;
    }

    public var textWidth(get, null):Float;
    private function get_textWidth():Float {
        if (_text == null || _text.length == 0) {
            return 0;
        }

        if (isInvalid() == true) {
            validate();
        }

        return _textWidth;
    }

    public var textHeight(get, null):Float;
    private function get_textHeight():Float {
//        if (_text == null || _text.length == 0) {
//            return 0;
//        }

        if (isInvalid() == true) {
            validate();
        }
        return _textHeight;
    }

    public var color(get, set):Int;
    private function get_color():Int {
        return _color;
    }
    private function set_color(value:Int):Int {
        if (_color == value) {
            return value;
        }

        invalidate(InvalidationFlags.STYLE);
        _color = value;
        return value;
    }

    private static var ADDED_FONTS:Map<String, String> = new Map<String, String>();

    public var fontName(get, set):String;
    private function get_fontName():String {
        return _fontName;
    }
    private function set_fontName(value:String):String {
        if (_fontName == value) {
            return value;
        }

        invalidate(InvalidationFlags.STYLE);
        _fontName = value;
        return value;
    }

    public var fontSize(get, set):Null<Float>;
    private function get_fontSize():Null<Float> {
        return _fontSize;
    }
    private function set_fontSize(value:Null<Float>):Null<Float> {
        if (_fontSize == value) {
            return value;
        }

        invalidate(InvalidationFlags.STYLE);
        _fontSize = value;
        return value;
    }

    public var textAlign(get, set):Null<String>;
    private function get_textAlign():Null<String> {
        return _textAlign;
    }
    private function set_textAlign(value:Null<String>):Null<String> {
        if (_textAlign == value) {
            return value;
        }

        invalidate(InvalidationFlags.STYLE);
        _textAlign = value;
        return value;
    }

    public var multiline(get, set):Bool;
    private function get_multiline():Bool {
        return _multiline;
    }
    private function set_multiline(value:Bool):Bool {
        if (value == _multiline) {
            return value;
        }

        invalidate(InvalidationFlags.STYLE);
        _multiline = value;
        return value;
    }

    public var wordWrap(get, set):Bool;
    private function get_wordWrap():Bool {
        return _wordWrap;
    }
    private function set_wordWrap(value:Bool):Bool {
        if (value == _wordWrap) {
            return value;
        }

        invalidate(InvalidationFlags.STYLE);
        _wordWrap = value;
        return value;
    }

    public function isInvalid(flag:String = InvalidationFlags.ALL):Bool {
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

    public function invalidate(flag:String = InvalidationFlags.ALL):Void {
        var isAlreadyInvalid:Bool = isInvalid();
        if (flag == InvalidationFlags.ALL) {
            _isAllInvalid = true;
        } else {
            if (flag != InvalidationFlags.ALL && !_invalidationFlags.exists(flag)) {
                _invalidationFlags.set(flag, true);
            }
        }
    }

    public function validate():Void {
        if (_isValidating == true     //we were already validating, the existing validation will continue.
           || isInvalid() == false) {   //if none is invalid, exit.
            return;
        }

        _isValidating = true;

        handleValidate();

        for (flag in _invalidationFlags.keys()) {
            _invalidationFlags.remove(flag);
        }

        _isAllInvalid = false;
        _isValidating = false;
    }

    private function handleValidate():Void {
        var dataInvalid = isInvalid(InvalidationFlags.DATA);
        var styleInvalid = isInvalid(InvalidationFlags.STYLE);
        var positionInvalid = isInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isInvalid(InvalidationFlags.DISPLAY);

        var measureTextRequired:Bool = false;

        if (dataInvalid) {
            validateData();
        }

        if (styleInvalid) {
            measureTextRequired = validateStyle();
        }

        if (positionInvalid) {
            validatePosition();
        }

        if (displayInvalid) {
            validateDisplay();
        }

        if (dataInvalid || displayInvalid || measureTextRequired) {
            measureText();
        }
    }
}
