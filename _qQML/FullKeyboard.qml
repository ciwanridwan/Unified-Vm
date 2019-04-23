import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id:full_keyboard
    width:925
    height:371
    color:"#cbd2db"
    property bool isShifted: false
    property bool isHighlighted: true
    property bool alphaOnly: false
    property bool numberOnly: false
    signal strButtonClick(string str)
    signal funcButtonClicked(string str)
//    Image{
//        id: sample_img
//        source: "aAsset/Keyboard.png"
    //        anchors.fill: parent
    //    }

    Row{
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5

        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "!" : "1"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true
        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "@" : "2"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "#" : "3"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "$" : "4"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "%" : "5"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "^" : "6"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "&" : "7"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "*" : "8"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "(" : "9"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? ")" : "0"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (alphaOnly==true) ? false : true

        }

        BackSpaceButton{
            width:75
            height:62
            //        chars: "Back"
        }
    }

    Row{
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "q" : "Q"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "w" : "W"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "e" : "E"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "r" : "R"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "t" : "T"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "y" : "Y"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "u" : "U"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "i" : "I"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "o" : "O"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "p" : "P"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "|" : "\\"
            isEnabled: (numberOnly==true || alphaOnly==true) ? false : true

        }
    }
    Row{
        y: 0
        anchors.top: parent.top
        anchors.topMargin: 150
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "a" : "A"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "s" : "S"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "d" : "D"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "f" : "F"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "g" : "G"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "h" : "H"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "j" : "J"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "k" : "K"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "l" : "L"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "_" : "-"
            isEnabled: (numberOnly==true || alphaOnly==true) ? false : true

        }
    }
    Row{
        y: 0
        anchors.top: parent.top
        anchors.topMargin: 220
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "z" : "Z"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "x" : "X"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "c" : "C"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "v" : "V"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "b" : "B"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "n" : "N"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "m" : "M"
            isEnabled: (numberOnly==true) ? false : true

        }
        LetterButton {
            width: 75
            height: 62
            chars: (isShifted==true) ? ">" : ","
            isEnabled: (numberOnly==true || alphaOnly==true) ? false : true

        }
        LetterButton {
            width: 75
            height: 62
            chars: (isShifted==true) ? "<" : "."
            isEnabled: (numberOnly==true || alphaOnly==true) ? false : true

        }
        LetterButton {
            width: 75
            height: 62
            chars: (isShifted==true) ? "#" : "@"
            isEnabled: (numberOnly==true || alphaOnly==true) ? false : true

        }
    }

    OKButton{
        x:688
        y:296
        width:217
        height:65
        chars: "OK"
    }
    ShiftButton{
        x:22
        y:293
        width:130
        height:65
        chars:"Shift"
        isEnabled: (numberOnly==true || alphaOnly==true) ? false : true

    }
    SpaceButton{
        x:165
        y:293
        width:509
        height:65
        chars: "Space"
//        isEnabled: (numberOnly==true || alphaOnly==true) ? false : true
        isEnabled: (numberOnly==true) ? false : true

    }
//    NumberActiveButton{
//        x:8
//        y:296
//        width:130
//        height:69
//        chars: "123"
//    }
}
