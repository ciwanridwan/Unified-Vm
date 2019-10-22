import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id:full_keyboard
    width:925
    height:371
    color:"#cbd2db"
    property bool isShifted: true
    property bool isHighlighted: true
    property var useMode: 'alphaOnly' // 'alphanumeric'
    signal strButtonClick(string str)
    signal funcButtonClicked(string str)
//    Image{
//        id: sample_img
//        source: "source/Keyboard.png"
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
//            chars: (isShifted==true) ? "!" : "1"
            chars: "1"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "@" : "2"
            chars: "2"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "#" : "3"
            chars: "3"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "$" : "4"
            chars: "4"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "%" : "5"
            chars: "5"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "^" : "6"
            chars: "6"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "&" : "7"
            chars: "7"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "*" : "8"
            chars: "8"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "(" : "9"
            chars: "9"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? ")" : "0"
            chars: "0"
            isNumber: true
            isHighlighted: full_keyboard.isHighlighted
            isEnabled: (useMode=='alphaOnly') ? false : true
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
//            chars: (isShifted==true) ? "q" : "Q"
            chars: "Q"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "w" : "W"
            chars: "W"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "e" : "E"
            chars: "E"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "r" : "R"
            chars: "R"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "t" : "T"
            chars: "T"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "y" : "Y"
            chars: "Y"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "u" : "U"
            chars: "U"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "i" : "I"
            chars: "I"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "o" : "O"
            chars: "O"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "p" : "P"
            chars: "P"
        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "|" : "\\"
            isEnabled: (useMode=='alphaOnly') ? false : true
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
//            chars: (isShifted==true) ? "a" : "A"
            chars: "A"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "s" : "S"
            chars: "S"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "d" : "D"
            chars: "D"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "f" : "F"
            chars: "F"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "g" : "G"
            chars: "G"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "h" : "H"
            chars: "H"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "j" : "J"
            chars: "J"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "k" : "K"
            chars: "K"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "l" : "L"
            chars: "L"
        }
        LetterButton{
            width:75
            height:62
            chars: (isShifted==true) ? "_" : "-"
            isEnabled: (useMode=='alphaOnly') ? false : true
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
//            chars: (isShifted==true) ? "z" : "Z"
            chars: "Z"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "x" : "X"
            chars: "X"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "c" : "C"
            chars: "C"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "v" : "V"
            chars: "V"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "b" : "B"
            chars: "B"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "n" : "N"
            chars: "N"
        }
        LetterButton{
            width:75
            height:62
//            chars: (isShifted==true) ? "m" : "M"
            chars: "M"
        }
        LetterButton {
            width: 75
            height: 62
            chars: (isShifted==true) ? ">" : ","
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton {
            width: 75
            height: 62
            chars: (isShifted==true) ? "<" : "."
            isEnabled: (useMode=='alphaOnly') ? false : true
        }
        LetterButton {
            width: 75
            height: 62
            chars: (isShifted==true) ? "#" : "@"
            isEnabled: (useMode=='alphaOnly') ? false : true
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
        isEnabled: (useMode=='alphaOnly') ? false : true
    }
    SpaceButton{
        x:165
        y:293
        width:509
        height:65
        chars: "Space"
    }
//    NumberActiveButton{
//        x:8
//        y:296
//        width:130
//        height:69
//        chars: "123"
//    }
}
