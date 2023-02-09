#!/bin/bash

pushd Sources/Renderer/Host
flutter build linux --profile --local-engine-src-path="$SCARLETUI_FLUTTER_ENGINE" --local-engine=host_profile_unopt
popd

mkdir -p .build/scarletui_host/libapp
gyb libapp.modulemap.gyb -DLIBAPP_PATH=$(pwd)/Sources/Renderer/Host/build/linux/x64/profile/bundle/lib/libapp.so -o .build/scarletui_host/libapp/module.modulemap

echo "#include <stdint.h>" > .build/scarletui_host/libapp/libapp.h
echo "extern uint8_t* _kDartIsolateSnapshotData;" >> .build/scarletui_host/libapp/libapp.h
echo "extern uint8_t* _kDartIsolateSnapshotInstructions;" >> .build/scarletui_host/libapp/libapp.h
echo "extern uint8_t* _kDartVmSnapshotData;" >> .build/scarletui_host/libapp/libapp.h
echo "extern uint8_t* _kDartVmSnapshotInstructions;" >> .build/scarletui_host/libapp/libapp.h
