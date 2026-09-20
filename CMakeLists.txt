cmake_minimum_required(VERSION 3.22)

project(OPIAN VERSION 0.2.1 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(OPIAN_BUILD_TESTS "Build OPIAN unit tests" ON)
option(OPIAN_COPY_PLUGIN_AFTER_BUILD "Copy AU/VST3 into the system plugin folders after build" ON)
if(DEFINED ENV{GITHUB_ACTIONS})
    set(OPIAN_COPY_PLUGIN_AFTER_BUILD OFF)
endif()

include(FetchContent)
FetchContent_Declare(
    juce
    GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
    GIT_TAG        8.0.8
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(juce)

if(APPLE)
    set(OPIAN_FORMATS AU VST3 Standalone)
else()
    set(OPIAN_FORMATS VST3 Standalone)
endif()

juce_add_plugin(OPIAN
    COMPANY_NAME "OPIAN"
    BUNDLE_ID com.opian.chordbuilder
    PLUGIN_MANUFACTURER_CODE Opia
    PLUGIN_CODE Opi1
    FORMATS ${OPIAN_FORMATS}
    PRODUCT_NAME "OPIAN"
    PLUGIN_NAME "OPIAN"
    IS_SYNTH TRUE
    NEEDS_MIDI_INPUT TRUE
    NEEDS_MIDI_OUTPUT TRUE
    IS_MIDI_EFFECT FALSE
    EDITOR_WANTS_KEYBOARD_FOCUS TRUE
    COPY_PLUGIN_AFTER_BUILD ${OPIAN_COPY_PLUGIN_AFTER_BUILD}
    VST3_CATEGORIES Instrument
    AU_MAIN_TYPE kAudioUnitType_MusicDevice
    MICROPHONE_PERMISSION_ENABLED FALSE
)

target_sources(OPIAN
    PRIVATE
        Source/Audio/PreviewSynth.cpp
        Source/Chord/ChordEngine.cpp
        Source/Chord/Voicing.cpp
        Source/Midi/ControlMap.cpp
        Source/Midi/ModuleRouter.cpp
        Source/PluginEditor.cpp
        Source/PluginProcessor.cpp
)

target_include_directories(OPIAN
    PRIVATE
        Source
)

target_compile_definitions(OPIAN
    PUBLIC
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0
        JUCE_DISPLAY_SPLASH_SCREEN=0
        JUCE_REPORT_APP_USAGE=0
)

target_link_libraries(OPIAN
    PRIVATE
        juce::juce_audio_utils
        juce::juce_audio_formats
        juce::juce_audio_plugin_client
        juce::juce_audio_devices
    PUBLIC
        juce::juce_recommended_config_flags
)

if(OPIAN_BUILD_TESTS)
    include(CTest)
    enable_testing()
    add_executable(opian_tests
        Tests/ChordEngineTests.cpp
        Source/Chord/ChordEngine.cpp
        Source/Chord/Voicing.cpp
    )
    target_include_directories(opian_tests PRIVATE Source)
    add_test(NAME ChordEngine COMMAND opian_tests)
endif()
