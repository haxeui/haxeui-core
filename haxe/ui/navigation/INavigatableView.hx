package haxe.ui.navigation;

@:autoBuild(haxe.ui.macros.NavigationMacros.buildNavigatableView())
interface INavigatableView {
    public function applyParams(params:Map<String, Any>):Void;
}