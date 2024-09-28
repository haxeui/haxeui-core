package haxe.ui.containers.properties;

import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.ScrollView.ScrollViewBuilder;
import haxe.ui.containers.ScrollView.ScrollViewEvents;
import haxe.ui.containers.properties.PropertyEditor.*;
import haxe.ui.containers.properties.PropertyEditor;
import haxe.ui.core.Component;

@:composite(Events, Builder)
@:access(haxe.ui.containers.properties.PropertyEditor)
class PropertyGrid extends ScrollView {
    private static var registeredEditors:Map<String, RegisteredEditorEntry> = new Map<String, RegisteredEditorEntry>();

    private static var defaultEditorsAdded:Bool = false;
    private static var defaultEditorType:String = "text";
    private static function initDefaultEditors() {
        if (defaultEditorsAdded) {
            return;
        }

        defaultEditorsAdded = true;
        registeredEditors.set("text", { editorClass: PropertyEditorText });
        registeredEditors.set("options", { editorClass: PropertyEditorOptions });
        registeredEditors.set("list", { editorClass: PropertyEditorList });
        registeredEditors.set("number", { editorClass: PropertyEditorNumber });
        registeredEditors.set("color", { editorClass: PropertyEditorColor });
        registeredEditors.set("boolean", { editorClass: PropertyEditorBoolean });
        registeredEditors.set("file", { editorClass: PropertyEditorFile });
        registeredEditors.set("date", { editorClass: PropertyEditorDate });
        registeredEditors.set("action", { editorClass: PropertyEditorAction });
        registeredEditors.set("toggle", { editorClass: PropertyEditorToggle });
    }

    public static function getRegisteredEditorInfo(type:String):RegisteredEditorEntry {
        initDefaultEditors();
        return registeredEditors.get(type);
    }

    public static function registerEditor(type:String, editorClass:Class<PropertyEditor>, config:Dynamic = null) {
        initDefaultEditors();
        registeredEditors.set(type, {
            editorClass: editorClass,
            config: config
        });
    }

    private static function createEditor(type:String):PropertyEditor {
        initDefaultEditors();
        if (!registeredEditors.exists(type)) {
            type = defaultEditorType;
        }
        var editorEntry = registeredEditors.get(type);
        var editor:PropertyEditor = Type.createInstance(editorEntry.editorClass, []);
        if (editorEntry.config != null) {
            editor.applyConfig(editorEntry.config);
        }
        return editor;
    }
}

private typedef RegisteredEditorEntry = {
    var editorClass:Class<PropertyEditor>;
    @:optional var config:Dynamic;
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
private class Events extends ScrollViewEvents {
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends ScrollViewBuilder {
    private var propertyGrid:PropertyGrid;

    public function new(propertyGrid:PropertyGrid) {
        super(propertyGrid);
        this.propertyGrid = propertyGrid;
        this.propertyGrid.percentContentWidth = 100;
    }

    public override function createVScroll():VerticalScroll {
        if (propertyGrid.autoHeight) {
            return super.createVScroll();
        }
        for (g in _component.findComponents(Property)) {
            g.addClass("scrolling");
        }
        return super.createVScroll();
    }
    
    public override function destroyVScroll() {
        if (propertyGrid.autoHeight) {
            super.destroyVScroll();
            return;
        }
        for (g in _component.findComponents(Property)) {
            g.removeClass("scrolling");
        }
        super.destroyVScroll();
    }
}