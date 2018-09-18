package haxe.ui.core;

import haxe.ui.backend.TextInputBase;
import haxe.ui.styles.Style;
import haxe.ui.validation.IValidating;
import haxe.ui.validation.InvalidationFlags;

class TextInputData {
    public var password:Bool = false;
    
    public var hscrollPos:Float = 0;
    public var hscrollMax:Float = 0;
    public var hscrollPageSize:Float = 0;
    
    public var vscrollPos:Float = 0;
    public var vscrollMax:Float = 0;
    public var vscrollPageSize:Float = 0;
    
    public var onScrollCallback:Void->Void = null;
    public var onChangedCallback:Void->Void = null;
    
    public function new() {
    }
}

/**
 Class that represents a framework specific method to display editable text inside a component
**/
class TextInput extends TextInputBase implements IValidating {
    private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _isAllInvalid:Bool = false;
    private var _isValidating:Bool = false;

    public function new() {
        super();

        _isAllInvalid = true;
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
                invalidate(InvalidationFlags.STYLE);
            });
        } else {
            invalidate(InvalidationFlags.STYLE);
        }
        
        _textStyle = value;
        return value;
    }

    public var data(get, null):TextInputData;
    private function get_data():TextInputData {
        return _inputData;
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
        invalidate(InvalidationFlags.DATA);
        return value;
    }

    public var password(get, set):Bool;
    private function get_password():Bool {
        return _inputData.password;
    }
    private function set_password(value:Bool):Bool {
        if (value == _inputData.password) {
            return value;
        }

        _inputData.password = value;
        invalidate(InvalidationFlags.STYLE);
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

        _left = value;
        invalidate(InvalidationFlags.POSITION);
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

        _top = value;
        invalidate(InvalidationFlags.POSITION);
        return value;
    }

    public var width(get, set):Float;
    public function set_width(value:Float):Float {
        if (_width == value) {
            return value;
        }

        _width = value;
        invalidate(InvalidationFlags.DISPLAY);
        validateDisplay(); // TODO: why is this needed??
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

        _height = value;
        invalidate(InvalidationFlags.DISPLAY);
        validateDisplay(); // TODO: why is this needed??
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
        if (_text == null || _text.length == 0) {
            //return 0; // if text is zero length we still want a height
        }

        if (isInvalid() == true) {
            validate();
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

        _displayData.multiline = value;
        invalidate(InvalidationFlags.STYLE);
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

        _displayData.wordWrap = value;
        invalidate(InvalidationFlags.STYLE);
        return value;
    }

    public var hscrollPos(get, set):Float;
    private function get_hscrollPos():Float {
        return _inputData.hscrollPos;
    }
    private function set_hscrollPos(value:Float):Float {
        if (value == _inputData.hscrollPos) {
            return value;
        }

        _inputData.hscrollPos = value;
        invalidate(InvalidationFlags.DATA);
        validateData(); // TODO: why is this needed??
        return value;
    }

    public var hscrollMax(get, null):Float;
    private function get_hscrollMax():Float {
        return _inputData.hscrollMax;
    }
    
    public var hscrollPageSize(get, null):Float;
    private function get_hscrollPageSize():Float {
        return _inputData.hscrollPageSize;
    }
    
    public var vscrollPos(get, set):Float;
    private function get_vscrollPos():Float {
        return _inputData.vscrollPos;
    }
    private function set_vscrollPos(value:Float):Float {
        if (value == _inputData.vscrollPos) {
            return value;
        }

        _inputData.vscrollPos = value;
        invalidate(InvalidationFlags.DATA);
        validateData(); // TODO: why is this needed??
        return value;
    }

    public var vscrollMax(get, null):Float;
    private function get_vscrollMax():Float {
        return _inputData.vscrollMax;
    }
    
    public var vscrollPageSize(get, null):Float;
    private function get_vscrollPageSize():Float {
        return _inputData.vscrollPageSize;
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

    public function invalidate(flag:String = InvalidationFlags.ALL) {
        if (flag == InvalidationFlags.ALL) {
            _isAllInvalid = true;
            //ValidationManager.instance.add(this);     //Don't need. It is validated internally in the component in a sync way
        } else {
            if (flag != InvalidationFlags.ALL && !_invalidationFlags.exists(flag)) {
                _invalidationFlags.set(flag, true);
                //ValidationManager.instance.add(this); //Don't need. It is validated internally in the component in a sync way
            }
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

    public function updateDisplay() {
    }
    
    public function validate() {
        if (_isValidating == true ||    //we were already validating, the existing validation will continue.
            isInvalid() == false) {     //if none is invalid, exit.
            return;
        }

        _isValidating = true;

        validateInternal();

        for (flag in _invalidationFlags.keys()) {
            _invalidationFlags.remove(flag);
        }

        _isAllInvalid = false;
        _isValidating = false;
    }
    
    private function validateInternal() {
        var dataInvalid = isInvalid(InvalidationFlags.DATA);
        var styleInvalid = isInvalid(InvalidationFlags.STYLE);
        var positionInvalid = isInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isInvalid(InvalidationFlags.DISPLAY);
        var measureInvalid = isInvalid(InvalidationFlags.MEASURE);

        if (dataInvalid) {
            validateData();
        }

        if (styleInvalid) {
            measureInvalid = validateStyle() || measureInvalid;
        }

        if (positionInvalid) {
            validatePosition();
        }

        if (displayInvalid) {
            validateDisplay();
        }

        if (dataInvalid || displayInvalid || measureInvalid) {
            measureText();
        }
    }
}