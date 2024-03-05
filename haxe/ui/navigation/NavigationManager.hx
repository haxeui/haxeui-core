package haxe.ui.navigation;

import haxe.ui.util.EventDispatcher;
import haxe.ui.core.Screen;
import haxe.ui.core.IComponentContainer;
import haxe.ui.core.Component;
import haxe.ui.events.NavigationEvent;

using StringTools;

class NavigationManager extends EventDispatcher<NavigationEvent> {
    private static var _instance:NavigationManager;
    public static var instance(get, null):NavigationManager;
    private static function get_instance():NavigationManager {
        if (_instance == null) {
            _instance = new NavigationManager();
        }
        return _instance;
    }


    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    public var defaultContainer:Component;
    public var subDomain:String;

    private var registeredRoutes:Array<RouteDetails> = [];

    private function new() {
        super();

        #if js

        if (js.Browser.window.location.protocol != "file:") {
            js.Browser.window.onpopstate = (event) -> {
                var state:String = event.state;
                if (state == null) {
                    state = "/";
                }
                if (state.trim().length == 0)  {
                    state = "/";
                }
                if (!state.startsWith("/")) {
                    state = "/" + state;
                }
                navigateTo(state, null, true);
            };
        }

        #end
    }

    public function applyInitialRoute() {
        var path:String = null;

        #if js
        if (js.Browser.window.location.protocol != "file:") {
            path = js.Browser.window.location.pathname;
            path = normalizePath(path);
            if (js.Browser.window.location.search != null && js.Browser.window.location.search.trim().length > 0) {
                path += js.Browser.window.location.search;
            }
        }
        #end

        if (path != null && subDomain != null && path.startsWith(subDomain)) {
            path = path.substring(subDomain.length);
            path = normalizePath(path);
        }

        #if haxeui_navigation_persist_route
        #if js
        if (js.Browser.window.location.protocol == "file:") {
            // get the path, we can look this up on refreshes (assuming flag allows it)
            var localStorage = js.Browser.window.localStorage;
            var lastPath = localStorage.getItem("lastPath");
            if (lastPath != null) {
                path = lastPath;
            } else {
                path = null;
            }
        }
        #end
        #end

        if (path == null) {
            var initialRoute = findInitialRoute();
            if (initialRoute != null) {
                path = initialRoute.path;
            }
        }

        if (path != null) {
            if (!path.startsWith("/")) {
                path = "/" + path;
            }
            navigateTo(path);
        }
    }

    public function registerRoute(path:String, routeDetails:RouteDetails) {
        if (subDomain != null && subDomain.length != 0 && !path.startsWith(subDomain) && !path.startsWith("/" + subDomain)) {
            path = subDomain + path;
        }

        var copy = routeDetails.clone();
        path = normalizePath(path);
        copy.path = path;
        registeredRoutes.push(copy);
    }

    private var currentFullPath:String;
    private var lastPath:String;

    public var currentPath(get, set):String;
    private function get_currentPath():String {
        var path = currentFullPath;
        return path;
    }
    private function set_currentPath(value:String):String {
        navigateTo(value);
        return value;
    }

    private function applyPathParams(path:String, params:Map<String, Any> = null) {
        if (params == null) {
            return path;
        }

        var newPath = path;
        for (key in params.keys()) {
            var token = "{" + key + "}";
            var value = params.get(key);
            if (newPath.indexOf(token) != -1) {
                newPath = newPath.replace(token, value);
                params.remove(key);
            }
        }

        for (key in params.keys()) {
            var value = params.get(key);
            if (value != null) {
                var use = switch (Type.typeof(value)) {
                    case TInt | TFloat | TBool: true;
                    case _: (value is String);
                }
                if (use) {
                    if (newPath.indexOf("?") == -1) {
                        newPath += "?";
                    }
        
                    newPath += key + "=" + value + "&";
                    params.remove(key);
                }
            }
        }

        if (newPath.endsWith("&")) {
            newPath = newPath.substring(0, newPath.length - 1);
        }

        return newPath;
    }

    private var views:Map<String, INavigatableView> = new Map<String, INavigatableView>();
    public function navigateTo(path:String, params:Map<String, Any> = null, replaceState:Bool = false) {
        if (registeredRoutes.length == 0) {
            trace("WARNING: no routes registered");
        }

        path = applyPathParams(path, params);
        if (currentFullPath == path) {
            //return;
        }
        currentFullPath = path;

        var fullPath = path;
        var pathParams:Map<String, String> = [];
        if (path.indexOf("?") != -1) {
            var paramsString = path.substring(path.indexOf("?") + 1);
            path = path.substring(0, path.indexOf("?"));
            var parts = paramsString.split("&");
            for (p in parts) {
                var n = p.indexOf("=");
                var param = p.substring(0, n);
                var value = p.substring(n + 1);
                pathParams.set(param, value);
            }
        }

        var originalPath = path;
        if (subDomain != null && subDomain.length != 0 && !path.startsWith(subDomain) && !path.startsWith("/" + subDomain)) {
            path = subDomain + path;
        }

        path = normalizePath(path);

        var routeDetails = findRouteByPath(path);
        if (routeDetails == null) {
            trace("path not found", path);
            var errorRouteDetails = findErrorRoute();
            if (errorRouteDetails != null) {
                routeDetails = errorRouteDetails.clone();
            } else {
                return;
            }
        }

        var routeParams = routeDetails.params;
        if (routeParams == null) {
            routeParams = [];
        }
        if (pathParams != null) {
            for (k in pathParams.keys()) {
                routeParams.set(k, pathParams.get(k));
            }
        }
        if (params != null) {
            for (k in params.keys()) {
                routeParams.set(k, params.get(k));
            }
        }

        var container = getContainer(routeDetails);
        var view:INavigatableView = null;
        if (routeDetails.preserveView) {
            view = views.get(routeDetails.path);
            if (view == null) {
                view = routeDetails.viewCtor();    
            }
            views.set(routeDetails.path, view);
        } else {
            view = routeDetails.viewCtor();
        }
        var component:Component = cast view;
        updateRouteContainer(routeDetails, container);
        updateRouteComponent(routeDetails, component);
        var containerRoutes = findRoutesForContainer(container);
        for (containerRoute in containerRoutes) {
            if (containerRoute.component != null && containerRoute.container.containsComponent(containerRoute.component)) {
                containerRoute.container.removeComponent(containerRoute.component, !containerRoute.preserveView);
            }
        }

        view.applyParams(routeParams);
        container.addComponent(component);

        #if js

        var statePath = fullPath;
        if (subDomain != null && subDomain.length != 0 && !statePath.startsWith(subDomain) && !statePath.startsWith("/" + subDomain)) {
            statePath = subDomain + "/" + statePath;
            statePath = "/" + normalizePath(statePath);
        }

        var documentOrigin = js.Browser.window.origin;
        var useState = true;
        if (documentOrigin == null || js.Browser.window.location.protocol == "file:") {
            useState = false;
        }
        if (useState && lastPath != statePath) {
            if (replaceState) {
                js.Browser.window.history.replaceState(statePath, null, statePath);
            } else {
                js.Browser.window.history.pushState(statePath, null, statePath);
            }
            // is this a hack?!
            lastPath = statePath;
        }

        #end

        #if haxeui_navigation_persist_route
        #if js
        if (js.Browser.window.location.protocol == "file:" && !routeDetails.error) {
            // store the path, we can look this up on refreshes (assuming flag allows it)
            var localStorage = js.Browser.window.localStorage;
            localStorage.setItem("lastPath", fullPath);
        }
        #end
        #end

        var event = new NavigationEvent(NavigationEvent.NAVIGATION_CHANGED);
        dispatch(event);
    }

    // since we work with copies, if we want to see container on the original one we'll have to find it
    private function updateRouteContainer(routeDetails:RouteDetails, container:IComponentContainer) {
        for (temp in registeredRoutes) {
            if (temp.path == routeDetails.path) {
                temp.container = container;
                break;
            }
        }
    }

    // since we work with copies, if we want to see container on the original one we'll have to find it
    private function updateRouteComponent(routeDetails:RouteDetails, component:Component) {
        for (temp in registeredRoutes) {
            if (temp.path == routeDetails.path) {
                temp.component = component;
                break;
            }
        }
    }

    private function findRoutesForContainer(container:IComponentContainer):Array<RouteDetails> {
        var list = [];
        for (routeDetails in registeredRoutes) {
            if (routeDetails.container != null && routeDetails.container == container) {
                list.push(routeDetails);
            }
        }
        return list;
    }

    private function getContainer(routeDetails:RouteDetails):IComponentContainer {
        if (routeDetails.container != null) {
            return routeDetails.container;
        }
        if (defaultContainer == null) {
            return Screen.instance;
        }
        return defaultContainer;
    }

    private function findRouteByPath(path:String):RouteDetails {
        if (path == null) {
            return null;
        }
        var route = null;
        for (r in registeredRoutes) {
            if (isRouteMatch(path, r)) {
                route = r;
                break;
            }
        }

        if (route == null) {
            return null;
        }

        route = route.clone();

        var pathPartsParamNames = route.path.split("/");
        var pathPartParamValues = path.split("/");
        var params:Map<String, Any> = [];
        for (i in 0...pathPartsParamNames.length) {
            var pathPartName = pathPartsParamNames[i];
            var pathPartValue = pathPartParamValues[i];
            if (pathPartName.startsWith("{") && pathPartName.endsWith("}")) {
                params.set(pathPartName.substring(1, pathPartName.length - 1), pathPartValue);
            }
        }

        if (route.params != null) {
            route.params = [];
            for (k in params.keys()) {
                route.params.set(k, params.get(k));
            }
        }

        return route;
    }

    private function isRouteMatch(path:String, candidate:RouteDetails):Bool {
        if (path == candidate.path) {
            return true;
        }

        var candidatePath = candidate.path;
        var pathParts = path.split("/");
        var candidatePathParts = candidatePath.split("/");
        if (pathParts.length != candidatePathParts.length) {
            return false;
        }

        for (i in 0...pathParts.length) {
            var pathPart = pathParts[i];
            var candidatePathPart = candidatePathParts[i];
            if (candidatePathPart.startsWith("{") && candidatePathPart.endsWith("}")) {
                continue;
            }
            if (pathPart != candidatePathPart) {
                return false;
            }
        }

        return true;
    }

    private function findInitialRoute():RouteDetails {
        if (registeredRoutes.length == 0) {
            trace("WARNING: no routes registered");
        }

        for (details in registeredRoutes) {
            if (details.initial) {
                return details;
            }
        }

        for (details in registeredRoutes) {
            if (details.path.length == 0) {
                return details;
            }
        }

        return null;
    }


    private function findErrorRoute():RouteDetails {
        if (registeredRoutes.length == 0) {
            trace("WARNING: no routes registered");
        }

        for (details in registeredRoutes) {
            if (details.error) {
                return details;
            }
        }
        return null;
    }

    private static function normalizePath(path:String) {
        if (path == null) {
            return null;
        }
        if (path.startsWith("/")) {
            path = path.substring(1);
        }
        if (path.endsWith("/")) {
            path = path.substring(0, path.length - 1);
        }
        path = path.replace("//", "/");
        /*
        if (!path.startsWith("/")) {
            path = "/" + path;
        }
        */
        return path;
    }
}