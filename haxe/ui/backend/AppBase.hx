package haxe.ui.backend;

import haxe.ui.Preloader.PreloadItem;

class AppBase {
    private function build() {
    }
    
    private function init(onReady:Void->Void, onEnd:Void->Void = null) {
        onReady();
    }
    
    private function getToolkitInit():ToolkitOptions {
        return  {
        };
    }
    
    public function start() {
    }

    private function buildPreloadList():Array<PreloadItem> {
        return [];
    }
    
}