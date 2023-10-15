package haxe.ui.macros.extensions;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ui.macros.MacroHelpers;

#end

class DraggableBuilder {
    #if macro

    macro static function build():Array<Field> {
        var fields = Context.getBuildFields();

        if (!MacroHelpers.shouldBuildExtension(Context.getLocalClass().get(), "haxe.ui.extensions.Draggable")) {
            return null;
        }

        var draggable = macro class Temp {
            /**
            * Utility property to add a single `DragEvent.DRAG_START` event
            */
            @:event(haxe.ui.events.DragEvent.DRAG_START)       public var onDragStart:haxe.ui.events.DragEvent->Void;    

            /**
            * Utility property to add a single `DragEvent.DRAG` event
            */
            @:event(haxe.ui.events.DragEvent.DRAG)             public var onDrag:haxe.ui.events.DragEvent->Void;    

            /**
            * Utility property to add a single `DragEvent.DRAG_END` event
            */
            @:event(haxe.ui.events.DragEvent.DRAG_END)         public var onDragEnd:haxe.ui.events.DragEvent->Void;    

            /**
            * When set to `true`, this component should be drag&drop-able.
            */
            public var draggable(get, set):Bool;
            private function get_draggable():Bool {
                return haxe.ui.dragdrop.DragManager.instance.isRegisteredDraggable(this);
            }
            private function set_draggable(value:Bool):Bool {
                if (value == true) {
                    haxe.ui.dragdrop.DragManager.instance.registerDraggable(this, dragOptions);
                } else {
                    haxe.ui.dragdrop.DragManager.instance.unregisterDraggable(this);
                }
                return value;
            }

            @:noCompletion private var _dragInitiator:haxe.ui.core.Component = null;
            public var dragInitiator(get, set):haxe.ui.core.Component;
            private function get_dragInitiator():haxe.ui.core.Component {
                return _dragInitiator;
            }
            private function set_dragInitiator(value:haxe.ui.core.Component):haxe.ui.core.Component {
                _dragInitiator = value;
                if (value != null) {
                    if (_dragOptions != null) {
                        _dragOptions.mouseTarget = value;
                    }
                    draggable = true;
                } else {
                    draggable = false;
                }
                return value;
            }

            @:noCompletion private var _dragOptions:haxe.ui.dragdrop.DragOptions = null;
            public var dragOptions(get, set):haxe.ui.dragdrop.DragOptions;
            private function get_dragOptions():haxe.ui.dragdrop.DragOptions {
                if (_dragOptions == null) {
                    _dragOptions = { mouseTarget: _dragInitiator };
                }
                return _dragOptions;
            }
            private function set_dragOptions(value:haxe.ui.dragdrop.DragOptions):haxe.ui.dragdrop.DragOptions {
                _dragOptions = value;
                draggable = true;
                return value;
            }
        }

        fields = fields.concat(draggable.fields);

        return fields;
    }

    #end

}