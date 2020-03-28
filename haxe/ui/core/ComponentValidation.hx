package haxe.ui.core;
import haxe.ui.validation.InvalidationFlags;
import haxe.ui.validation.ValidationManager;

class ComponentValidation extends ComponentEvents {
    private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _delayedInvalidationFlags:Map<String, Bool> = new Map<String, Bool>();
    private var _isAllInvalid:Bool = false;
    private var _isValidating:Bool = false;
    private var _isInitialized:Bool = false;
    private var _isDisposed:Bool = false;
    private var _invalidateCount:Int = 0;
    
    private var _depth:Int = -1;
    @:dox(group = "Internal")
    public var depth(get, set):Int;
    private function get_depth():Int {
        return _depth;
    }
    private function set_depth(value:Int):Int {
        if (_depth == value) {
            return value;
        }

        _depth = value;

        return value;
    }
    
    /**
     Check if the component is invalidated with some `flag`.
    **/
    @:dox(group = "Invalidation related properties and methods")
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
    
    /**
     Invalidate this components with the `InvalidationFlags` indicated. If it hasn't parameter then the component will be invalidated completely.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function invalidateComponent(flag:String = InvalidationFlags.ALL) {
        if (_ready == false) {
            return;     //it should be added into the queue later
        }

        var isAlreadyInvalid:Bool = isComponentInvalid();
        var isAlreadyDelayedInvalid:Bool = false;
        if (_isValidating == true) {
            for (value in _delayedInvalidationFlags) {
                isAlreadyDelayedInvalid = true;
                break;
            }
        }

        if (flag == InvalidationFlags.ALL) {
            if (_isValidating == true) {
                _delayedInvalidationFlags.set(InvalidationFlags.ALL, true);
            } else {
                _isAllInvalid = true;
            }
        } else {
            if (_isValidating == true) {
                _delayedInvalidationFlags.set(flag, true);
            } else if (flag != InvalidationFlags.ALL && !_invalidationFlags.exists(flag)) {
                _invalidationFlags.set(flag, true);
            }
        }

        if (_isValidating == true) {
            //it is already in queue
            if (isAlreadyDelayedInvalid == true) {
                return;
            }

            _invalidateCount++;

            //we track the invalidate count to check if we are in an infinite loop or serious bug because it affects performance
            if (this._invalidateCount >= 10) {
                throw 'The validation queue returned too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls invalidate() during validation.';
            }

            ValidationManager.instance.add(cast(this, Component)); // TODO: avoid cast
            return;
        } else if (isAlreadyInvalid == true) {
            return;
        }

        _invalidateCount = 0;
        ValidationManager.instance.add(cast(this, Component)); // TODO: avoid cast
    }
    
    /**
     Invalidate the data of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentData() {
        invalidateComponent(InvalidationFlags.DATA);
    }
    
    /**
     Invalidate this components layout, may result in multiple calls to `invalidateDisplay` and `invalidateLayout` of its children
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentLayout() {
        if (_layout == null || _layoutLocked == true) {
            return;
        }
        invalidateComponent(InvalidationFlags.LAYOUT);
    }
    
    /**
     Invalidate the position of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentPosition() {
        invalidateComponent(InvalidationFlags.POSITION);
    }
    
    /**
     Invalidate the visible aspect of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentDisplay() {
        invalidateComponent(InvalidationFlags.DISPLAY);
    }
    
    /**
     Invalidate and recalculate this components style, may result in a call to `invalidateDisplay`
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateComponentStyle(force:Bool = false) {
        invalidateComponent(InvalidationFlags.STYLE);
        if (force == true) {
            _style = null;
        }
    }

    /**
     This method validates the tasks pending in the component.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function validateComponent() {
        if (_ready == false ||
            _isDisposed == true ||      //we don't want to validate disposed components, but they may have been left in the queue.
            _isValidating == true ||    //we were already validating, the existing validation will continue.
            isComponentInvalid() == false) {     //if none is invalid, exit.
            return;
        }

        var isInitialized = _isInitialized;
        if (isInitialized == false) {
            initializeComponent();
        }

        _isValidating = true;

        validateComponentInternal();
        validateInitialSize(isInitialized);
        
        for (flag in _invalidationFlags.keys()) {
            _invalidationFlags.remove(flag);
        }

        _isAllInvalid = false;

        for (flag in _delayedInvalidationFlags.keys()) {
            if (flag == InvalidationFlags.ALL) {
                _isAllInvalid = true;
            } else {
                _invalidationFlags.set(flag, true);
            }
            _delayedInvalidationFlags.remove(flag);
        }
        _isValidating = false;
    }

    /**
     Validate this component and its children on demand.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function validateNow() {
        syncComponentValidation();
    }
    
    /**
     Validate this component and its children on demand.
    **/
    @:dox(group = "Invalidation related properties and methods")
    public function syncComponentValidation() {
        var count:Int = 0;
        while(isComponentInvalid()) {
            validateComponent();

            for (child in childComponents) {
                child.syncComponentValidation();
            }

            if (++count >= 10) {
                throw 'The syncValidation returned too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls invalidate() during validation.';
            }
        }
    }
    
    private function validateComponentInternal() {
        var dataInvalid = isComponentInvalid(InvalidationFlags.DATA);
        var styleInvalid = isComponentInvalid(InvalidationFlags.STYLE);
        var textDisplayInvalid = isComponentInvalid(InvalidationFlags.TEXT_DISPLAY) && hasTextDisplay();
        var textInputInvalid = isComponentInvalid(InvalidationFlags.TEXT_INPUT) && hasTextInput();
        var imageDisplayInvalid = isComponentInvalid(InvalidationFlags.IMAGE_DISPLAY) && hasImageDisplay();
        var positionInvalid = isComponentInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isComponentInvalid(InvalidationFlags.DISPLAY);
        var layoutInvalid = isComponentInvalid(InvalidationFlags.LAYOUT) && _layoutLocked == false;

        if (dataInvalid) {
            validateComponentData();
        }

        if (styleInvalid) {
            validateComponentStyle();
        }

        if (textDisplayInvalid) {
            getTextDisplay().validateComponent();
        }

        if (textInputInvalid) {
            getTextInput().validateComponent();
        }

        if (imageDisplayInvalid) {
            getImageDisplay().validateComponent();
        }

        if (positionInvalid) {
            validateComponentPosition();
        }

        if (layoutInvalid) {
            displayInvalid = validateComponentLayout() || displayInvalid;
        }

        if (displayInvalid || styleInvalid) {
            ValidationManager.instance.addDisplay(cast(this, Component));    //Update the display from all objects at the same time. Avoids UI flashes.
                                                                             // TODO: avoid cast
        }
    }
    
    private function initializeComponent() {
        
    }
    
    private function validateInitialSize(isInitialized:Bool) {
        
    }
    
    private function validateComponentData() {
        behaviours.validateData();
    }
    
    private function validateComponentLayout():Bool {
        return false;
    }
    
    private function validateComponentStyle() {
        
    }
    
    private function validateComponentPosition() {
        
    }
}