package haxe.ui;

import haxe.ui.Preloader.PreloadItem;
import haxe.ui.backend.AppBase;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.core.UIEvent;

@:keep
class HaxeUIApp extends AppBase {
    public function new() {
        super();
        Toolkit.build();
        build();
    }

    public function ready(onReady:Void->Void, onEnd:Void->Void = null) {
        init(onReady, onEnd);
    }

    private override function init(onReady:Void->Void, onEnd:Void->Void = null) {
        if (Toolkit.backendProperties.getProp("haxe.ui.theme") != null && Toolkit.theme == "default") {
            Toolkit.theme = Toolkit.backendProperties.getProp("haxe.ui.theme");
        }

        Toolkit.init(getToolkitInit());
        
        var preloadList:Array<PreloadItem> = null;
        var preloader = null;
        
        #if (!haxeui_hxwidgets && !haxeui_kha) // TODO: needs some work here

        preloadList = buildPreloadList();        
        if (preloadList != null && preloadList.length > 0) {
            preloader = new Preloader();
            preloader.progress(0, preloadList.length);
            addComponent(preloader);
            preloader.validate();
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
        switch(item.type) {
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
    
    public function addComponent(component:Component) {
        Screen.instance.addComponent(component);
    }

    public function removeComponent(component:Component) {
        Screen.instance.removeComponent(component);
    }

    public function setComponentIndex(child:Component, index:Int) {
        Screen.instance.setComponentIndex(child, index);
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