//
//  BluetoothIOManager.h
//  BluetoothIO
//
//  Created by m00nthug on 09/02/2015.
//  Copyright (c) 2015 m00nthug. All rights reserved.
//


#pragma once

#include <string>
#include <vector>

using namespace std;

///////////////////////////////////////////////////////////////////////////////
//
//
// BluetoothIODevice
//

class BluetoothIODevice {
public:
    BluetoothIODevice();
    BluetoothIODevice(string deviceName, string deviceAddress);
    
    string name;
    string address;
    
    bool isConnected;
    
    int getRSSI();
    int getRawRSSI();
};


///////////////////////////////////////////////////////////////////////////////
//
//
// BluetoothioManager
//

class BluetoothIOManager {
    
public:
    static vector<BluetoothIODevice> getPairedDevices();
    static vector<BluetoothIODevice> getConnectedDevices();
    
    static void inquireForDevices();
    static void inquireForDevices(int inquiryLength);

    static void connectToDevice(string deviceAddress);
    static void disconnectFromDevice(string deviceAddress);
    
};