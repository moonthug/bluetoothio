/**
 * Created by moonman
 */

// Libs
var should = require('should');

// BluetoothIO
var bluetoothio = require('../bluetoothio');


describe('Addon', function() {
    describe('#getPairedDevices()', function() {
        it('should return an instance of an array', function(){
            bluetoothio.getPairedDevices().should.be.instanceof(Array)
        });
    });
});