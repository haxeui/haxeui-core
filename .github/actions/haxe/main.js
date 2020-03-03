const core = require('@actions/core');
const github = require('@actions/github');
const fs = require('fs');
const child_process = require('child_process');

try {
    var haxeVersion = core.getInput('haxe-version');
    var platform = core.getInput('platform');
    if (platform == null || platform.length == 0) {
        if (process.platform.startsWith("linux")) {
            platform = "linux64"
        } else if (process.platform.startsWith("darwin")) {
            platform = "osx"
        } else if (process.platform.startsWith("win")) {
            platform = "win64"
        }

        console.log("platform guessed as: " + platform);
    }

    var installLocation = "/usr/local/bin/haxe";
    var haxelibLocation = "/usr/local/bin/haxe/haxelibs";

    console.log("haxeVersion: " + haxeVersion);
    console.log("platform: " + platform);

    if (platform == "linux64") {
        child_process.execSync('sudo rm -f /etc/apt/sources.list.d/dotnetdev.list /etc/apt/sources.list.d/microsoft-prod.list', {stdio: 'inherit'});
        child_process.execSync('sudo add-apt-repository ppa:haxe/snapshots -y', {stdio: 'inherit'});
        child_process.execSync('sudo apt-get update', {stdio: 'inherit'});
        child_process.execSync('sudo apt install neko -y', {stdio: 'inherit'});

        installLocation = "/opt/haxe";
        haxelibLocation = "/opt/haxe/haxelibs";
    } else if (platform == "osx") {
        child_process.execSync('brew install neko', {stdio: 'inherit'});
    } else if (platform == "win64") {
        installLocation = "D:\\haxe";
        haxelibLocation = "D:\\haxe\\haxelibs";
    }

    var filename = "haxe-" + haxeVersion + "-" + platform;
    if (platform == "linux64" || platform == "osx") {
        filename += ".tar.gz";
    } else if (platform == "win64") {
        filename += ".zip";
    }

    var archiveUrl = "http://github.com/HaxeFoundation/haxe/releases/download/" + haxeVersion + "/" + filename;

    if (platform == "linux64" || platform == "osx") {
        console.log("Downloading haxe from: " + archiveUrl);

        child_process.execSync('wget ' + archiveUrl, {stdio: 'inherit'});
        fs.mkdirSync(installLocation);
        child_process.execSync('tar -C ' + installLocation + ' -zxvf ' + filename + ' --strip 1', {stdio: 'inherit'});
        child_process.execSync("chmod 777 " + installLocation + "/haxe", {stdio: 'inherit'});
        child_process.execSync("chmod 777 " + installLocation + "/haxelib", {stdio: 'inherit'});
        fs.mkdirSync(haxelibLocation);
        child_process.execSync(installLocation + "/haxelib setup " + haxelibLocation, {stdio: 'inherit'});
    } else if (platform == "win64") {
        child_process.execSync('powershell ' + __dirname + '/download-file-windows.ps1 -url ' + archiveUrl + ' -output ' + filename, {stdio: 'inherit'});
        fs.mkdirSync(installLocation);
        child_process.execSync('powershell ' + __dirname + '/unzip-file-windows.ps1 -file ' + filename + ' -output ' + installLocation, {stdio: 'inherit'});
        fs.mkdirSync(haxelibLocation);
        
        var nekoPath = __dirname + "\\neko-2.3.0-win64";
        if (haxeVersion.startsWith("3")) {
            nekoPath = __dirname + "\\neko-2.3.0-win";
        }
        core.addPath(nekoPath);
        core.exportVariable("NEKO_INSTPATH", nekoPath);
        process.env['NEKO_INSTPATH'] = nekoPath;

        fs.writeFileSync(process.env["USERPROFILE"] + "\\.haxelib", haxelibLocation);
    }
    
    core.addPath(installLocation);
    core.exportVariable("HAXELIB_PATH", haxelibLocation);
    core.exportVariable("HAXEPATH", installLocation);
    core.exportVariable("HAXE_STD_PATH", installLocation + "/std");
} catch (error) {
    core.setFailed(error.message);
}