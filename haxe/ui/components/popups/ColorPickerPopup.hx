package haxe.ui.components.popups;

import haxe.ui.components.DropDown;
import haxe.ui.containers.Box;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.ItemRenderer;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Color;

@:xml('
<dropdown type="color" width="65">
    <item-renderer width="100%">
        <box id="selectedColorPreviewContainer" width="100%">
            <box id="selectedColorPreview" width="100%" style="background-color:#ff0000">
                <label text="" /> <!-- just to get the right size for a normal (text) dropdown -->
            </box>
        </box>
    </item-renderer>
</dropdown>
')
class ColorPickerPopup extends DropDown {
    public function new() {
        super();
        DropDownBuilder.HANDLER_MAP.set("color", Type.getClassName(ColorPickerPopupHandler));
    }
    
    private var _liveTracking:Bool = true;
    public var liveTracking(get, set):Bool;
    private function get_liveTracking():Bool {
        return _liveTracking;
    }
    private function set_liveTracking(value:Bool):Bool {
        _liveTracking = value;
        return value;
    }
}

@:access(haxe.ui.core.Component)
private class ColorPickerPopupHandler extends DropDownHandler {
    private var _view:ColorPickerPopupView = null;
    
    private override function get_component():Component {
        if (_view == null) {
            _view = new ColorPickerPopupView();
            _view.dropdown = _dropdown;
            _view.liveTracking = cast(_dropdown, ColorPickerPopup).liveTracking;
            _view.currentColor = _cachedSelectedColor;
            _view.onChange = onColorChange;
        }
        
        return _view;
    }
    
    public override function prepare(wrapper:Box) {
        super.prepare(wrapper);
        if (_cachedSelectedColor != null) {
            selectedItem = _cachedSelectedColor;
        }
    }
    
    private var _cachedSelectedColor:Null<Color> = null;
    private override function get_selectedItem():Dynamic {
        if (_view != null) {
            _cachedSelectedColor = _view.currentColor;
            return _view.currentColor;
        }
        return _cachedSelectedColor;
    }

    private override function set_selectedItem(value:Dynamic):Dynamic {
        if ((value is String)) {
            _cachedSelectedColor = Color.fromString(value);
        } else {
            _cachedSelectedColor = value;
        }
        if (_view != null) {
            _view.currentColor = _cachedSelectedColor;
        }
        onColorChange(null);
        return value;
    }
    
    private function onColorChange(e:UIEvent) {
        if (_view != null) {
            _cachedSelectedColor = _view.currentColor;
        }
        var itemRenderer = _dropdown.findComponent(ItemRenderer);
        if (itemRenderer != null) {
            var preview = itemRenderer.findComponent("selectedColorPreview", Box);
            if (preview != null) {
                preview.backgroundColor = _cachedSelectedColor.toHex();
                
                var event = new UIEvent(UIEvent.CHANGE);
                event.value = _cachedSelectedColor.toHex();
                _dropdown.dispatch(event);
            }
        }
    }
    
}

@:xml('
<vbox style="spacing:0;padding:5px;">
    <color-picker id="picker" />
    <box id="cancelApplyButtons" style="padding-top: 5px;" width="100%" hidden="true">
        <hbox horizontalAlign="right">
            <button id="cancelButton" text="Cancel" styleName="text-small" style="padding: 4px 8px;" />
            <button id="applyButton" text="Apply" styleName="text-small" style="padding: 4px 8px;" />
        </hbox>
    </box>
</vbox>
')
private class ColorPickerPopupView extends VBox {
    public var dropdown:DropDown = null;
    
    @:bind(picker, UIEvent.CHANGE)
    private function onPickerChange(_) {
        if (_liveTracking == true) {
            dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }
    
    public var currentColor(get, set):Null<Color>;
    private function get_currentColor():Null<Color> {
        return picker.currentColor;
    }
    private function set_currentColor(value:Null<Color>):Null<Color> {
        picker.currentColor = value;
        return value;
    }
    
    private var _liveTracking:Bool = true;
    public var liveTracking(get, set):Bool;
    private function get_liveTracking():Bool {
        return _liveTracking;
    }
    private function set_liveTracking(value:Bool):Bool {
        _liveTracking = value;
        if (_liveTracking == true) {
            cancelApplyButtons.hide();
        } else {
            cancelApplyButtons.show();
        }
        return value;
    }
    
    @:bind(cancelButton, MouseEvent.CLICK)
    private function onCancel(_) {
        dropdown.hideDropDown();
    }
    
    @:bind(applyButton, MouseEvent.CLICK)
    private function onApply(_) {
        dispatch(new UIEvent(UIEvent.CHANGE));
        dropdown.hideDropDown();
    }
}