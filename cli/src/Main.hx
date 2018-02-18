package;

import commands.CommandFactory;
import descriptors.DescriptorFactory;
import descriptors.HxmlFile;
import descriptors.InfoFile;
import descriptors.KhaFile;
import descriptors.NMEProjectNmml;
import descriptors.OpenFlApplicationXml;
import projects.Project;
import projects.ProjectFactory;
import sys.FileSystem;
import sys.io.File;

class Main {
	public static function main() {
        /*
        var s = File.getContent("C:\\Users\\Ian Harrigan\\Downloads\\test_pixijs\\html5.hxml");
        var hxml = new HxmlFile();
        hxml.load("C:\\Users\\Ian Harrigan\\Downloads\\test_pixijs\\html5.hxml");
        trace("html5.hxml: " + hxml.main);
        
        var openfl = new OpenFlApplicationXml();
        openfl.load("C:\\Users\\Ian Harrigan\\Downloads\\test_pixijs\\application.xml");
        trace("openfl: " + openfl.main);
        
        var nme = new NMEProjectNmml();
        nme.load("Z:\\TestApps\\ValidationTests\\project.nmml");
        trace("nme: " + nme.main);
        
        var info = new InfoFile();
        info.load("C:\\Temp\\haxeui_test2");
        trace("info: " + info.main);
        
        var kha = new KhaFile();
        kha.load("C:\\Temp\\haxeui_test3\\khafile.js");
        trace("kha: " + kha.main);
        
        
        var d = DescriptorFactory.find("C:\\Users\\Ian Harrigan\\Downloads\\test_pixijs\\");
        trace(Type.getClassName(Type.getClass(d)));
        
        return; 
        */
        
        Util.log("");
        
        var args = Sys.args();
        
        var cwd = Sys.getCwd();
        var target = args.pop();
        var command = args.shift();
        
        var backend = null;
        for (a in args) {
            if (Util.isBackend(a)) {
                backend = a;
                args.remove(a);
                break;
            }
        }
        
        var params:Params = {
            cwd: cwd,
            target: target,
            command: command,
            backend: backend,
            additional: args
        }
        
        if (params.command == null) {
            Util.log('ERROR: no command specified');
            return;
        }
        
        var command = CommandFactory.get(params.command);
        if (command == null) {
            Util.log('ERROR: command "${params.command}" not recognized');
            return;
        }
        
        #if !debug
        
        try {
            command.execute(params);
        } catch (e:Dynamic) {
            Util.log(e);
        }
        
        #else
        
        command.execute(params);
        
        #end
    }
}
