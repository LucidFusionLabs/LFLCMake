# $Id: LFLPackage.cmake 1335 2014-12-02 04:13:46Z justin $

if(LFL_EMSCRIPTEN)
  function(lfl_post_build_copy_asset_bin target source_target)
  endfunction()

  function(lfl_post_build_copy_bin target source_target)
  endfunction()

  function(lfl_post_build_start target)
  endfunction()

  macro(lfl_add_package target)
    lfl_add_target(${target} EXECUTABLE ${ARGN})
    set_target_properties(${target} PROPERTIES OUTPUT_NAME ${target}.html)
    set_target_properties(${target} PROPERTIES LINK_FLAGS
      "--embed-file assets -s USE_SDL=2 -s USE_LIBPNG=1 -s USE_ZLIB=1 -s TOTAL_MEMORY=20971520")

    add_custom_command(TARGET ${target} PRE_LINK WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND rm -rf assets
      COMMAND mkdir assets
      COMMAND cp ${${target}_ASSET_FILES} assets)
  endmacro()

elseif(LFL_ANDROID)
  function(lfl_post_build_copy_asset_bin target source_target)
  endfunction()

  function(lfl_post_build_copy_bin target source_target)
  endfunction()

  function(lfl_post_build_start target)
    add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${target}-android
      COMMAND ${LFL_SOURCE_DIR}/core/script/CopyAndroidPackageAssets.sh ${${target}_ASSET_FILES})

    add_custom_target(${target}_release WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${target}-android DEPENDS ${target}
      COMMAND "JAVA_HOME=${JAVA_HOME}" "ANDROID_HOME=${ANDROID_HOME}" ${GRADLE_HOME}/bin/gradle uninstallRelease
      COMMAND "JAVA_HOME=${JAVA_HOME}" "ANDROID_HOME=${ANDROID_HOME}" ${GRADLE_HOME}/bin/gradle assembleRelease
      COMMAND ${ANDROID_HOME}/platform-tools/adb install ./build/outputs/apk/${target}-android-release.apk
      COMMAND ${ANDROID_HOME}/platform-tools/adb shell am start -n `${ANDROID_HOME}/build-tools/19.1.0/aapt dump badging ./build/outputs/apk/${target}-android-release.apk | grep package | cut -d\\' -f2`/`${ANDROID_HOME}/build-tools/19.1.0/aapt dump badging ./build/outputs/apk/${target}-android-release.apk | grep launchable-activity | cut -d\\' -f2`
      COMMAND ${ANDROID_HOME}/platform-tools/adb logcat | tee ${CMAKE_CURRENT_BINARY_DIR}/debug.txt)

    add_custom_target(${target}_debug WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${target}-android DEPENDS ${target}
      COMMAND "JAVA_HOME=${JAVA_HOME}" "ANDROID_HOME=${ANDROID_HOME}" ${GRADLE_HOME}/bin/gradle uninstallDebug
      COMMAND "JAVA_HOME=${JAVA_HOME}" "ANDROID_HOME=${ANDROID_HOME}" ${GRADLE_HOME}/bin/gradle   installDebug
      COMMAND ${ANDROID_HOME}/platform-tools/adb shell am start -n `${ANDROID_HOME}/build-tools/19.1.0/aapt dump badging ./build/outputs/apk/${target}-android-debug.apk | grep package | cut -d\\' -f2`/`${ANDROID_HOME}/build-tools/19.1.0/aapt dump badging ./build/outputs/apk/${target}-android-debug.apk | grep launchable-activity | cut -d\\' -f2`
      COMMAND ${ANDROID_HOME}/platform-tools/adb logcat | tee ${CMAKE_CURRENT_BINARY_DIR}/debug.txt)

    add_custom_target(${target}_debug_start WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${target}-android DEPENDS ${target}
      COMMAND ${ANDROID_HOME}/platform-tools/adb shell am start -n `${ANDROID_HOME}/build-tools/19.1.0/aapt dump badging ./build/outputs/apk/${target}-android-debug.apk | grep package | cut -d\\' -f2`/`${ANDROID_HOME}/build-tools/19.1.0/aapt dump badging ./build/outputs/apk/${target}-android-debug.apk | grep launchable-activity | cut -d\\' -f2`
      COMMAND ${ANDROID_HOME}/platform-tools/adb logcat | tee ${CMAKE_CURRENT_BINARY_DIR}/debug.txt)

    add_custom_target(${target}_help WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND echo "Symbolicate with: ${ANDROID_NDK_HOME}/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-addr2line -C -f -e libnative-lib.so 008bd340")
  endfunction()

  macro(lfl_add_package target)
    lfl_add_target(${target} SHARED_LIBRARY ${ARGN})
    set_target_properties(${target} PROPERTIES OUTPUT_NAME native-lib)
  endmacro()

elseif(LFL_IOS)
  function(lfl_post_build_copy_asset_bin target source_target)
  endfunction()

  function(lfl_post_build_copy_bin target source_target)
  endfunction()

  function(lfl_post_build_start target)
    string(REPLACE ";" " " IOS_CERT "${LFL_IOS_CERT}")
    set_target_properties(${target} PROPERTIES
                          MACOSX_BUNDLE TRUE
                          XCODE_ATTRIBUTE_SKIP_INSTALL NO
                          XCODE_ATTRIBUTE_ENABLE_BITCODE FALSE
                          XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${IOS_CERT}"
                          XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${LFL_IOS_TEAM}"
                          XCODE_ATTRIBUTE_PROVISIONING_PROFILE_SPECIFIER "${LFL_IOS_PROVISION_NAME}")

    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Assets.xcassets/Contents.json)
      set_target_properties(${target} PROPERTIES RESOURCE ${target}-ios/Assets.xcassets)
    endif()
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Assets.xcassets/AppIcon.appiconset)
      set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon")
    endif()
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Info.plist)
      set_target_properties(${target} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Info.plist)
    endif()

    if(LFL_XCODE)
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/BundleRoot/* "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app"
        COMMAND for d in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/\*.lproj\;  do if [ -d $$d ]; then cp -R $$d "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app" \; fi\; done
        COMMAND for d in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/\*.bundle\; do if [ -d $$d ]; then cp -R $$d "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app" \; fi\; done
        COMMAND for f in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Resources/\*\; do o=`basename $$f | sed s/xib$$/nib/`\; ${LFL_APPLE_DEVELOPER}/usr/bin/ibtool --warnings --errors --notices --compile "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app/\$\$o" $$f\; done
        COMMAND for d in ${LFL_SOURCE_DIR}/core/imports/appirater/\*.lproj\; do if [ -d $$d ]; then o=`basename $$d` \; if [ -d "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app/$$o" ]; then cp $$d/* "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app/$$o" \; fi\; fi\; done)
    else()
      set(should_sign)
      if(NOT LFL_IOS_SIM AND LFL_IOS_CERT)
        set(should_sign 1)
      endif()
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND rm -rf ${target}.dSYM
        COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/BundleRoot/* $<TARGET_FILE_DIR:${target}>
        COMMAND for d in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/\*.lproj\;  do if [ -d $$d ]; then cp -R $$d $<TARGET_FILE_DIR:${target}>\; fi\; done
        COMMAND for d in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/\*.bundle\; do if [ -d $$d ]; then cp -R $$d $<TARGET_FILE_DIR:${target}>\; fi\; done
        COMMAND for f in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Resources/\*\; do o=`basename $$f | sed s/xib$$/nib/`\; ${LFL_APPLE_DEVELOPER}/usr/bin/ibtool --warnings --errors --notices --compile $<TARGET_FILE_DIR:${target}>/$$o $$f\; done
        COMMAND for d in ${LFL_SOURCE_DIR}/core/imports/appirater/\*.lproj\; do if [ -d $$d ]; then o=`basename $$d` \; if [ -d "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app/$$o" ]; then cp $$d/* "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app/$$o" \; fi\; fi\; done
        COMMAND dsymutil $<TARGET_FILE:${target}> -o ${target}.dSYM
        COMMAND if [ ${should_sign} ]\; then codesign -f -s \"${LFL_IOS_CERT}\"
        --entitlements ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Entitlements.plist $<TARGET_FILE_DIR:${target}>\; fi)
    endif()

    add_custom_target(${target}_pkg WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
      COMMAND rm -rf i${target}.ipa
      COMMAND /usr/bin/xcrun -sdk iphoneos PackageApplication -v $<TARGET_FILE_DIR:${target}>
      -o ${CMAKE_CURRENT_BINARY_DIR}/i${target}.ipa --sign \"${LFL_IOS_CERT}\" --embed ${LFL_IOS_PROVISION})

    add_custom_target(${target}_help WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND echo "Symbolicate with: atos -arch armv7 -o $<TARGET_FILE:${target}> -l 0xcc000 0x006cf99f")

    if(LFL_IOS_SIM)
      add_custom_target(${target}_run WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
        COMMAND if pgrep -f Simulator.app\; then echo\; else nohup /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/Contents/MacOS/Simulator & sleep 5\; fi
        COMMAND xcrun simctl install booted $<TARGET_FILE_DIR:${target}> || { tail -1 $ENV{HOME}/Library/Logs/CoreSimulator/CoreSimulator.log && false\; }
        COMMAND xcrun simctl launch booted `cat ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Info.plist | grep BundleIdentifier -A1 | tail -1 | cut -f2 -d\\> | cut -f1 -d \\<`
        COMMAND touch   `find $ENV{HOME}/Library/Developer/CoreSimulator/Devices/\\`xcrun simctl list | grep Booted | head -1 | cut -f2 -d\\\( -f2 | cut -f1 -d\\\)\\`/data/Containers/Bundle/Application -name ${target}.app`/${target}.txt
        COMMAND tail -f `find $ENV{HOME}/Library/Developer/CoreSimulator/Devices/\\`xcrun simctl list | grep Booted | head -1 | cut -f2 -d\\\( -f2 | cut -f1 -d\\\)\\`/data/Containers/Bundle/Application -name ${target}.app`/${target}.txt | tee debug.txt)

      add_custom_target(${target}_run_syslog WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
        COMMAND if pgrep iOS\ Simulator\; then echo\; else nohup /Applications/Xcode.app/Contents/Developer/Applications/iOS\ Simulator.app/Contents/MacOS/iOS\ Simulator & sleep 5\; fi
        COMMAND xcrun simctl install booted $<TARGET_FILE_DIR:${target}> || { tail -1 $ENV{HOME}/Library/Logs/CoreSimulator/CoreSimulator.log && false\; }
        COMMAND xcrun simctl launch booted `cat ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Info.plist | grep BundleIdentifier -A1 | tail -1 | cut -f2 -d\\> | cut -f1 -d \\<`
        COMMAND echo tail -f ~/Library/Logs/CoreSimulator/`xcrun simctl list | grep Booted | head -1 | cut -f2 -d\\\( -f2 | cut -f1 -d\\\)`/system.log
        COMMAND      tail -f ~/Library/Logs/CoreSimulator/`xcrun simctl list | grep Booted | head -1 | cut -f2 -d\\\( -f2 | cut -f1 -d\\\)`/system.log)

      add_custom_target(${target}_debug WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
        COMMAND if pgrep iOS\ Simulator\; then echo\; else nohup /Applications/Xcode.app/Contents/Developer/Applications/iOS\ Simulator.app/Contents/MacOS/iOS\ Simulator & sleep 5\; fi
        COMMAND xcrun simctl install booted $<TARGET_FILE_DIR:${target}> || { tail -1 $ENV{HOME}/Library/Logs/CoreSimulator/CoreSimulator.log && false\; }
        COMMAND find $ENV{HOME}/Library/Developer/CoreSimulator/Devices/`xcrun simctl list | grep Booted | head -1 | cut -f2 -d\\\( -f2 | cut -f1 -d\\\)`/data/Containers/Bundle/Application -name ${target}.app
        COMMAND xcrun simctl launch booted `cat ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/Info.plist | grep BundleIdentifier -A1 | tail -1 | cut -f2 -d\\> | cut -f1 -d \\<`
        COMMAND lldb -n ${target} -o cont)

    else()
      add_custom_target(${target}_run WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
        COMMAND ios-deploy --bundle $<TARGET_FILE_DIR:${target}> 
        COMMAND zip deployed-`date +\"%Y-%m-%d_%H_%M_%S\"`-${target}.zip -r $<TARGET_FILE_DIR:${target}>)
      add_custom_target(${target}_debug WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
        COMMAND ios-deploy --debug --bundle $<TARGET_FILE_DIR:${target}>)
    endif()
  endfunction()

  macro(lfl_add_package target)
    lfl_add_target(${target} EXECUTABLE ${ARGN})
  endmacro()

elseif(LFL_OSX)
  function(lfl_post_build_copy_asset_bin target source_target)
    if(LFL_XCODE)
      string(REPLACE ";" " " OSX_CERT "${LFL_OSX_CERT}")
      set_target_properties(${source_target} PROPERTIES
                            XCODE_ATTRIBUTE_SKIP_INSTALL YES
                            XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
                            XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY[variant=Release] "${OSX_CERT}"
                            XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${LFL_OSX_TEAM}")
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND cp "\${BUILT_PRODUCTS_DIR}/${source_target}" "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.\${WRAPPER_EXTENSION}/Contents/Resources/assets")
    else()
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND cp $<TARGET_FILE:${source_target}> $<TARGET_FILE_DIR:${target}>/../Resources/assets)
    endif()
  endfunction()

  function(lfl_post_build_copy_bin target source_target)
    if(LFL_XCODE)
      string(REPLACE ";" " " OSX_CERT "${LFL_OSX_CERT}")
      set_target_properties(${source_target} PROPERTIES
                            XCODE_ATTRIBUTE_SKIP_INSTALL YES
                            XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
                            XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY[variant=Release] "${OSX_CERT}"
                            XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${LFL_OSX_TEAM}")
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND cp "\${BUILT_PRODUCTS_DIR}/${source_target}" "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.\${WRAPPER_EXTENSION}/Contents/MacOS")
    else()
      set(should_sign)
      if(LFL_OSX_CERT)
        set(should_sign 1)
      endif()
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND cp $<TARGET_FILE:${source_target}> $<TARGET_FILE_DIR:${target}>/${source_target}
        COMMAND install_name_tool -change /usr/local/lib/libportaudio.2.dylib @loader_path/../Libraries/libportaudio.2.dylib $<TARGET_FILE_DIR:${target}>/${source_target}
        COMMAND install_name_tool -change /usr/local/lib/libmp3lame.0.dylib @loader_path/../Libraries/libmp3lame.0.dylib $<TARGET_FILE_DIR:${target}>/${source_target}
        COMMAND install_name_tool -change lib/libopencv_core.3.1.dylib @loader_path/../Libraries/libopencv_core.3.1.dylib $<TARGET_FILE_DIR:${target}>/${source_target}
        COMMAND install_name_tool -change lib/libopencv_imgproc.3.1.dylib @loader_path/../Libraries/libopencv_imgproc.3.1.dylib $<TARGET_FILE_DIR:${target}>/${source_target}
        COMMAND if [ ${should_sign} ]; then codesign -f -s \"${LFL_OSX_CERT}\" $<TARGET_FILE_DIR:${target}>/${source_target} \; fi)
    endif()

    add_custom_target(${source_target}_run WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${source_target}
      COMMAND $<TARGET_FILE_DIR:${target}>/${source_target})

    add_custom_target(${source_target}_debug WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${source_target}
      COMMAND lldb -f $<TARGET_FILE_DIR:${target}>/${source_target} -o run)
  endfunction()

  function(lfl_post_build_start target)
    string(REPLACE ";" " " OSX_CERT "${LFL_OSX_CERT}")
    set_target_properties(${target} PROPERTIES
                          XCODE_ATTRIBUTE_SKIP_INSTALL NO
                          XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
                          XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY[variant=Release] "${OSX_CERT}"
                          XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${LFL_OSX_TEAM}"
                          XCODE_ATTRIBUTE_PROVISIONING_PROFILE_SPECIFIER "${LFL_OSX_PROVISION_NAME}")
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/Assets.xcassets/Contents.json)
      set_target_properties(${target} PROPERTIES RESOURCE ${target}-mac/Assets.xcassets)
    endif()
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/Assets.xcassets/AppIcon.appiconset)
      set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon")
    endif()
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/Info.plist)
      set_target_properties(${target} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/Info.plist)
    endif()
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/icon.icns)
      set_target_properties(${target} PROPERTIES MACOSX_BUNDLE_ICON_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/icon.icns)
    endif()
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/Entitlements.plist)
      set_target_properties(${target} PROPERTIES XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/Entitlements.plist)
    endif()

    if(LFL_XCODE)
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND for d in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/\*.lproj\; do if [ -d $$d ]; then cp -R $$d "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.\${WRAPPER_EXTENSION}/Contents/Resources" \; fi\; done
        COMMAND if [ -f ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/icon.icns ]; then cp ${CMAKE_CURRENT_SOURCE_DIR}/${target}-mac/icon.icns "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.\${WRAPPER_EXTENSION}/Contents/Resources" \; fi\;)
    else()
        set(copy_lfl_app_lib_files)
      if(${target}_LIB_FILES)
        set(copy_lfl_app_lib_files 1)
      endif()
      add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMAND for d in ${CMAKE_CURRENT_SOURCE_DIR}/${target}-ios/*.lproj\; do if [ -d $$d ]; then cp -R $$d $<TARGET_FILE_DIR:${target}>/../Resources \; fi\; done
        COMMAND mkdir -p $<TARGET_FILE_DIR:${target}>/../Libraries
        COMMAND if [ ${copy_lfl_app_lib_files} ]; then cp ${${target}_LIB_FILES} $<TARGET_FILE_DIR:${target}>/../Libraries\; fi
        COMMAND install_name_tool -change /usr/local/lib/libportaudio.2.dylib @loader_path/../Libraries/libportaudio.2.dylib $<TARGET_FILE:${target}> 
        COMMAND install_name_tool -change /usr/local/lib/libmp3lame.0.dylib @loader_path/../Libraries/libmp3lame.0.dylib $<TARGET_FILE:${target}> 
        COMMAND if [ -f $<TARGET_FILE_DIR:${target}>/../Libraries/libopencv_imgproc.3.1.dylib ]; then install_name_tool -change lib/libopencv_core.3.1.dylib @loader_path/../Libraries/libopencv_core.3.1.dylib $<TARGET_FILE_DIR:${target}>/../Libraries/libopencv_imgproc.3.1.dylib\; fi
        COMMAND install_name_tool -change lib/libopencv_core.3.1.dylib @loader_path/../Libraries/libopencv_core.3.1.dylib $<TARGET_FILE:${target}> 
        COMMAND install_name_tool -change lib/libopencv_imgproc.3.1.dylib @loader_path/../Libraries/libopencv_imgproc.3.1.dylib $<TARGET_FILE:${target}> )
    endif()

    add_custom_target(${target}_pkg WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND codesign -f -s \"${LFL_OSX_CERT}\" $<TARGET_FILE:${target}>
      COMMAND if [ -d /Volumes/${target} ]; then umount /Volumes/${target}\; fi
      COMMAND rm -rf ${target}.dmg ${target}.sparseimage
      COMMAND hdiutil create -size 60m -type SPARSE -fs HFS+ -volname ${target} -attach ${target}.sparseimage
      COMMAND bless --folder /Volumes/${target} --openfolder /Volumes/${target}
      COMMAND cp -r ${target}.app /Volumes/${target}/
      COMMAND ln -s /Applications /Volumes/${target}/.
      COMMAND hdiutil eject /Volumes/${target}
      COMMAND hdiutil convert ${target}.sparseimage -format UDBZ -o ${target}.dmg
      COMMAND codesign -f -s \"${LFL_OSX_CERT}\" ${target}.dmg)

    add_custom_target(${target}_run WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
      COMMAND $<TARGET_FILE:${target}>)

    add_custom_target(${target}_debug WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
      COMMAND lldb -f $<TARGET_FILE:${target}> -o run)

    if(LFL_ADD_BITCODE_TARGETS AND TARGET ${target}_designer)
      lfl_post_build_copy_bin(${target}_designer ${target})
    endif()
  endfunction()

  macro(lfl_add_package target)
    lfl_add_target(${target} EXECUTABLE ${ARGN})
    set_target_properties(${target} PROPERTIES
                          MACOSX_BUNDLE TRUE
                          MACOSX_BUNDLE_BUNDLE_NAME ${target})
  endmacro()

  macro(lfl_add_screensaver target)
    lfl_add_target(${target} MODULE_LIBRARY ${ARGN})
    set_target_properties(${target} PROPERTIES
                          BUNDLE TRUE
                          XCODE_ATTRIBUTE_WRAPPER_EXTENSION "saver"
                          XCODE_ATTRIBUTE_MACH_O_TYPE "mh_bundle"
                          XCODE_ATTRIBUTE_INSTALL_PATH "/Library/Screen Savers")
    add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND mkdir -p "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.\${WRAPPER_EXTENSION}/Contents/Resources/assets"
      COMMAND cp ${${target}_ASSET_FILES} "\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.\${WRAPPER_EXTENSION}/Contents/Resources/assets")
  endmacro()

elseif(LFL_WINDOWS)
  function(lfl_post_build_copy_asset_bin target source_target)
  endfunction()

  function(lfl_post_build_copy_bin target source_target)
  endfunction()

  function(lfl_post_build_start target)
  endfunction()

  macro(lfl_add_package target)
    link_directories(${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
    lfl_add_target(${target} EXECUTABLE WIN32 ${ARGN})
    add_dependencies(${target} zlib)
    if(LFL_JPEG)
      add_dependencies(${target} libjpeg)
    endif()
  endmacro()

elseif(LFL_LINUX)
  function(lfl_post_build_copy_asset_bin target source_target)
  endfunction()

  function(lfl_post_build_copy_bin target source_target)
    if(${target}_INSTALL_BIN)
      install(TARGETS ${source_target} DESTINATION ${${target}_INSTALL_BIN})
    endif()

    add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND cp $<TARGET_FILE:${source_target}> ${target}.app/${source_target})
  endfunction()

  function(lfl_post_build_start target)
    file(GLOB asset_files ${${target}_ASSET_FILES})

    if(${target}_INSTALL_BIN)
      install(TARGETS ${target} DESTINATION ${${target}_INSTALL_BIN})
      install(FILES ${asset_files} DESTINATION ${${target}_INSTALL_RES})
    endif()

    if(${target}_LIB_FILES)
      set(copy_lfl_app_lib_files 1)
      file(GLOB lib_files ${${target}_LIB_FILES})
      if(${target}_INSTALL_BIN)
        install(FILES ${lib_files} DESTINATION ${${target}_INSTALL_RES})
      endif()
    endif()

    add_custom_command(TARGET ${target} POST_BUILD WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMAND rm -rf ${target}.app
      COMMAND mkdir -p ${target}.app/assets
      COMMAND cp $<TARGET_FILE:${target}> ${target}.app/${target}
      COMMAND cp ${${target}_ASSET_FILES} ${target}.app/assets
      COMMAND if [ ${copy_lfl_app_lib_files} ]; then cp ${${target}_LIB_FILES} ${target}.app\; fi)

    add_custom_target(${target}_run WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} DEPENDS ${target}
      COMMAND ${target}.app/${target})
  endfunction()

  macro(lfl_add_package target)
    lfl_add_target(${target} EXECUTABLE ${ARGN})
  endmacro()

else()
  function(lfl_post_build_copy_asset_bin target source_target)
  endfunction()

  function(lfl_post_build_copy_bin target source_target)
  endfunction()

  function(lfl_post_build_start target target)
  endfunction()

  macro(lfl_add_package target)
    lfl_add_target(${target} EXECUTABLE ${ARGN})
  endmacro()
endif()
