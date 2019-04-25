import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:159
    height:62
    color: (full_keyboard.isShifted==true) ? "gray" : "#ffc125"
    radius: 10
    property var chars: "Shift"
    property bool isEnabled

    Text{
        id: text_button
        text: chars
        color: (full_keyboard.isShifted==true) ? "white" : "red"
        font.family:"Ubuntu"
        font.pixelSize:30
        anchors.centerIn: parent;
//        font.bold: true
    }

    MouseArea {
        enabled: isEnabled
        anchors.fill: parent
        onClicked: {
            full_keyboard.isShifted = !full_keyboard.isShifted
        }
    }
}
