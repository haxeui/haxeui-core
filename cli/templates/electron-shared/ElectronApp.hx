package;

import electron.main.BrowserWindow;
import js.Node;

class ElectronApp {
    static var window:BrowserWindow;

    static function createWindow() {
        window = new BrowserWindow({
            show: false,
            webPreferences: {
                nodeIntegration: true
            }
        });
        window.setMenu(null);
        window.on(closed, function() {
            window = null;
        });
        window.loadFile('index.html');
        //window.maximize();
        //window.webContents.openDevTools();
        window.show();
        window.focus();
        window.focusOnWebView();

        window.setMenuBarVisibility(false);
    }

    static function main() {
        electron.CrashReporter.start({
            companyName: '::name::',
            submitURL : "https://haxeui.org"
        });

        electron.main.App.on(ready, function(e) {
            createWindow();
        });

        electron.main.App.on(window_all_closed, function(e) {
            if (Node.process.platform != 'darwin') {
                electron.main.App.quit();
            }
        });
    }
}
