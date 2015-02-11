//
//  addon.cc
//  BluetoothIO
//
//  Created by m00nthug on 09/02/2015.
//  Copyright (c) 2015 m00nthug. All rights reserved.
//


#include <node.h>
#include <v8.h>

#include <stdio.h>
#include <iostream>
#include <iterator>

#include "BluetoothIOManager.h"

using namespace v8;

//--------------------------------------------------------------
Handle<Value> InquireForDevices(const Arguments& args) {
    HandleScope scope;

    int length = 10;
    if (!args[0]->IsNumber()) {
        ThrowException(Exception::TypeError(String::New("Invalid inquiry length")));
        return scope.Close(Undefined());;
    }
    
//    Number inquiryLengthArg(args[0]->ToNumber());
//    length = std::string(*macAddressArg);
    
    BluetoothIOManager::inquireForDevices(length);
    
    return scope.Close(Undefined());
}

//--------------------------------------------------------------
Handle<Value> GetPairedDevices(const Arguments& args) {
    HandleScope scope;
    
    vector<BluetoothIODevice> pairedDevices = BluetoothIOManager::getPairedDevices();
    
    Local<Array> v8pairedDevices = Array::New(pairedDevices.size());

    for(vector<BluetoothIODevice>::iterator i = pairedDevices.begin(); i != pairedDevices.end(); ++i) {
        BluetoothIODevice device = (*i);
        Local<Object> obj = Object::New();
        obj->Set(String::NewSymbol("name"), String::New(device.name.c_str()));
        obj->Set(String::NewSymbol("address"), String::New(device.address.c_str()));
        v8pairedDevices->Set(std::distance(i, pairedDevices.begin()), obj);
    }
    
    return scope.Close(v8pairedDevices);
}


//--------------------------------------------------------------
Handle<Value> GetConnectedDevices(const Arguments& args) {
    HandleScope scope;
    
    vector<BluetoothIODevice> connectedDevices = BluetoothIOManager::getConnectedDevices();
    
    Local<Array> v8connectedDevices = Array::New(connectedDevices.size());
    
    for(vector<BluetoothIODevice>::iterator i = connectedDevices.begin(); i != connectedDevices.end(); ++i) {
        BluetoothIODevice device = (*i);
        Local<Object> obj = Object::New();
        obj->Set(String::NewSymbol("name"), String::New(device.name.c_str()));
        obj->Set(String::NewSymbol("address"), String::New(device.address.c_str()));
        obj->Set(String::NewSymbol("RSSI"), Number::New(device.getRSSI()));
        obj->Set(String::NewSymbol("rawRSSI"), Number::New(device.getRawRSSI()));

        v8connectedDevices->Set(std::distance(i, connectedDevices.begin()), obj);
    }
    
    return scope.Close(v8connectedDevices);
}

//--------------------------------------------------------------
Handle<Value> ConnectToDevice(const Arguments& args) {
    HandleScope scope;
    
    if (args.Length() < 1) {
        ThrowException(Exception::TypeError(String::New("No MAC Adddress set")));
        return scope.Close(Undefined());;
    }
    
    if (!args[0]->IsString()) {
        ThrowException(Exception::TypeError(String::New("Invalid MAC Address")));
        return scope.Close(Undefined());;
    }
    
    String::Utf8Value macAddressArg(args[0]->ToString());
    string macAddress = std::string(*macAddressArg);
    
    BluetoothIOManager::connectToDevice(macAddress);
    
    return scope.Close(Undefined());
}


//--------------------------------------------------------------
void Init(Handle<Object> exports) {
    exports->Set(String::NewSymbol("inquireForDevices"),
                 FunctionTemplate::New(InquireForDevices)->GetFunction());
    
    exports->Set(String::NewSymbol("getPairedDevices"),
                 FunctionTemplate::New(GetPairedDevices)->GetFunction());
    
    exports->Set(String::NewSymbol("getConnectedDevices"),
                 FunctionTemplate::New(GetConnectedDevices)->GetFunction());
    
    exports->Set(String::NewSymbol("connectToDevice"),
                 FunctionTemplate::New(ConnectToDevice)->GetFunction());
}


//--------------------------------------------------------------
NODE_MODULE(bluetoothio, Init)