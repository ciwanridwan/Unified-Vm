__author__ = "fitrah.wahyudi.imam@gmail.com"

from _dDevice import _HID
import sys
#from hid import AccessDeniedError, PathNotFoundError

# The scanner VID/PID change if neessary
VENDORID = 0x05e0
PRODUCTID = 0x1300

class Scanner(object):
    """ this library is platform-independent but depends on the backend HID.py"""
    def __init__(self, handle):
        """handle is an HIDDevice object """
        self.handle = handle
        #self.overlapped = overlapped

    def read(self):
        return self.handle.read(80)

    def getBarcode(self):
        readresult = self.read()
        #print readresult
        length = readresult[0]
        if (length == 0):
            return
        reportdata = readresult[1]
        reporttype = reportdata[0]
        #print "Number of bytes read: ", length
        #print "Buffer: "
        #for x in range(length):
        #    print(reportdata[x]),
        #print('\n')

        barcode = ""
        for x in range(5, length):
            if (reportdata[x] == 0):
                break
            barcode += chr(reportdata[x])
        return barcode
        #self.printStatus()

    def simply_read(self):
        while 1:
            barcode = sys.stdin.readline().rstrip().replace(' ', '')
            # f = urllib.urlopen("http://www.google.com/search?%s" % urllib.urlencode( {'q':line} ))
            return barcode 
        
         
def get_scanners():
    """Returns a collection of barcode scanner objects."""
    targets = _HID.OpenDevices(VENDORID, PRODUCTID)
    return [Scanner(scanner) for scanner in targets]
