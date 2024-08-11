package haxe.ui.core;

import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.util.Color;

class BasicItemRenderer extends ItemRenderer {
    private var _icon:Image;
    private var _label:Label;
    public function new() {
        super();

        var hbox:HBox = new HBox();
        hbox.addClass("basic-renderer-container");

        _icon = new Image();
        _icon.id = "icon";
        _icon.addClass("basic-renderer-icon");
        _icon.verticalAlign = "center";
        _icon.hide();
        hbox.addComponent(_icon);

        _label = new Label();
        _label.id = "text";
        _label.addClass("basic-renderer-label");
        _label.verticalAlign = "center";
        _label.hide();
        hbox.addComponent(_label);

        addComponent(hbox);
    }

    private override function updateValues(value:Dynamic, fieldList:Array<String> = null, currentRecursionLevel:Null<Int> = 0) {
        super.updateValues(value, fieldList, currentRecursionLevel);

        if (_label.text != null) {
            _label.show();
        } else {
            _label.hide();
        }

        if (_icon.resource != null) {
            _icon.show();
        } else {
            _icon.hide();
        }

        if (value != null) {
            if (value.color != null) {
                _label.customStyle.color = Color.fromString(value.color);
            }
            if (value.bold != null) {
                _label.customStyle.fontBold = (Std.string(value.bold) == "true");
            }
            if (value.italic != null) {
                _label.customStyle.fontItalic = (Std.string(value.italic) == "true");
            }
            if (value.underline != null) {
                _label.customStyle.fontUnderline = (Std.string(value.underline) == "true");
            }
        }
    }
}
