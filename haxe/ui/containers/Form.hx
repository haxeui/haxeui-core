package haxe.ui.containers;

import haxe.ui.core.InteractiveComponent;
import haxe.ui.events.UIEvent;
import haxe.ui.events.ValidatorEvent;
import haxe.ui.layouts.VerticalGridLayout;

using haxe.ui.animation.AnimationTools;

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
    public var highlightInvalidFields:Bool = true;

    @:event(UIEvent.SUBMIT_START)               public var onSubmitStart:UIEvent->Void;
    @:event(UIEvent.SUBMIT)                     public var onSubmit:UIEvent->Void;
    @:event(ValidatorEvent.INVALID_DATA)        public var onInvalidData:ValidatorEvent->Void;
    @:event(ValidatorEvent.VALID_DATA)          public var onValidData:ValidatorEvent->Void;

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

    public function submit() {
        dispatch(new UIEvent(UIEvent.SUBMIT, true));
    }

    //***********************************************************************************************************
    // Private API
    //***********************************************************************************************************
    private function validateForm(fn:Bool->Void) {
        fn(true);
    }

    public var invalidFields:Array<InteractiveComponent> = [];
    public var invalidFieldMessages:Map<InteractiveComponent, Array<String>> = new Map<InteractiveComponent, Array<String>>();

    @:noCompletion
    private function validateFormData(fn:Bool->Void) {
        invalidFields = [];
        invalidFieldMessages = new Map<InteractiveComponent, Array<String>>();

        var interactives = findComponents(InteractiveComponent, -1);
        for (i in interactives) {
            if (i.validators != null && i.validators.length > 0) {
                for (v in i.validators) {
                    if (v == null) {
                        continue;
                    }
                    var valid = v.validate(i);
                    if (valid == false) {
                        invalidFields.push(i);
                        var messageList = invalidFieldMessages.get(i);
                        if (messageList == null) {
                            messageList = [];
                            invalidFieldMessages.set(i, messageList);
                        }
                        messageList.push(v.invalidMessage);
                    }
                }
            }
        }

        if (invalidFields.length == 0) {
            fn(true);
            dispatch(new ValidatorEvent(ValidatorEvent.VALID_DATA));
        } else {
            if (highlightInvalidFields) {
                for (f in invalidFields) {
                    f.shake().flash();
                }
            }
            dispatch(new ValidatorEvent(ValidatorEvent.INVALID_DATA));
            fn(false);
        }

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
        registerEvent(UIEvent.SUBMIT, onSubmit);
    }

    public override function unregister() {
        super.unregister();
        unregisterEvent(UIEvent.SUBMIT, onSubmit);
    }

    private function onSubmit(event:UIEvent) {
        dispatch(new UIEvent(UIEvent.SUBMIT_START, true));
        _form.validateFormData(function(valid) {
            if (!valid) {
                event.cancel();
            } else {
                _form.validateForm(function(valid) {
                    if (!valid) {
                        event.cancel();
                    }
                });
            }
        });
    }
}