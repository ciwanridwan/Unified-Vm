import win32print

PRINTER_ERROR_STATES = (
    win32print.PRINTER_STATUS_NO_TONER,
    win32print.PRINTER_STATUS_NOT_AVAILABLE,
    win32print.PRINTER_STATUS_OFFLINE,
    win32print.PRINTER_STATUS_OUT_OF_MEMORY,
    win32print.PRINTER_STATUS_OUTPUT_BIN_FULL,
    win32print.PRINTER_STATUS_PAGE_PUNT,
    win32print.PRINTER_STATUS_PAPER_JAM,
    win32print.PRINTER_STATUS_PAPER_OUT,
    win32print.PRINTER_STATUS_PAPER_PROBLEM,
)

ERROR_PRINTER = {
    16: 'OUT_OF_PAPER'
}


def check_error(printer, error_states=PRINTER_ERROR_STATES):
    prn_opts = win32print.GetPrinter(printer)
    status = int(prn_opts[18])
    result = None
    if status != 0:
        result = error_states[status]
    return result


def main():
    printer_name = win32print.GetDefaultPrinter()
    prn = win32print.OpenPrinter(printer_name)
    error = check_error(prn)
    if error is not None:
        print("[ERROR] Printer: ", error)
    else:
        print("PRINTER OK")
        #  Do the real work

    win32print.ClosePrinter(prn)


if __name__ == "__main__":
    main()
