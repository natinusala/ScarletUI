# ScarletUI

A description of this package.

# TODO: SPM plugin to regenerate bindings when they change and rebuild the host

## External dependencies

- Python 3
    - [gyb](https://pypi.org/project/gyb/)
- patchelf

## Using a prebuilt Flutter Engine

## Building the Flutter Engine manually

To use ScarletUI in your project, you need to build your own version of the C++ Flutter Engine. Sadly the prebuilt Engine Embedder target provided by Google comes with the Dart VM in interpreter / JIT mode, and we need it to be in AOT mode ("precompiled code") to run as fast as possible.

This step is only necessary once.

Follow the steps described [here](https://github.com/flutter/flutter/wiki/Setting-up-the-Engine-development-environment) but replace the URL by this fork: `https://github.com/natinusala/engine`. Checkout the commit defined in `Sources/Renderer/FlutterEngine.swift`.

On Ubuntu, use `./flutter/build_scarletui_ubuntu.sh` from inside the buildroot (`src`) to build the library with the correct flags. Then `sudo ./flutter/build_scarletui_ubuntu.sh` to install it and make it available to `pkg-config` system wide.

Finally, add a `SCARLETUI_FLUTTER_ENGINE` environment variable that points to the `src` folder because Flutter needs it to build the host app in the next step.

You might want to run `sudo ldconfig /usr/local/lib` to make sure the library can be found by the linker at runtime.

## Building the host Flutter app

Since the renderer is written in Dart, you also need to build the "host" Flutter app, in Dart, giving the custom engine built at the previous step.

This step is only necessary once if you don't intend to edit the Dart bindings. Otherwise you'll need to rebuild the host app after every change.

First you need to install regular Flutter on your regular system. Please make sure to get any version with the same "Engine revision" as the Engine commit checked out earlier. You can check with `flutter doctor -v`.

Then run the appropriate `build_host_SYSTEM-ARCH.sh` script in this repository. That will build the host and place the output at the right location for ScarletUI to find and use.
