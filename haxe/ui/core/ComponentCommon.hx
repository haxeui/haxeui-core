package haxe.ui.core;

import haxe.ui.backend.ComponentSurface;

class ComponentCommon extends ComponentSurface {
    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    @:dox(group = "Backend")
    public function getTextDisplay():TextDisplay {
        return null;
    }

    @:dox(group = "Backend")
    public function hasTextDisplay():Bool {
        return false;
    }
    
    @:dox(group = "Backend")
    public function getTextInput():TextInput {
        return null;
    }

    @:dox(group = "Backend")
    public function hasTextInput():Bool {
        return false;
    }
    
    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    @:dox(group = "Backend")
    public function getImageDisplay():ImageDisplay {
        return null;
    }

    @:dox(group = "Backend")
    public function hasImageDisplay():Bool {
        return false;
    }
}