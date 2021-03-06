ifndef MATLAB_DIR
	MATLAB_DIR=/opt/matlab
endif

MEX=$(MATLAB_DIR)/bin/mex
CXX=g++


MEXFLAGS = -I$(MATLAB_DIR)/extern/include

MEXSUFFIX=$(shell $(MATLAB_DIR)/bin/mexext)

default_targets : testHokuyo testHokuyoReader hokuyoAPI.(MEXSUFFIX) hokuyoReaderAPI.(MEXSUFFIX)

testHokuyo : testHokuyo.cc Hokuyo.o SerialDevice.o
	$(CXX) -O2 -Wall testHokuyo.cc Hokuyo.o SerialDevice.o -o testHokuyo

testHokuyoReader : testHokuyoReader.cc Hokuyo.o HokuyoReader.o SerialDevice.o
	$(CXX) -O2 -Wall testHokuyoReader.cc Hokuyo.o HokuyoReader.o SerialDevice.o -lpthread -o testHokuyoReader

Hokuyo.o : Hokuyo.cc
	$(CXX) -O2 -Wall -c Hokuyo.cc -fPIC

SerialDevice.o : SerialDevice.cc
	$(CXX) -O2 -Wall -c -DSERIAL_DEVICE_DEBUG SerialDevice.cc -fPIC

HokuyoReader.o : HokuyoReader.cc
	$(CXX) -O2 -Wall -c HokuyoReader.cc -fPIC

hokuyoAPI.(MEXSUFFIX) : hokuyoAPI.cc Hokuyo.cc SerialDevice.cc
	$(MEX) -O hokuyoAPI.cc Hokuyo.cc SerialDevice.cc $(MEXFLAGS) -DSERIAL_DEVICE_DEBUG

hokuyoReaderAPI.(MEXSUFFIX) : hokuyoReaderAPI.cc Hokuyo.cc HokuyoReader.cc SerialDevice.cc
	$(MEX) -O hokuyoReaderAPI.cc Hokuyo.cc HokuyoReader.cc SerialDevice.cc $(MEXFLAGS) -DSERIAL_DEVICE_DEBUG

hokuyodrivernew: Hokuyo.o SerialDevice.o HokuyoDriverNew.cc
	$(CXX) -O2 -Wall `pkg-config --cflags playercore` -g -fPIC -shared -L. `pkg-config --libs playercore` -o $@.so Hokuyo.o SerialDevice.o HokuyoDriverNew.cc

clean :
	rm -rf *.o *.so testHokuyo testHokuyoReader *.$(MEXSUFFIX)


