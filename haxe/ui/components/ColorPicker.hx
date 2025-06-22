package haxe.ui.components;

import haxe.io.Bytes;
import haxe.ui.containers.Box;
import haxe.ui.core.Screen;
import haxe.ui.events.DragEvent;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;
import haxe.ui.util.Color;
import haxe.ui.util.ColorUtil.HSV;
import haxe.ui.util.ColorUtil;

/**
	A visual color picker that allows the user to pick a color from either an HSV color space, 
    or by directly modifying RGB/HSV values.
**/
class ColorPicker extends Box {
    private var _impl:ColorPickerImpl = null;
    /**
    	Creates a new color picker. `0xFF00000` is selected by default.
    **/
    public function new() {
        super();
        _impl = new HSVColorPickerImpl();
        _impl.registerEvent(UIEvent.CHANGE, onImplValueChanged);
        _impl.picker = this;
        addComponent(_impl);
    }
    
    /**
    	The currently selected color, as a 24-bit, RGB value.

        Setting this value will update the selected color in the picker.
    **/
    public var currentColor(get, set):Null<Color>;
    private function get_currentColor():Null<Color> {
        return _impl.currentColor;
    }
    private function set_currentColor(value:Null<Color>):Null<Color> {
        _impl.currentColor = value;
        return value;
    }
    
    private function onImplValueChanged(_) {
        dispatch(new UIEvent(UIEvent.CHANGE));
    }
    
    public override function addClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        super.addClass(name, invalidate, recursive);
        if (_impl != null) {
            @:privateAccess _impl.onStyleClassChanged();
        }
    }
    
    public override function removeClass(name:String, invalidate:Bool = true, recursive:Bool = false) {
        super.removeClass(name, invalidate, recursive);
        if (_impl != null) {
            @:privateAccess _impl.onStyleClassChanged();
        }
    }
}

private class ColorPickerImpl extends Box {
    public var picker:ColorPicker = null;
    
    private var _currentColor:Null<Color> = null;
    public var currentColor(get, set):Null<Color>;
    private function get_currentColor():Null<Color> {
        return _currentColor;
    }
    private function set_currentColor(value:Null<Color>):Null<Color> {
        _currentColor = value;
        onCurrentColorChanged();
        return value;
    }
    private function onCurrentColorChanged() {
    }
    
    private override function onInitialize() {
        super.onInitialize();
        if (_currentColor == null) {
            //currentColor = 0xff0000;
        }
    }
    private function onStyleClassChanged() {
        
    }
}

@:xml('
<box width="100%" height="100%">
    <vbox width="100%" height="100%">
        <absolute id="saturationValueContainer" style="clip:true;padding-right: 3px;padding-bottom:3px;" width="100%" height="100%">
            <canvas id="saturationValueGraph" width="100%" height="100%" left="2" top="2" style="pointer-events:true" />
            <box id="saturationValueIndicator" style="pointer-events:none" includeInLayout="false" />
        </absolute>
        
        <absolute id="hueContainer" width="100%" style="clip:true;">
            <canvas id="hueGraph" width="100%" height="20" left="2" top="2" style="pointer-events:true" />
            <box id="hueIndicator" width="8" height="18" includeInLayout="false" top="3" left="10" />
        </absolute>
        
        <hbox styleName="controls-preview-container" width="100%">
            <hbox styleName="controls-container" width="100%">
                <image id="prevControls" verticalAlign="center" style="pointer-events:true" onclick="controlsStack.prevPage()" />
                <stack id="controlsStack" width="100%" selectedIndex="0">
                    <grid id="hsvControls" columns="4" width="100%" style="spacing:0px">
                        <label text="{{hue}}" styleName="text-tiny" />
                        <slider id="sliderHue" max="360" allowFocus="false" styleName="simple-slider" step="1" />
                        <spacer width="5" />
                        <textfield id="inputHue" restrictChars="0-9" styleName="text-tiny" allowFocus="false" />
                        
                        <label text="{{saturation}}" styleName="text-tiny" />
                        <slider id="sliderSaturation" allowFocus="false" styleName="simple-slider" />
                        <spacer width="5" />
                        <textfield id="inputSaturation" restrictChars="0-9" styleName="text-tiny" allowFocus="false" />
                        
                        <label text="{{brightness}}" styleName="text-tiny" />
                        <slider id="sliderValue" allowFocus="false" styleName="simple-slider" />
                        <spacer width="5" />
                        <textfield id="inputValue" restrictChars="0-9" styleName="text-tiny" allowFocus="false" />
                    </grid>
                    
                    <grid id="rgbControls" columns="4" width="100%" style="spacing:0">
                        <label text="{{red}}" styleName="text-tiny" />
                        <slider id="sliderRed" max="255" allowFocus="false" styleName="simple-slider" />
                        <spacer width="5" />
                        <textfield id="inputRed" restrictChars="0-9" styleName="text-tiny" allowFocus="false" />
                        
                        <label text="{{green}}" styleName="text-tiny" />
                        <slider id="sliderGreen" max="255" allowFocus="false" styleName="simple-slider" />
                        <spacer width="5" />
                        <textfield id="inputGreen" restrictChars="0-9" styleName="text-tiny" allowFocus="false" />
                        
                        <label text="{{blue}}" styleName="text-tiny" />
                        <slider id="sliderBlue" max="255" allowFocus="false" styleName="simple-slider" />
                        <spacer width="5" />
                        <textfield id="inputBlue" restrictChars="0-9" styleName="text-tiny" allowFocus="false" />
                    </grid>
                </stack>
                <image id="nextControls" verticalAlign="center" style="pointer-events:true" onclick="controlsStack.nextPage()" />
            </hbox>
            
            <vbox height="100%" style="spacing: 2px">
                <box id="colorPreviewContainer" width="64" height="100%">
                    <box id="colorPreview" width="100%" height="100%" style="background-color: #ff0000">
                    </box>
                </box>    
                <textfield horizontalAlign="center" id="inputHex" styleName="text-tiny" allowFocus="false" />
            </vbox>    
        </hbox>    
    </vbox>    
</box>
')
private class HSVColorPickerImpl extends ColorPickerImpl {
    private var _currentColorHSV:HSV;
    private var _currentColorRGBF:RGBF;
    private var _lastColor:Null<Color> = null;
    public function new() {
        super();
        saturationValueGraph.componentGraphics.setProperty("html5.graphics.method", "canvas");
        hueGraph.componentGraphics.setProperty("html5.graphics.method", "canvas");
        pauseEvent(UIEvent.CHANGE);
        currentColor = 0x000000;
    }
    
    private override function set_currentColor(value:Null<Color>):Null<Color> {
        _currentColorHSV = ColorUtil.toHSV(value);
        _currentColorRGBF = {r:value.r, g:value.g, b:value.b};
        return super.set_currentColor(value);
    }

    private override function onReady() {
        super.onReady();
        saturationValueGraph.invalidateComponentLayout();
        saturationValueGraph.validateNow();
    }

    private override function onCurrentColorChanged() {
        invalidateComponentData();
    }
    
    private override function validateComponentData() {
        super.validateComponentData();
        if (_currentColorRGBF == null) {
            return;
        }
        _currentColorRGBF.r = Math.fround(_currentColorRGBF.r);
        _currentColorRGBF.g = Math.fround(_currentColorRGBF.g);
        _currentColorRGBF.b = Math.fround(_currentColorRGBF.b);
        
        updateSaturationValueGraph();
        updateHueGraph();
        
        if (isHSV()) {
            sliderHue.pos = _currentColorHSV.h;
            sliderSaturation.pos = _currentColorHSV.s;
            sliderValue.pos = _currentColorHSV.v;
            inputHue.text = "" + Math.round(_currentColorHSV.h);
            inputSaturation.text = "" + Math.round(_currentColorHSV.s);
            inputValue.text = "" + Math.round(_currentColorHSV.v);
        } else if (isRGB()) {
            sliderRed.pos = _currentColorRGBF.r;
            sliderGreen.pos = _currentColorRGBF.g;
            sliderBlue.pos = _currentColorRGBF.b;
            inputRed.text = "" + Math.round(_currentColorRGBF.r);
            inputGreen.text = "" + Math.round(_currentColorRGBF.g);
            inputBlue.text = "" + Math.round(_currentColorRGBF.b);
        }
        
        inputHex.text = StringTools.hex(Std.int(_currentColorRGBF.r), 2) + StringTools.hex(Std.int(_currentColorRGBF.g), 2) + StringTools.hex(Std.int(_currentColorRGBF.b), 2);
        
        var coord = saturationValueCoordFromHSV(_currentColorHSV.h, _currentColorHSV.s, _currentColorHSV.v);
        saturationValueIndicator.left = Std.int(coord.x) - 0;
        saturationValueIndicator.top = Std.int(coord.y) - 1;
        
        var coord = hueCoordFromHSV(_currentColorHSV.h, _currentColorHSV.s, _currentColorHSV.v);
        hueIndicator.left = Std.int(coord.x) - 0;
        hueIndicator.top = Std.int(coord.y) - 0;
        
        
        _currentColor = Color.fromComponents(Math.round(_currentColorRGBF.r), Math.round(_currentColorRGBF.g), Math.round(_currentColorRGBF.b), 255);
        colorPreview.backgroundColor = _currentColor.toHex();
        
        if (_lastColor != _currentColor) {
            _lastColor = _currentColor;
            dispatch(new UIEvent(UIEvent.CHANGE));
        }

        resumeEvent(UIEvent.CHANGE);
    }
    
    @:bind(this, UIEvent.SHOWN)
    private function _onShown(_) {
        _saturationValueGraphLastHue = null;
        updateSaturationValueGraph();
    }

    private var _saturationValueGraphBytes:Bytes = null;
    private var _saturationValueGraphLastHue:Null<Float> = null;
    private function updateSaturationValueGraph() {
        if (_currentColorHSV == null) {
            return;
        }
        var cx:Int = Std.int(saturationValueGraph.width);
        var cy:Int = Std.int(saturationValueGraph.height);
        if (cx <= 0 || cy <= 0) {
            return;
        }
        
        var requiresRedraw = true;
        if (_saturationValueGraphLastHue != null && _saturationValueGraphLastHue == _currentColorHSV.h) {
            requiresRedraw = false;
            // Sometimes html element image data "disappears" so we still need to set pixels
            saturationValueGraph.componentGraphics.setPixels(_saturationValueGraphBytes);
        }

        //Seemingly breaks the color picker for no reason, commenting just in case.
        /*
        if (_currentColorRGBF.r == 255 && _currentColorRGBF.g == 255 && _currentColorRGBF.b == 255) {
            return;
        }
        */
        
        if (requiresRedraw) {
            _saturationValueGraphLastHue = _currentColorHSV.h;

            var bytesSize = cx * cy * 4;
            if (_saturationValueGraphBytes == null) {
                _saturationValueGraphBytes = Bytes.alloc(bytesSize);
            }
            if (_saturationValueGraphBytes.length != bytesSize) {
                _saturationValueGraphBytes = Bytes.alloc(bytesSize);
            }

            var isDisabled = picker.disabled;
            var stepX = 100 / cx;
            var stepY = 100 / cy;
            var l = cx * 4;
            for (y in 0...cy) {
                for (x in 0...cx) {
                    var i:Int = y * l + x * 4;
                    var pixel = ColorUtil.hsvToRGBF(_currentColorHSV.h - 1, (x + 1) * stepX, 100 - (y * stepY));
                    if (isDisabled) {
                        var greypixel = ColorUtil.rgbToGray(Math.round(pixel.r), Math.round(pixel.g), Math.round(pixel.b));
                        _saturationValueGraphBytes.set(i + 0, greypixel);
                        _saturationValueGraphBytes.set(i + 1, greypixel);
                        _saturationValueGraphBytes.set(i + 2, greypixel);
                        _saturationValueGraphBytes.set(i + 3, 0xFF);
                    } else {
                        _saturationValueGraphBytes.set(i + 0, Std.int(pixel.r));
                        _saturationValueGraphBytes.set(i + 1, Std.int(pixel.g));
                        _saturationValueGraphBytes.set(i + 2, Std.int(pixel.b));
                        _saturationValueGraphBytes.set(i + 3, 0xFF);
                    }
                }
            }

            saturationValueGraph.componentGraphics.clear();
            saturationValueGraph.componentGraphics.setPixels(_saturationValueGraphBytes);
        }
    }
    
    private var _hueGraphBytes:Bytes = null;
    private function updateHueGraph() {
        var cx:Int = Std.int(hueGraph.width);
        var cy:Int = Std.int(hueGraph.height);
        if (cx <= 0 || cy <= 0) {
            return;
        }
        
        //Seemingly breaks the color picker for no reason, commenting just in case.
        /*
        if (_currentColorRGBF.r == 255 && _currentColorRGBF.g == 255 && _currentColorRGBF.b == 255) {
            return;
        }
        */
        
        var requiresRedraw = true;

        if (requiresRedraw) {
            var bytesSize = cx * cy * 4;
            if (_hueGraphBytes == null) {
                _hueGraphBytes = Bytes.alloc(bytesSize);
            }
            if (_hueGraphBytes.length != bytesSize) {
                _hueGraphBytes = Bytes.alloc(bytesSize);
            }

            var isDisabled = picker.disabled;
            var step = 360 / cx;
            var l = cx * 4;
            for (y in 0...cy) {
                for (x in 0...cx) {
                    var i:Int = y * l + x * 4;
                    var c = ColorUtil.hsvToRGBF(x * step, 100, 100);
                    if (isDisabled) {
                        var greypixel = ColorUtil.rgbToGray(Math.round(c.r), Math.round(c.g), Math.round(c.b));
                        _hueGraphBytes.set(i + 0, greypixel);
                        _hueGraphBytes.set(i + 1, greypixel);
                        _hueGraphBytes.set(i + 2, greypixel);
                        _hueGraphBytes.set(i + 3, 0xFF);
                    } else {
                        _hueGraphBytes.set(i + 0, Std.int(c.r));
                        _hueGraphBytes.set(i + 1, Std.int(c.g));
                        _hueGraphBytes.set(i + 2, Std.int(c.b));
                        _hueGraphBytes.set(i + 3, 0xFF);
                    }
                }
            }

            hueGraph.componentGraphics.clear();
            hueGraph.componentGraphics.setPixels(_hueGraphBytes);
        }
    }
    
    @:bind(controlsStack, UIEvent.CHANGE)
    private function onControlStackChange(_) {
        onCurrentColorChanged();
    }

    private function isHSV() {
        return controlsStack.selectedIndex == 0;
    }
    
    private function isRGB() {
        return controlsStack.selectedIndex == 1;
    }

    ///////////////////////////////////////////////////////////////////////////////////
    // Focus Handlers
    ///////////////////////////////////////////////////////////////////////////////////
    @:bind(inputHue, FocusEvent.FOCUS_IN)
    @:bind(inputSaturation, FocusEvent.FOCUS_IN)
    @:bind(inputValue, FocusEvent.FOCUS_IN)
    @:bind(inputRed, FocusEvent.FOCUS_IN)
    @:bind(inputGreen, FocusEvent.FOCUS_IN)
    @:bind(inputBlue, FocusEvent.FOCUS_IN)
    @:bind(inputHex, FocusEvent.FOCUS_IN)
    private function onInputFocus(e:FocusEvent) {
        //var textField = cast(e.target, TextField);
        //textField.selectionStartIndex = 0;
        //textField.selectionEndIndex = textField.text.length;
    }
    
    // lets make the graph a little nicer by NOT applying the change from the hex value when we are using sliders (this leads to rounding issues between RGB -> HSV)
    private var _sliderTracking:Bool = false;
    @:bind(sliderHue, DragEvent.DRAG_START)
    @:bind(sliderSaturation, DragEvent.DRAG_START)
    @:bind(sliderValue, DragEvent.DRAG_START)
    private function onSliderDragStart(_) {
        _sliderTracking = true;
    }
    
    @:bind(sliderHue, DragEvent.DRAG_END)
    @:bind(sliderSaturation, DragEvent.DRAG_END)
    @:bind(sliderValue, DragEvent.DRAG_END)
    private function onSliderDragEnd(_) {
        _sliderTracking = false;
    }
    ///////////////////////////////////////////////////////////////////////////////////
    // HSL Input Handlers
    ///////////////////////////////////////////////////////////////////////////////////
    @:bind(sliderHue, UIEvent.CHANGE)
    private function onHueSliderChanged(_) {
        if (_currentColorHSV == null) {
            return;
        }
        applyHSV({h: sliderHue.pos, s: _currentColorHSV.s, v: _currentColorHSV.v });
    }
    
    @:bind(inputHue, UIEvent.CHANGE)
    private function onHueInputChanged(_) {
        if (inputHue.text == null || inputHue.text == "") {
            return;
        }
        var v = Std.parseFloat(inputHue.text);
        if (Math.isNaN(v)) {
            v = 0;
        }
        if (v > 360) {
            v = 360;
        }
        sliderHue.pos = v;
    }
    
    @:bind(sliderSaturation, UIEvent.CHANGE)
    private function onSaturationSliderChanged(_) {
        if (_currentColorHSV == null) {
            return;
        }
        applyHSV({h: _currentColorHSV.h, s: sliderSaturation.pos, v: _currentColorHSV.v });
    }

    @:bind(inputSaturation, UIEvent.CHANGE)
    private function onSaturationInputChanged(_) {
        if (inputSaturation.text == null || inputSaturation.text == "") {
            return;
        }
        var v = Std.parseFloat(inputSaturation.text);
        if (Math.isNaN(v)) {
            v = 0;
        }
        if (v > 100) {
            v = 100;
        }
        sliderSaturation.pos = v;
    }
    
    @:bind(sliderValue, UIEvent.CHANGE)
    private function onValueSliderChanged(_) {
        if (_currentColorHSV == null) {
            return;
        }
        applyHSV({h: _currentColorHSV.h, s: _currentColorHSV.s, v: sliderValue.pos });
    }
    
    @:bind(inputValue, UIEvent.CHANGE)
    private function onValueInputChanged(_) {
        if (inputValue.text == null || inputValue.text == "") {
            return;
        }
        var v = Std.parseFloat(inputValue.text);
        if (Math.isNaN(v)) {
            v = 0;
        }
        if (v > 100) {
            v = 100;
        }
        sliderValue.pos = v;
    }

    ///////////////////////////////////////////////////////////////////////////////////
    // RGB Input Handlers
    ///////////////////////////////////////////////////////////////////////////////////
    @:bind(sliderRed, UIEvent.CHANGE)
    private function onRedSliderChanged(_) {
        if (_currentColorRGBF == null) {
            return;
        }
        applyHSV(ColorUtil.rgbfToHSV(sliderRed.pos, _currentColorRGBF.g, _currentColorRGBF.b));
    }

    @:bind(inputRed, UIEvent.CHANGE)
    private function onRedInputChanged(_) {
        if (inputRed.text == null || inputRed.text == "") {
            return;
        }
        var v = Std.parseFloat(inputRed.text);
        if (Math.isNaN(v)) {
            v = 0;
        }
        if (v > 255) {
            v = 255;
        }
        sliderRed.pos = v;
    }
    
    @:bind(sliderGreen, UIEvent.CHANGE)
    private function onGreenSliderChanged(_) {
        if (_currentColorRGBF == null) {
            return;
        }
        applyHSV(ColorUtil.rgbfToHSV(_currentColorRGBF.r, sliderGreen.pos, _currentColorRGBF.b));
    }

    @:bind(inputGreen, UIEvent.CHANGE)
    private function onGreenInputChanged(_) {
        if (inputGreen.text == null || inputGreen.text == "") {
            return;
        }
        var v = Std.parseFloat(inputGreen.text);
        if (Math.isNaN(v)) {
            v = 0;
        }
        if (v > 255) {
            v = 255;
        }
        sliderGreen.pos = v;
    }

    @:bind(sliderBlue, UIEvent.CHANGE)
    private function onBlueSliderChanged(_) {
        if (_currentColorRGBF == null) {
            return;
        }
        applyHSV(ColorUtil.rgbfToHSV(_currentColorRGBF.r, _currentColorRGBF.g, sliderBlue.pos));
    }

    @:bind(inputBlue, UIEvent.CHANGE)
    private function onBlueInputChanged(_) {
        if (inputBlue.text == null || inputBlue.text == "") {
            return;
        }
        var v = Std.parseFloat(inputBlue.text);
        if (Math.isNaN(v)) {
            v = 0;
        }
        if (v > 255) {
            v = 255;
        }
        sliderBlue.pos = v;
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    // RGB Input Handlers
    ///////////////////////////////////////////////////////////////////////////////////
    @:bind(inputHex, UIEvent.CHANGE)
    private function onHexInputChanged(_) {
        if (inputHex.text == null || inputHex.text == "" || inputHex.text.length != 6) {
            return;
        }
        
        var hexR = inputHex.text.substr(0, 2);
        var hexG = inputHex.text.substr(2, 2);
        var hexB = inputHex.text.substr(4, 2);
        var r = Std.parseInt("0x" + hexR);
        var g = Std.parseInt("0x" + hexG);
        var b = Std.parseInt("0x" + hexB);
        
        if (_trackingSaturationValue == false && _sliderTracking == false) {
            applyRGBA({r:r, g:g, b:b});
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    // Helpers
    ///////////////////////////////////////////////////////////////////////////////////
    
    private function applyHSV(newHSV:HSV) {
        _currentColorHSV = newHSV;
        _currentColorRGBF = ColorUtil.hsvToRGBF(newHSV.h, newHSV.s, newHSV.v);
        onCurrentColorChanged();
    }

    private function applyRGBA(newRGBF:RGBF) {
        _currentColorHSV = ColorUtil.rgbfToHSV(newRGBF.r, newRGBF.g, newRGBF.b);
        _currentColorRGBF = newRGBF;
        onCurrentColorChanged();
    }
    
    private var _trackingSaturationValue:Bool = false;
    @:bind(saturationValueGraph, MouseEvent.MOUSE_DOWN)
    private function onSaturationValueGraphDown(e:MouseEvent) {
        e.cancel();
        _trackingSaturationValue = true;
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        
        applyHSVFromCoord(e.screenX - (saturationValueGraph.screenLeft + getComponentOffset().x), e.screenY - (saturationValueGraph.screenTop + getComponentOffset().y));
    }

    private var _trackingHue:Bool = false;
    @:bind(hueGraph, MouseEvent.MOUSE_DOWN)
    private function onHueGraphDown(e:MouseEvent) {
        e.cancel();
        _trackingHue = true;
        
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        
        applyHueFromCoord(e.screenX - (hueGraph.screenLeft + getComponentOffset().x), e.screenY - (hueGraph.screenTop + getComponentOffset().y));
    }
    
    private function onScreenMouseMove(e:MouseEvent) {
        if (_trackingSaturationValue) {
            applyHSVFromCoord(e.screenX - (saturationValueGraph.screenLeft + getComponentOffset().x), e.screenY - (saturationValueGraph.screenTop + getComponentOffset().y));
        } else if (_trackingHue) {
            applyHueFromCoord(e.screenX - (hueGraph.screenLeft + getComponentOffset().x), e.screenY - (hueGraph.screenTop + getComponentOffset().y));
        }
    }
    
    private function onScreenMouseUp(e:MouseEvent) {
        _trackingSaturationValue = false;
        _trackingHue = false;
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
    }
    
    private function applyHSVFromCoord(x:Float, y:Float) {
        var cx = saturationValueGraph.width;
        var cy = saturationValueGraph.height;
        
        if (x > cx) {
            x = cx;
        } else if (x < 0) {
            x = 0;
        }
        if (y > cy) {
            y = cy;
        } else if (y < 0) {
            y = 0;
        }
        
        var newHSV = hsvFromSaturationValueCoord(_currentColorHSV.h, x, y);
        _currentColorHSV = newHSV;
        _currentColorRGBF = ColorUtil.hsvToRGBF(newHSV.h, newHSV.s, newHSV.v);
        onCurrentColorChanged();
    }
    
    private function applyHueFromCoord(x:Float, y:Float) {
        var cx = hueGraph.width;
        var step = 360 / (hueGraph.width - 10);
        var hue = (x - 3) * step;
        applyHSV({h: hue, s: _currentColorHSV.s, v: _currentColorHSV.v });
    }
    
    private function hsvFromSaturationValueCoord(hue:Float, x:Float, y:Float):HSV {
        var stepX = 100 / saturationValueGraph.width;
        var stepY = 100 / saturationValueGraph.height;
        var s = (x) * stepX;
        var v = 100 - (y * stepY);
        return {h: hue, s: s, v: v};
    }
    
    private function saturationValueCoordFromHSV(hue:Float, saturation:Float, value:Float):Point {
        var stepX = 100 / saturationValueGraph.width;
        var stepY = 100 / saturationValueGraph.height;
        
        var x = (saturation - 1) / stepX;
        var y = ((100 - value) / stepY);
        
        return new Point(x, y);
    }
    
    private function hueCoordFromHSV(hue:Float, saturation:Float, value:Float):Point {
        var step = 360 / (hueGraph.width - 10);
        
        var x = hue / step;
        var y = 3;
        
        return new Point(x + 3, y);
    }
    
    private override function onStyleClassChanged() {
        if (picker.hasClass("no-sliders") || picker.hasClass("no-text-inputs")) {
            hsvControls.columns = 3;
            rgbControls.columns = 3;
        } else {
            hsvControls.columns = 4;
            rgbControls.columns = 4;
        }
    }
}