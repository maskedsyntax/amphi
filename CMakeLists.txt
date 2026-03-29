cmake_minimum_required(VERSION 3.16)
project(amphi VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)
find_package(PkgConfig REQUIRED)
pkg_check_modules(MPV REQUIRED mpv)

qt_add_executable(amphi
    src/main.cpp
    src/mpvitem.cpp
    src/mpvitem.h
    src/playlistmodel.cpp
    src/playlistmodel.h
)

qt_add_qml_module(amphi
    URI amphi
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES
        qml/main.qml
    RESOURCES
        assets/icons/play.svg
        assets/icons/pause.svg
        assets/icons/skip-forward.svg
        assets/icons/skip-back.svg
        assets/icons/volume-2.svg
        assets/icons/volume-x.svg
        assets/icons/settings.svg
        assets/icons/list-video.svg
        assets/icons/sun.svg
        assets/icons/moon.svg
        assets/icons/folder-open.svg
        assets/icons/camera.svg
)

target_include_directories(amphi PRIVATE ${MPV_INCLUDE_DIRS})
target_link_directories(amphi PRIVATE ${MPV_LIBRARY_DIRS})
target_link_libraries(amphi PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    ${MPV_LIBRARIES}
)

if (APPLE)
    set_target_properties(amphi PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_GUI_IDENTIFIER com.example.amphi
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
    )
endif()
