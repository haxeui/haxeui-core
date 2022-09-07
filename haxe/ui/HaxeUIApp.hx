package haxe.ui;

import haxe.ui.Preloader;
import haxe.ui.Preloader.PreloadItem;
import haxe.ui.backend.AppImpl;
import haxe.ui.backend.ToolkitOptions;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;

@:keep
class HaxeUIApp extends AppImpl {
    public static var instance:HaxeUIApp;

    private var _options:ToolkitOptions;
    public function new(options:ToolkitOptions = null) {
        super();
        instance = this;
        _options = options;
        Toolkit.build();
        build();
    }

    public function ready(onReady:Void->Void, onEnd:Void->Void = null) {
        init(onReady, onEnd);
    }

    public var preloaderClass:Class<Preloader> = null;
    public var preloader:Preloader = null;
    private override function init(onReady:Void->Void, onEnd:Void->Void = null) {
        if (Toolkit.backendProperties.getProp("haxe.ui.theme") != null && Toolkit.theme == "default") {
            Toolkit.theme = Toolkit.backendProperties.getProp("haxe.ui.theme");
        }

        if (_options == null) {
            Toolkit.init(getToolkitInit());
        } else { // TODO: consider: https://code.haxe.org/category/macros/combine-objects.html
            Toolkit.init(_options);
        }

        var preloadList:Array<PreloadItem> = null;

        #if (!haxeui_hxwidgets && !haxeui_kha && !haxeui_qt && !haxeui_raylib) // TODO: needs some work here

        preloadList = buildPreloadList();
        if (preloadList != null && preloadList.length > 0) {
            if (preloaderClass == null) {
                preloader = new Preloader();
            } else {
                preloader = Type.createInstance(preloaderClass, []);
            }
            preloader.progress(0, preloadList.length);
            addComponent(preloader);
            preloader.validateComponent();
        }

        #end

        handlePreload(preloadList, onReady, onEnd, preloader);
    }

    private function handlePreload(list:Array<PreloadItem>, onReady:Void->Void, onEnd:Void->Void, preloader:Preloader) {
        if (list == null || list.length == 0) {
            if (preloader != null) {
                preloader.complete();
            }
            super.init(onReady, onEnd);
            return;
        }

        var item = list.shift();
        switch (item.type) {
            case "font":
                ToolkitAssets.instance.getFont(item.resourceId, function(f) {
                    if (preloader != null) {
                        preloader.increment();
                    }
                    handlePreload(list, onReady, onEnd, preloader);
                });
            case "image":
                ToolkitAssets.instance.getImage(item.resourceId, function(i) {
                    if (preloader != null) {
                        preloader.increment();
                    }
                    handlePreload(list, onReady, onEnd, preloader);
                });
            case _:
                trace('WARNING: unknown type to preload "${item.type}", continuing');
                if (preloader != null) {
                    preloader.increment();
                }
                handlePreload(list, onReady, onEnd, preloader);
        }
    }

    public var title(get, set):String;
    private function get_title():String {
        return Screen.instance.title;
    }
    private function set_title(value:String):String {
        Screen.instance.title = value;
        return value;
    }
    
    public function addComponent(component:Component):Component {
        return Screen.instance.addComponent(component);
    }

    public function removeComponent(component:Component, dispose:Bool = true):Component {
        return Screen.instance.removeComponent(component, dispose);
    }

    public function setComponentIndex(child:Component, index:Int):Component {
        return Screen.instance.setComponentIndex(child, index);
    }

    private override function buildPreloadList():Array<PreloadItem> {
        var list = super.buildPreloadList();

        if (list == null) {
            list = [];
        }

        list = list.concat(ToolkitAssets.instance.preloadList);

        return list;
    }
}