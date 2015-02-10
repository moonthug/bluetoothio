# BluetoothIO

A simple NodeJS wrapper for OSX IOBluetooth Framework.

See more at the [Apple Docs](https://developer.apple.com/library/mac/documentation/DeviceDrivers/Reference/IOBluetooth/_index.html).

### Version
0.0.1

### Installation

```sh
$ npm install https://github.com/moonthug/bluetoothio/tarball/master
```

### Examples
```javascript
var bluetoothio = require('bluetoothio');

# Get a list of paired devices
# i.e. [ { name: 'dethfone_s5', address: '68-48-98-3d-6c-8a' } ]
console.dir(bluetoothio.getPairedDevices());

# Connect to a device
bluetoothio.connectToDevice('68-48-98-3d-6c-8a');

# Get a list of connected devices
# i.e. [ { name: 'dethfone_s5', address: '68-48-98-3d-6c-8a', RSSI: 0, rawRSSI: -59 } ]
console.dir(bluetoothio.getPairedDevices());

#
```

### Development

Feel free to get involved. It's very much a work in progress.

### Todo's

 - Write Tests
 - Finish up DeviceInquiry
 - Add iBeacon Support

### License

MIT