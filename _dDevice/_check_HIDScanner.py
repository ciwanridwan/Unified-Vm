__author__ = "fitrah.wahyudi.imam@gmail.com"

# import evdev
# import os
# import sys
#
#
# if __name__ == '__main__':
#     devices = [evdev.InputDevice(fn) for fn in evdev.list_devices()]
#     for device in devices:
#         print(device.fn, device.name, device.phys)
#
#     device = evdev.InputDevice("/dev/hidraw4")
#     print(device)
#     for event in device.read_loop():
#         print(event)


import os
import sys
import usb.core
import usb.util

from time import sleep
import random


# handler called when a report is received
def rx_handler(data):
    print('Receive : ', data)


def find_hid(vid, pid):
    hid_device = usb.core.find(idVendor=vid, idProduct=pid)
    if not hid_device:
        print("No HID Connected")
        sys.exit("Could not find HID Device")
    else:
        sys.stdout.write('Device Found\n')
        if hid_device.is_kernel_driver_active(0):
            try:
                hid_device.detach_kernel_driver(0)
            except usb.core.USBError as e:
                sys.exit("Could not detach kernel driver: %s" % str(e))
        try:
            # hid_device.set_configuration()
            hid_device.reset()
        except usb.core.USBError as e:
            sys.exit("Could not set configuration: %s" % str(e))
        endpoint = hid_device[0][(0, 0)][0]
        while True:
            data = [0x0] * 16
            # read the data
            _bytes = hid_device.read(endpoint.bEndpointAddress, 8)
            rx_handler(_bytes)
            for i in range(8):
                data[i] = _bytes[i]
                data[i + 8] = random.randint(0, 255)
            hid_device.write(1, data)


if __name__ == '__main__':
    vendor_id = 0x0c2e
    product_id = 0x0ec1
    find_hid(vendor_id, product_id)
#
# import usb
#
# busses = usb.busses()
# for bus in busses:
#     devices = bus.devices
#     for dev in devices:
#         if "0x{:04x}".format(dev.idVendor) == "0x0c2e" and "0x{:04x}".format(dev.idProduct) == "0x0ec1":
#             print("Device:", dev.filename)
#             print("  VID: 0x{:04x}".format(dev.idVendor))
#             print("  PID: 0x{:04x}".format(dev.idProduct))
#             handle = dev.open()
#             dev._langids = (1033,)
#             if dev.iManufacturer == 0:
#                 print('No Data')
#             else:
#                 print(" --> '{}'".format(handle.getString(dev.iManufacturer, 255)))


#
# Device:
#   VID: 0x0c2e
#   PID: 0x0ec1
