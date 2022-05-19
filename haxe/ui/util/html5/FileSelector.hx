package haxe.ui.util.html5;

import haxe.ui.containers.dialogs.Dialogs.FileDialogExtensionInfo;
import haxe.ui.containers.dialogs.Dialogs.SelectedFileInfo;

#if js

import haxe.io.Bytes;
import js.Browser;
import js.html.FileReader;
import js.html.InputElement;

using StringTools;

class ReadMode {
    public static inline var None:String = "none";
    public static inline var Text:String = "text";
    public static inline var Binary:String = "binary";
}

@:noCompletion
class FileSelector {
    private var _fileInput:InputElement;
    private var _readMode:String = ReadMode.None;
    private var _callback:Bool->Array<SelectedFileInfo>->Void;
    
    public function new() {
    }
    
    public function selectFile(callback:Bool->Array<SelectedFileInfo>->Void, readMode:String = "none", multiple:Bool = false, extensions:Array<FileDialogExtensionInfo> = null) {
        _callback = callback;
        _readMode = readMode;
        createFileInput(multiple, extensions);
        _fileInput.click();
    }
    
    private var _hasChanged:Bool = false;
    private function onFileInputChanged(e) {
        _hasChanged = true;
        var infos:Array<SelectedFileInfo> = [];
        var files:Array<Dynamic> = [];
        var selectedFiles:Dynamic = e.target.files;
        for (i in 0...selectedFiles.length) {
            var selectedFile = selectedFiles[i];
            var info:SelectedFileInfo = {
                name: selectedFile.name,
                isBinary: false
            }
            infos.push(info);
            files.push(selectedFile);
        }
        
        if (_readMode == ReadMode.None) {
            if (_callback != null) {
                _callback(false, infos);
            }
        } else {
            readFileContents(infos.copy(), files, function() {
                _callback(false, infos);
            });
        }
        destroyFileInput();
    }
    
    private function createFileInput(multiple:Bool = false, extensions:Array<FileDialogExtensionInfo>) {
        _hasChanged = false;
        
        Browser.window.addEventListener("focus", onWindowFocus);
        
        _fileInput = Browser.document.createInputElement();
        _fileInput.type = "file";
        _fileInput.id = "fileInput_" + Date.now().toString().replace("-", "_").replace(":", "_").replace(" ", "_");
        _fileInput.style.display = "none";
        _fileInput.accept = buildAcceptString(extensions);
        if (multiple == true) {
            _fileInput.multiple = true;
        }
        _fileInput.onchange = onFileInputChanged;
        Browser.document.body.appendChild(_fileInput);
    }
    
    private function buildAcceptString(extensions:Array<FileDialogExtensionInfo>):String {
        var s = null;
        
        if (extensions != null && extensions.length > 0) {
            var arr = [];
            for (e in extensions) {
                var ext = e.extension;
                ext = ext.trim();
                if (ext.length == 0) {
                    continue;
                }
                var parts = ext.split(",");
                for (p in parts) {
                    p = p.trim();
                    if (p.length == 0) {
                        continue;
                    }
                    arr.push("." + p);
                }
            }
            s = arr.join(",");
        }
        
        return s;
    }
    
    private function readFileContents(infos:Array<SelectedFileInfo>, files:Array<Dynamic>, callback:Void->Void) {
        if (infos.length == 0) {
            callback();
            return;
        }
        
        var info:SelectedFileInfo = infos.shift();
        var file:Dynamic = files.shift();
        var reader = new FileReader();
        if (_readMode == ReadMode.Text) {
            reader.readAsText(file, "UTF-8");
        } else if (_readMode == ReadMode.Binary) {
            reader.readAsArrayBuffer(file);
        }
        
        reader.onload = function(readerEvent) {
            var result:Dynamic = readerEvent.target.result;
            if (_readMode == ReadMode.Text) {
                info.isBinary = false;
                info.text = result;
            } else if (_readMode == ReadMode.Binary) {
                info.isBinary = true;
                info.bytes = Bytes.ofData(result);
            }
            
            readFileContents(infos, files, callback);
        }
    }
    
    private function onWindowFocus(e) { // js doesnt allow you to know when dialog has been cancelled, so lets use a window focus event
        Timer.delay(function() {
            destroyFileInput();
            if (_hasChanged == false) {
                if (_callback != null) {
                    _callback(true, null);
                }
            }
        }, 200);
    }
    
    private function destroyFileInput() {
        if (_fileInput == null) {
            return;
        }
        
        Browser.window.removeEventListener("focus", onWindowFocus);
        
        _fileInput.onchange = null;
        Browser.document.body.removeChild(_fileInput);
        _fileInput = null;
    }
}

#else 

enum ReadMode {
    None;
    Text;
    Binary;
}

@:noCompletion
class FileSelector {
    
    public function new() {
    }
    
    public function selectFile(callback:Bool->Array<SelectedFileInfo>->Void, readMode:String = "none", multiple:Bool = false, extensions:Array<FileDialogExtensionInfo> = null) {
    }
}
#end