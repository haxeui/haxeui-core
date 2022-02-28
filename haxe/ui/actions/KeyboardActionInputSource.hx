package haxe.ui.actions;

import haxe.ui.actions.ActionManager;
import haxe.ui.actions.ActionType;
import haxe.ui.core.Platform;
import haxe.ui.core.Screen;
import haxe.ui.events.ActionEvent;
import haxe.ui.events.KeyboardEvent;

class KeyboardActionInputSource implements IActionInputSource {
    public function new() {
    }
    
    private var _started:Bool = false;
    public function start() {
        if (_started == true) {
            return;
        }
        _started = true;
        Screen.instance.registerEvent(KeyboardEvent.KEY_DOWN, onKeyDown);
        Screen.instance.registerEvent(KeyboardEvent.KEY_UP, onKeyUp);
    }
    
    private var _downKeys:Map<Int, Bool> = new Map<Int, Bool>(); // different platforms / frameworks behave differently, some dispatch once, others multiple - lets normalise that
    private function onKeyDown(e:KeyboardEvent) {
        var keyCode = e.keyCode;
        if (_downKeys.exists(keyCode)) {
            return;
        }
        _downKeys.set(keyCode, true);
        if (keyCode == Platform.instance.KeySpace) {
            ActionManager.instance.actionStart(ActionType.PRESS);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_START, ActionType.PRESS, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyLeft) {
            ActionManager.instance.actionStart(ActionType.LEFT);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_START, ActionType.LEFT, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyRight) {
            ActionManager.instance.actionStart(ActionType.RIGHT);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_START, ActionType.RIGHT, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyUp) {
            ActionManager.instance.actionStart(ActionType.UP);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_START, ActionType.UP, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyDown) {
            ActionManager.instance.actionStart(ActionType.DOWN);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_START, ActionType.DOWN, false, "KeyboardActionInputSource"));
        }
    }
    
    private function onKeyUp(e:KeyboardEvent) {
        var keyCode = e.keyCode;
        if (_downKeys.exists(keyCode) == false) {
            return;
        }
        _downKeys.remove(keyCode);
        
        if (keyCode == Platform.instance.KeySpace) {
            ActionManager.instance.actionEnd(ActionType.PRESS);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_END, ActionType.PRESS, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyLeft) {
            ActionManager.instance.actionEnd(ActionType.LEFT);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_END, ActionType.LEFT, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyRight) {
            ActionManager.instance.actionEnd(ActionType.RIGHT);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_END, ActionType.RIGHT, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyUp) {
            ActionManager.instance.actionEnd(ActionType.UP);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_END, ActionType.UP, false, "KeyboardActionInputSource"));
        } else if (keyCode == Platform.instance.KeyDown) {
            ActionManager.instance.actionEnd(ActionType.DOWN);
            ActionManager.instance.dispatch(new ActionEvent(ActionEvent.ACTION_END, ActionType.DOWN, false, "KeyboardActionInputSource"));
        }
    }
}