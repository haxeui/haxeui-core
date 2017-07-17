package haxe.ui.validation;

/**
    A object that supports validation. Objects of this type
    will delay updating after property changes until just before the renderer
    renders the display list to avoid running redundant code.
**/
interface IValidating
{
    /**
        The component's depth in the display list, relative to the stage. If
        the component isn't on the stage or it isn't a component,
        its depth will be -1.

        Used by the validation system to validate components from the down top.
    **/
    var depth(get, set):Int;

    /**
        Immediately validates the object, if it is invalid. The
        validation system exists to postpone updating a object after
        properties are changed until the last possible moment the
        renderer renders the display list. This allows multiple properties to be
        changed at a time without requiring a full update every time.
    **/
    function validate():Void;

    /**
        Update the display of the object. All objects update the display at the
        same time.
    **/
    function updateDisplay():Void;
}
