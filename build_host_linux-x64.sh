#!/bin/bash

pushd Sources/Renderer/Host
flutter build linux --release --local-engine-src-path="$SCARLETUI_FLUTTER_ENGINE" --local-engine=host_release
popd
