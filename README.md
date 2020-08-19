# haxeui-core

`haxeui-core` is a users universal entry point into the HaxeUI framework and allows for the same user interface code (either with markup or via `haxe` source code) to be used to build a user interface on various platforms using various HaxeUI `backends`. Below is a general overview of how `haxeui-core` and the various HaxeUI `backends` fit together. You can watch a presentation (given at WWX2016) about HaxeUI to get more of an understanding <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">here</a>.

<p align="center">
  <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/system.jpg"/>
</p>

## Installation
Installation of the haxeui can be performed by using haxelib, you will need a the haxeui-core haxelib as well as a backend, for example: 
```
haxelib install haxeui-core
haxelib install haxeui-openfl
```


## Backends
In general, using a HaxeUI `backend` is as simple as just including `haxeui-core` and the `backend` library into your application, for example:

```
-lib haxeui-core
-lib haxeui-openfl
```

Currently, HaxeUI supports the following `backends`. Please refer to each `backend` for specific instructions on how to set-up and initialise the host framework (if required).

| Backend Library                   | Dependencies        | Platforms | Native Components |
| ------------- | -----------------------| ----------------- | :-----: |
| <a href="https://github.com/haxeui/haxeui-openfl">haxeui-openfl</a> | `OpenFL` / `Lime` | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/mobile.png" title="Mobile"> <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/desktop.png" title="Desktop"> <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/browser.png" title="Browser"> | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/cross.png"> |
| <a href="https://github.com/haxeui/haxeui-kha">haxeui-kha</a> | `Kha` | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/mobile.png" title="Mobile"> <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/desktop.png" title="Desktop"> <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/browser.png" title="Browser"> | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/cross.png"> |
| <a href="https://github.com/haxeui/haxeui-html5">haxeui-html5</a> | _`none`_ | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/browser.png" title="Browser"> | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/tick.png"> |
| <a href="https://github.com/haxeui/haxeui-pixijs">haxeui-pixijs</a> | `PixiJS` | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/browser.png" title="Browser"> | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/cross.png"> |
| <a href="https://github.com/haxeui/haxeui-nme">haxeui-nme</a> | `NME` | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/mobile.png" title="Mobile"> <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/desktop.png" title="Desktop"> <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/browser.png" title="Browser"> | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/cross.png"> |
| <a href="https://github.com/haxeui/haxeui-hxwidgets">haxeui-hxwidgets</a> | `hxWidgets` / `wxWidgets` | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/desktop.png" title="Desktop"> | <img src="https://raw.githubusercontent.com/haxeui/haxeui-core/master/tick.png"> |


## Usage
Assuming that `haxeui-core` and the `backend` library have been included in your application, initialising the toolkit and using it should be relatively straight forward:

```haxe
Toolkit.init();
```

The `init` function can take an optional `Dynamic` argument that allows certain options to be passed to the host framework. Please refer to each specific backend on how to use these. 

Once the toolkit has been initialised components can be added in one of two ways:

### Adding components using Haxe code
Using HaxeUI components in haxe code is simple and easy:

```haxe
import haxe.ui.components.Button;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;

var main = new VBox();

var button1 = new Button();
button1.text = "Button 1";
main.addComponent(button1);

var button2 = new Button();
button2.text = "Button 2";
main.addComponent(button2);

Screen.instance.addComponent(main);
```

_Note: `Screen` was used here as a universal way to add items to the application, this is not required however, if you are using a single framework and are not interested in the cross-framework capabilities of HaxeUI, then you can use something more specific to the target framework (eg: `Lib.current.stage.addChild(main)`)._

### Adding components from markup
It is also possible for HaxeUI to take a user interface definition from a markup language (like XML) and use that to build code similar to above:

```haxe
var main = ComponentMacros.buildComponent("assets/ui/demo/main.xml");
Screen.instance.addComponent(main);
```
If your xml isn't available at compile time you can use `Toolkit.componentFromString`:

```haxe
var main = Toolkit.componentFromString('<vbox><button text="Button" /></vbox>', "xml");
Screen.instance.addComponent(main);
```

## Addtional resources
* <a href="http://haxeui.org/explorer/">component-explorer</a> - Browse HaxeUI components
* <a href="http://haxeui.org/builder/">playground</a> - Write and test HaxeUI layouts in your browser
* <a href="https://github.com/haxeui/component-examples">component-examples</a> - Various componet examples
* <a href="http://haxeui.org/api/haxe/ui/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
