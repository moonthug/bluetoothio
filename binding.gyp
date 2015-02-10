{
    "targets": [{
        "target_name": 'bluetoothio',
        "sources": [
            "./src/addon.cc",
            "./src/BluetoothIOManager.mm",
            './bluetoothio.js',
        ],
        "cflags!": [
            "-fno-exceptions"
        ],
        "cflags_cc!": [
            "-fno-exceptions"
        ],
        "conditions": [[
            "OS=='mac'",
            {
                "defines": [
                "__MACOSX_CORE__"
                ],
                "architecture": "i386",
                "xcode_settings": {
                    "GCC_ENABLE_CPP_EXCEPTIONS": "YES"
                },
                "link_settings": {
                    "libraries": [
                        "-undefined dynamic_lookup",
                        "-framework",
                        "IOBluetooth"
                    ],
                    "configurations": {
                        "Debug": {
                            "xcode_settings": {
                            }
                        },
                        "Release": {
                            "xcode_settings": {
                            }
                        }
                    }
                }
            }
        ]]
    }]
}
