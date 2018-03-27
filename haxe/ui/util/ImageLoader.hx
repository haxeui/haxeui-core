package haxe.ui.util;

import haxe.io.Bytes;
import haxe.ui.assets.ImageInfo;

class ImageLoader {
    private var _resource:String;
    
    public function new(resource:String) {
        _resource = StringTools.trim(resource);
    }
    
    public function load(callback:ImageInfo->Void) {
        if (StringTools.startsWith(_resource, "http://")) {
           loadFromHttp(_resource, callback);
        } else if (StringTools.startsWith(_resource, "file://")) {
            loadFromFile(_resource.substr(7), callback);
        } else { // assume asset
           Toolkit.assets.getImage(_resource, callback);
        }
    }
    
    private function loadFromHttp(url:String, callback:ImageInfo->Void) {
        #if js
        
        var request = new js.html.XMLHttpRequest();
        request.open("GET", url);
        request.overrideMimeType('text/plain; charset=x-user-defined');
        request.onreadystatechange = function(_) {
            if (request.readyState != 4) {
                return;
            }
            
            var s = try request.status catch (e:Dynamic) null;
            if (s == untyped __js__("undefined")) {
                s = null;
            }
            
            if (s != null && s >= 200 && s < 400) {
                var bytes = haxe.io.Bytes.alloc(request.responseText.length);
                for (i in 0...request.responseText.length) {
                     bytes.set(i, request.responseText.charCodeAt(i) & 0xFF);
                }
                Toolkit.assets.imageFromBytes(bytes, callback);
            } else if (s == null) {
                callback(null);
            } else {
                #if debug
                
                var error:String = "Http Error #" + request.status;
                switch(s) {
                    case 12029:
                        error = "Failed to connect to host";
                    case 12007:    
                        error = "Unknown host";
                    default:
                }
                
                trace(error);
                
                #end
                
                callback(null);
            }
        }
        request.send();
        
        #else
        
        var http:haxe.Http = new haxe.Http(url);
        http.onData = function(data:String) {
            Toolkit.assets.imageFromBytes(Bytes.ofString(data), callback);
        }
        http.onError = function(msg:String) {
            trace(msg);
            callback(null);
        }
        http.request();
        
        #end
    }

    private function loadFromFile(filename, callback:ImageInfo->Void) {
        #if sys
            if (sys.FileSystem.exists(filename) == false) {
                callback(null);
            }
            
            Toolkit.assets.imageFromBytes(sys.io.File.getBytes(filename), callback);
        #else
            trace('WARNING: cant load from file system on non-sys targets [${filename}]');
            callback(null);
        #end
    }
}