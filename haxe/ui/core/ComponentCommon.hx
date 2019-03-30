package haxe.ui.core;
import haxe.ui.backend.ComponentSurface;

class ComponentCommon extends ComponentSurface {
    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    public function getTextDisplay():TextDisplay {
        return null;
    }

    public function hasTextDisplay():Bool {
        return false;
    }
    
    public function getTextInput():TextInput {
        return null;
    }

    public function hasTextInput():Bool {
        return false;
    }
    
    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    public function getImageDisplay():ImageDisplay {
        return null;
    }

    public function hasImageDisplay():Bool {
        return false;
    }
}