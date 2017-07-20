package haxe.ui.core;

/**
 Interface that allows component properties to be automatically cloned based on `:clonable` metadata
**/
interface IClonable<T> {
    function cloneComponent():T;
    private function self():T;
}
