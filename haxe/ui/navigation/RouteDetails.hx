package haxe.ui.navigation;

import haxe.ui.core.IComponentContainer;
import haxe.ui.core.Component;

@:structInit
class RouteDetails {
    public var viewCtor:Void->INavigatableView = null;
    public var path:String = null;
    public var initial:Bool = false;
    public var error:Bool = false;
    public var preserveView:Bool = false;

    public var containerId:String = null;
    public var container:IComponentContainer = null;
    public var component:Component = null;

    public var params:Map<String, Any> = [];

    public function clone():RouteDetails {
        return {
            viewCtor: this.viewCtor,
            path: this.path,
            initial: this.initial,
            error: this.error,
            preserveView: this.preserveView,
            containerId: this.containerId,
            container: this.container,
            component: this.component,
            params: this.params.copy()
        }
    }
}