package haxe.ui.util;

import haxe.io.Bytes;
import haxe.ui.assets.ImageInfo;

class ImageLoader {
    private var _resource:String;
    
    public function new(resource:String) {
        _resource = StringTools.trim(resource);
    }
    
    public function load(callback:ImageInfo->Void) {
        if (StringTools.startsWith(_resource, "http://") || StringTools.startsWith(_resource, "https://")) {
           loadFromHttp(_resource, callback);
        } else if (StringTools.startsWith(_resource, "file://")) {
            loadFromFile(_resource.substr(7), callback);
        } else { // assume asset
           Toolkit.assets.getImage(_resource, callback);
        }
    }
    
    private function loadFromHttp(url:String, callback:ImageInfo->Void) {
        #if js // cant use haxe.Http because we need responseType
        
        var request = new js.html.XMLHttpRequest();
        request.open("GET", url);
        request.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
        
        request.onreadystatechange = function(_) {
            if (request.readyState != 4) {
                return;
            }
            
            var s = try request.status catch (e:Dynamic) null;
            if (s == untyped __js__("undefined")) {
                s = null;
            }
            
            if (s != null && s >= 200 && s < 400) {
                Toolkit.assets.imageFromBytes(Bytes.ofData(request.response), callback);
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
                if (s == 0) { // Seems status = 0 is a CORS error, lets try and use a "normal" http request from the browser rather than XMLHttpRequest
                    Toolkit.assets.getImage(url, callback);
                    return;
                }
                callback(null);
            }
        }
        request.onerror = function(x) {
        }
        
        request.send();
        
        #elseif cs // hxcs bytes are wrong in haxe.Http
        
        var request = cs.system.net.WebRequest.Create(url);
        var buffer = new cs.NativeArray<cs.types.UInt8>(32768);
        var reader = new cs.system.io.StreamReader(request.GetResponse().GetResponseStream());
        var memStream = new cs.system.io.MemoryStream();
        var bytesRead = 0;
        while ((bytesRead = reader.BaseStream.Read(buffer, 0, buffer.Length)) > 0) {
            memStream.Write(buffer, 0, bytesRead);
        }
        reader.Close();
        Toolkit.assets.imageFromBytes(Bytes.ofData(memStream.ToArray()), callback);
        
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
            
            try {
                Toolkit.assets.imageFromBytes(sys.io.File.getBytes(filename), callback);
            } catch (e:Dynamic) {
                trace("Problem loading image file: " + e);
                callback(null);
            }
        #else
            trace('WARNING: cant load from file system on non-sys targets [${filename}]');
            callback(null);
        #end
    }
}