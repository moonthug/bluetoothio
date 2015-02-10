#include <node.h>
#include <v8.h>

#include <stdio.h>
#include <iostream>
#include <unistd.h>

#include "BlueListManager.h"

using namespace v8;

void GetPairedDevices(Handle<Object> exports) {
  	Isolate* isolate = Isolate::GetCurrent();
  	HandleScope scope(isolate);

	Local<Function> cb = Local<Function>::Cast(args[0]);

  	BlueList blueList;
	vector<BlueDevice> pairedDevices = BlueList::getPairedDevices();

	v8::Local<v8::Array> v8PairedDevices = v8::Array::New(pairedDevices.size());

	for(vector<BlueDevice>::const_iterator i = pairedDevices.begin(); i != pairedDevices.end(); ++i) {
	    BlueDevice device = (*i);
	    cout <<
	        device.name << "," <<
	        (device.isConnected == true ? 1 : 0) << "," <<
	        device.address << "," <<
	        device.getRawRSSI() << endl;
	    
	    if(device.isConnected == false) {
	        blueList.connectToDevice(device.address);
	    }
	}

}

void InitAll(Handle<Object> exports) {
  NODE_SET_METHOD(exports, "getPairedDevices", GetPairedDevices);
}

NODE_MODULE(addon, InitAll)