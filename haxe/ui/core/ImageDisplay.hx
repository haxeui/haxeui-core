package haxe.ui.core;

import haxe.ui.assets.ImageInfo;
import haxe.ui.backend.ImageDisplayImpl;
import haxe.ui.geom.Rectangle;
import haxe.ui.validation.InvalidationFlags;

/**
 Class that represents a framework specific method to display an image inside a component
**/
class ImageDisplay extends ImageDisplayImpl {
    private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _isAllInvalid:Bool = false;
    private var _isValidating:Bool = false;
    
    public function new() {
        super();
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
        invalidateComponent(InvalidationFlags.POSITION);
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
        invalidateComponent(InvalidationFlags.POSITION);
        return value;
    }

    public var imageWidth(get, set):Float;
    public function set_imageWidth(value:Float):Float {
        if (_imageWidth == value || value <= 0) {
            return value;
        }

        _imageWidth = value;
        invalidateComponent(InvalidationFlags.DISPLAY);
        return value;
    }

    public function get_imageWidth():Float {
        return _imageWidth;
    }

    public var imageHeight(get, set):Float;
    public function set_imageHeight(value:Float):Float {
        if (_imageHeight == value || value <= 0) {
            return value;
        }

        _imageHeight = value;
        invalidateComponent(InvalidationFlags.DISPLAY);
        return value;
    }

    public function get_imageHeight():Float {
        return _imageHeight;
    }

    public var imageInfo(get, set):ImageInfo;
    private function get_imageInfo():ImageInfo {
        return _imageInfo;
    }
    private function set_imageInfo(value:ImageInfo):ImageInfo {
        if (value == _imageInfo) {
            return value;
        }

        _imageInfo = value;
        _imageWidth = _imageInfo.width;
        _imageHeight = _imageInfo.height;
        invalidateComponent(InvalidationFlags.DATA);
        invalidateComponent(InvalidationFlags.DISPLAY);

        return value;
    }

    public var imageClipRect(get, set):Rectangle;
    public function get_imageClipRect():Rectangle {
        return _imageClipRect;
    }
    private function set_imageClipRect(value:Rectangle):Rectangle {
        _imageClipRect = value;
        invalidateComponent(InvalidationFlags.DISPLAY);

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
            parentComponent.invalidateComponent(InvalidationFlags.IMAGE_DISPLAY);
        } else if (!_invalidationFlags.exists(flag)) {
            _invalidationFlags.set(flag, true);
            parentComponent.invalidateComponent(InvalidationFlags.IMAGE_DISPLAY);
        }
    }

    public function validateComponent() {
        if (_isValidating == true ||    //we were already validating, the existing validation will continue.
            isComponentInvalid() == false) {     //if none is invalid, exit.
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

    private function handleValidate() {
        var dataInvalid = isComponentInvalid(InvalidationFlags.DATA);
        var positionInvalid = isComponentInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isComponentInvalid(InvalidationFlags.DISPLAY);

        if (dataInvalid) {
            validateData();
        }

        if (positionInvalid) {
            validatePosition();
        }

        if (displayInvalid) {
            validateDisplay();
        }
    }
}