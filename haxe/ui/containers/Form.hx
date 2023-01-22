package haxe.ui.containers;

import haxe.ui.events.UIEvent;
import haxe.ui.layouts.VerticalGridLayout;

@:composite(FormEvents)
class Form extends Box {
    public function new() {
        super();
        if (_columns == -1) { // dont set it if its already been set
            columns = 2;
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:event(UIEvent.USER_SUBMIT)                                      public var onSubmit:UIEvent->Void;

    private var _columns:Int = -1;
    @:clonable public var columns(get, set):Int;
    private function get_columns():Int {
        if (!(_layout is VerticalGridLayout)) {
            return -1;
        }
        return cast(_layout, VerticalGridLayout).columns;
    }
    private function set_columns(value:Int):Int {
        if (_layout == null) {
            layout = createLayout();
        }

        if (!(_layout is VerticalGridLayout)) {
            layout = new VerticalGridLayout();
        }

        cast(_layout, VerticalGridLayout).columns = value;
        _columns = value;
        return value;
    }

    private function validateForm(fn:Bool->Void) {
        fn(true);
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        super.createDefaults();
        _defaultLayoutClass = VerticalGridLayout;
    }
}

@:access(haxe.ui.containers.Form)
private class FormEvents extends haxe.ui.events.Events {
    private var _form:Form;

    public function new(form:Form) { 
        super(form);
        _form = form;
    }

    public override function register() {
        super.register();
        registerEvent(UIEvent.USER_SUBMIT, onSubmit);
    }

    public override function unregister() {
        super.unregister();
        unregisterEvent(UIEvent.USER_SUBMIT, onSubmit);
    }

    private function onSubmit(event:UIEvent) {
        _form.validateForm(function(valid) {
            if (!valid) {
                event.cancel();
            }
        });
    }
}