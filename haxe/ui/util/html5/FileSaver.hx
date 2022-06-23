package haxe.ui.util.html5;

import haxe.io.Bytes;

#if js

import js.Browser;
import js.html.AnchorElement;
import js.html.Blob;
import js.html.URL;

class FileSaver {
    private var _link:AnchorElement = null;
    private var _callback:Bool->Void = null;
    public function new() {
    }
    
    public function saveText(fileName:String, text:String, callback:Bool->Void) {
        if (fileName == null) {
            fileName = "";
        }
        
        _callback = callback;
        var file = new Blob([text], {type: "text/plain"});
        _link = Browser.document.createAnchorElement();
        _link.setAttribute("href", URL.createObjectURL(file));
        _link.setAttribute("download", fileName);
        _link.style.display = "none";
        Browser.document.body.appendChild(_link);
        _link.click();
        
        Browser.window.addEventListener("focus", onWindowFocus);
    }
    
    public function saveBinary(fileName:String, bytes:Bytes, callback:Bool->Void) {
        if (fileName == null) {
            fileName = "";
        }

        _callback = callback;
        var file = new Blob([bytes.getData()]);
        _link = Browser.document.createAnchorElement();
        _link.setAttribute("href", URL.createObjectURL(file));
        _link.setAttribute("download", fileName);
        _link.style.display = "none";
        Browser.document.body.appendChild(_link);
        _link.click();
        
        Browser.window.addEventListener("focus", onWindowFocus);
    }
    
    private function onWindowFocus() { // js doesnt allow you to know when dialog has been cancelled, so lets use a window focus event
        destroy();
        if (_callback != null) {
            _callback(true);// no way to know if the user save the file or cancelled, so lets assume saved (?)
        }
    }
    
    private function destroy() {
        if (_link != null) {
            Browser.document.body.removeChild(_link);
            URL.revokeObjectURL(_link.href);
            _link = null;
        }
        Browser.window.removeEventListener("focus", onWindowFocus);
    }
}

#else

class FileSaver {
    public function new() {
    }
    
    public function saveText(fileName:String, text:String, callback:Bool->Void) {
    }
    
    public function saveBinary(fileName:String, bytes:Bytes, callback:Bool->Void) {
    }
}

#end