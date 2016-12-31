<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui2-warning.png"/>
</p>

[![Build Status](https://travis-ci.org/haxeui/haxeui-core.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-core)
[![Code Climate](https://codeclimate.com/github/haxeui/haxeui-core/badges/gpa.svg)](https://codeclimate.com/github/haxeui/haxeui-core)
[![Issue Count](https://codeclimate.com/github/haxeui/haxeui-core/badges/issue_count.svg)](https://codeclimate.com/github/haxeui/haxeui-core)
[![Support this project on Patreon](https://dl.dropboxusercontent.com/u/26678671/patreon_button.png)](https://www.patreon.com/haxeui)

<h2>haxeui-core</h2>

`haxeui-core` is a users universal entry point into the HaxeUI framework and allows for the same user interface code (either with markup or via `haxe` source code) to be used to build a user interface on various platforms using various HaxeUI `backends`. Below is a general overview of how `haxeui-core` and the various HaxeUI `backends` fit together. You can watch a presentation (given at WWX2016) about HaxeUI to get more of an understanding <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">here</a>.

<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui-overview.png"/>
</p>

<h2>Installation</h2>
Eventually all these libs will become haxelibs, however, currently in their alpha form they do not even contain a `haxelib.json` file (for dependencies, etc) and therefore can only be used by downloading the source and using the `haxelib dev` command or by directly using the git versions using the `haxelib git` command (recommended). Eg:

```
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib dev haxeui-openfl path/to/expanded/source/archive
```


<h2>Backends</h2>
In general, using a HaxeUI `backend` is as simple as just including `haxeui-core` and the `backend` library into your application, for example:

```
-lib haxeui-core
-lib haxeui-openfl
```

Currently, HaxeUI supports the following `backends`. Please refer to each `backend` for specific instructions on how to set-up and initialise the host framework (if required).

| Backend Library                   | Dependencies        | Platforms | Native Components | CI |
| ------------- | -----------------------| ----------------- | :-----: | :------: |
| <a href="https://github.com/haxeui/haxeui-openfl">haxeui-openfl</a> | `OpenFL` / `Lime` | <img src="https://dl.dropboxusercontent.com/u/26678671/mobile.png" title="Mobile"> <img src="https://dl.dropboxusercontent.com/u/26678671/desktop.png" title="Desktop"> <img src="https://dl.dropboxusercontent.com/u/26678671/browser.png" title="Browser"> | <img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-openfl.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-openfl) |
| <a href="https://github.com/haxeui/haxeui-flambe">haxeui-flambe</a> | `Flambe` | <img src="https://dl.dropboxusercontent.com/u/26678671/mobile.png" title="Mobile">, <img src="https://dl.dropboxusercontent.com/u/26678671/browser.png" title="Browser"> | <img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-flambe.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-flambe) |
| <a href="https://github.com/haxeui/haxeui-kha">haxeui-kha</a> | `Kha` | <img src="https://dl.dropboxusercontent.com/u/26678671/mobile.png" title="Mobile"> <img src="https://dl.dropboxusercontent.com/u/26678671/desktop.png" title="Desktop"> <img src="https://dl.dropboxusercontent.com/u/26678671/browser.png" title="Browser"> | <img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-kha.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-kha) |
| <a href="https://github.com/haxeui/haxeui-html5">haxeui-html5</a> | _`none`_ | <img src="https://dl.dropboxusercontent.com/u/26678671/browser.png" title="Browser"> | <img src="https://dl.dropboxusercontent.com/u/26678671/tick.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-html5.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-html5) |
| <a href="https://github.com/haxeui/haxeui-pixijs">haxeui-pixijs</a> | `PixiJS` | <img src="https://dl.dropboxusercontent.com/u/26678671/browser.png" title="Browser"> | <img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-pixijs.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-pixijs) |
| <a href="https://github.com/haxeui/haxeui-nme">haxeui-nme</a> | `NME` | <img src="https://dl.dropboxusercontent.com/u/26678671/mobile.png" title="Mobile"> <img src="https://dl.dropboxusercontent.com/u/26678671/desktop.png" title="Desktop"> <img src="https://dl.dropboxusercontent.com/u/26678671/browser.png" title="Browser"> | <img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-nme.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-nme) |
| <a href="https://github.com/haxeui/haxeui-luxe">haxeui-luxe</a> | `luxe` | <img src="https://dl.dropboxusercontent.com/u/26678671/mobile.png" title="Mobile"> <img src="https://dl.dropboxusercontent.com/u/26678671/desktop.png" title="Desktop"> <img src="https://dl.dropboxusercontent.com/u/26678671/browser.png" title="Browser"> | <img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-luxe.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-luxe) |
| <a href="https://github.com/haxeui/haxeui-hxwidgets">haxeui-hxwidgets</a> | `hxWidgets` / `wxWidgets` | <img src="https://dl.dropboxusercontent.com/u/26678671/desktop.png" title="Desktop"> | <img src="https://dl.dropboxusercontent.com/u/26678671/tick.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-hxwidgets.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-hxwidgets) |
| <a href="https://github.com/haxeui/haxeui-xwt">haxeui-xwt</a> | `Xwt` | <img src="https://dl.dropboxusercontent.com/u/26678671/desktop.png" title="Desktop"> | <img src="https://dl.dropboxusercontent.com/u/26678671/tick.png"> | [![Build Status](https://travis-ci.org/haxeui/haxeui-xwt.svg?branch=master)](https://travis-ci.org/haxeui/haxeui-xwt) [![Build status](https://ci.appveyor.com/api/projects/status/2phv2o2wg8md1ygo/branch/master?svg=true)](https://ci.appveyor.com/project/ibilon/haxeui-xwt/branch/master) |


<h2>Usage</h2>
Assuming that `haxeui-core` and the `backend` library have been included in your application, initialising the toolkit and using it should be relatively straight forward:

```haxe
Toolkit.init();
```

The `init` function can take an optional `Dynamic` argument that allows certain options to be passed to the host framework. Please refer to each specific backend on how to use these. 

Once the toolkit has been initialised components can be added in one of two ways:

<h3>Adding components using Haxe code</h3>
Using HaxeUI components in haxe code is simple and easy:

```haxe
var main:VBox = new VBox();

var button:Button = new Button();
button.text = "Button 1";
main.addComponent(button1);

var button:Button = new Button();
button.text = "Button 2";
main.addComponent(button1);

Screen.instance.addComponent(main);
```

_Note: `Screen` was used here as a universal way to add items to the application, this is not required however, if you are using a single framework and are not interested in the cross-framework capabilities of HaxeUI, then you can use something more specific to the target framework (eg: `Lib.current.stage.addChild(main)`)._

<h3>Adding components from markup</h3>
It is also possible for HaxeUI to take a user interface definition from a markup language (like XML) and use that to build code similar to above:

```haxe
var main = ComponentMacros.buildComponent("assets/ui/demo/main.xml");
Screen.instance.addComponent(main);
```

_Note: in the alpha release of haxeui-core there is currently no support for building a user interface from markup at runtime, however, this is **certainly** something that will be implemented._

<h2>Additional resources</h2>
* <a href="http://haxeui.github.io/haxeui-api/">haxeui-api</a> - The HaxeUI api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with HaxeUI and backends.
* <a href="https://github.com/haxeui/haxeui-demo">haxeui-demo</a> - Demo application written using HaxeUI.
* <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a> - Set of templates for IDEs to allow quick project creation.
* <a href="https://github.com/haxeui/haxeui-bdd">haxeui-bdd</a> - A behaviour driven development engine written specifically for HaxeUI (uses <a href="https://github.com/haxeui/haxe-bdd">haxe-bdd</a> which is a gherkin/cucumber inspired project).
* <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">WWX2016 presentation</a> - A presentation given at WWX2016 regarding HaxeUI.

