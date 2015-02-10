//
//  BluetoothIOManager.mm
//  BluetoothIO
//
//  Created by m00nthug on 09/02/2015.
//  Copyright (c) 2015 m00nthug. All rights reserved.
//

#import "BluetoothIOManager.h"


///////////////////////////////////////////////////////////////////////////////
//
//
// OSX
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetooth/objc/IOBluetoothDeviceInquiry.h>
#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothHostController.h>
#import <IOBluetooth/IOBluetoothUtilities.h>

@interface BlueController : NSObject {
}
- (void)connectToDevice:(NSString*)addrStr;
- (void)disconnectFromDevice:(NSString*)addrStr;
@end

@interface BlueController () <IOBluetoothDeviceInquiryDelegate>
@property IOBluetoothDeviceInquiry *inquiry;
@end

@implementation BlueController

//--------------------------------------------------------------
- (id) init {
    
//    _inquiry = [IOBluetoothDeviceInquiry inquiryWithDelegate:self];
//    [_inquiry start];
    [IOBluetoothDevice registerForConnectNotifications:self selector:@selector(deviceIsConnected:fromDevice:)];
    
    return self;
}

//--------------------------------------------------------------
//-(void)dealloc {
//    [super dealloc];
//    [self disconnectFromAllDevices];
//}



//--------------------------------------------------------------
- (void)connectToDevice:(NSString*)addrStr {
    
    BluetoothDeviceAddress addr;
    IOBluetoothNSStringToDeviceAddress(addrStr, &addr);
    
    IOBluetoothDevice * device = [[IOBluetoothDevice alloc] init];
    device = [IOBluetoothDevice deviceWithAddress:&addr];
    [device openConnection];
}

//--------------------------------------------------------------
- (void)disconnectFromDevice:(NSString*)addrStr {
    
    NSArray * devices = [IOBluetoothDevice pairedDevices];
    IOBluetoothDevice * device;
    NSEnumerator * e = [devices objectEnumerator];
    while (device = [e nextObject]) {
        if([device isConnected] && [addrStr isEqualToString:[device addressString]]) {
            [device closeConnection];
        }
    }
}


//
//
// IOBluetoothDeviceInquiryDelegate

//--------------------------------------------------------------
- (void)deviceInquiryStarted:(IOBluetoothDeviceInquiry *)sender {
    //NSLog(@"Searching....");
}

//--------------------------------------------------------------
- (void)deviceInquiryDeviceFound:(IOBluetoothDeviceInquiry *)sender
                          device:(IOBluetoothDevice *)device {
    
    //NSLog(@"Found: %@", [device nameOrAddress]);
    [device openConnection];
}

//--------------------------------------------------------------
- (void)deviceInquiryComplete:(IOBluetoothDeviceInquiry *)sender
                        error:(IOReturn)error
                      aborted:(BOOL)aborted {
    //NSLog(@"Complete");
}

//
//
// Notifications

//--------------------------------------------------------------
-(void)deviceDidDisconnected:(IOBluetoothUserNotification*)notification fromDevice:(IOBluetoothDevice*)device {
    //NSLog(@"Device Disconnected: %@ %@", notification, [device nameOrAddress]);
}

//--------------------------------------------------------------
-(void)deviceIsConnected:(IOBluetoothUserNotification*)notification fromDevice:(IOBluetoothDevice*)device {
    //NSLog(@"Device Connected %@ %@", notification, [device nameOrAddress]);
    //NSLog(@"RSSI: %i", [device RSSI]);
    [device registerForDisconnectNotification:self selector:@selector(deviceDidDisconnected:fromDevice:)];
}

@end


//
// Expose Controller Singleton

BlueController * controller = NULL;
BlueController * getControllerInstance() {
    if(controller == NULL) {
        controller = [[BlueController alloc] init];
    }
    return controller;
}



///////////////////////////////////////////////////////////////////////////////
//
//
// BluetoothIODevice
//

//--------------------------------------------------------------
BluetoothIODevice::BluetoothIODevice() {
    name        = "unknown";
    address     = "unknown";
    isConnected = false;
}

//--------------------------------------------------------------
BluetoothIODevice::BluetoothIODevice(string deviceName, string deviceAddress) {
    name        = deviceName;
    address     = deviceAddress;
    isConnected = false;
}

//--------------------------------------------------------------
int BluetoothIODevice::getRSSI() {
    NSArray * devices = [IOBluetoothDevice pairedDevices];
    IOBluetoothDevice * device;
    NSEnumerator * e = [devices objectEnumerator];
    
    while (device = [e nextObject]) {
        if([device isConnected]) {
            string deviceAddress = [[device addressString] UTF8String];
            if(deviceAddress == address) {
                return (int)[device RSSI];
            }
        }
    }
    return 0;
}

//--------------------------------------------------------------
int BluetoothIODevice::getRawRSSI() {
    NSArray * devices = [IOBluetoothDevice pairedDevices];
    IOBluetoothDevice * device;
    NSEnumerator * e = [devices objectEnumerator];
    
    while (device = [e nextObject]) {
        if([device isConnected]) {
            string deviceAddress = [[device addressString] UTF8String];
            if(deviceAddress == address) {
                return (int)[device rawRSSI];
            }
        }
    }
    return 0;
}


///////////////////////////////////////////////////////////////////////////////
//
//
// BluetoothIOManager
//

//--------------------------------------------------------------
vector<BluetoothIODevice> BluetoothIOManager::getPairedDevices() {
    vector<BluetoothIODevice>pairedDevices;
    
    NSArray * devices = [IOBluetoothDevice pairedDevices];
    if(devices) {
        IOBluetoothDevice * device;
        NSEnumerator * e = [devices objectEnumerator];
        while (device = [e nextObject]) {
            if(device) {
                string name = [device name] == nil
                    ? "unknown"
                    : [[device name] UTF8String];
                
                string address = [device addressString] == nil
                    ? "unknown"
                    : [[device addressString] UTF8String];
                
                BluetoothIODevice b = BluetoothIODevice(name, address);
                pairedDevices.push_back(b);
            }
        }
    }
    
    return pairedDevices;
}

//--------------------------------------------------------------
vector<BluetoothIODevice> BluetoothIOManager::getConnectedDevices() {
    vector<BluetoothIODevice>connectedDevices;
    NSArray * devices = [IOBluetoothDevice pairedDevices];
    IOBluetoothDevice * device;
    NSEnumerator * e = [devices objectEnumerator];
    while (device = [e nextObject]) {
        if(device) {
            if([device isConnected]) {
                string name = [device name] == nil
                    ? "unknown"
                    : [[device name] UTF8String];
                
                string address = [device addressString] == nil
                    ? "unknown"
                    : [[device addressString] UTF8String];
                
                BluetoothIODevice b = BluetoothIODevice(name, address);
                b.isConnected = [device isConnected];
                connectedDevices.push_back(b);
            }
        }
    }
    return connectedDevices;
}

//--------------------------------------------------------------
void BluetoothIOManager::connectToDevice(string deviceAddress) {
    NSString * address = [NSString stringWithUTF8String:deviceAddress.c_str()];
    //NSLog(@"Connect to device: %@", address);
    [getControllerInstance() connectToDevice: address];
}

//--------------------------------------------------------------
void BluetoothIOManager::disconnectFromDevice(string deviceAddress) {
    [getControllerInstance() disconnectFromDevice:[NSString stringWithUTF8String:deviceAddress.c_str()]];
}


