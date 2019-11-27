import QtQuick 2.0

Rectangle{
    id: groupFirstName
    width: 430
    height: 50
    color: "transparent"
    border.width: 2
    border.color: "gray"
    property string show_label: "FirstName"
    property string show_text: ""
    property bool set_focus: false
    Text{
        text: show_label
        anchors.top: parent.top
        anchors.topMargin: -35
        font.family: "GothamRounded"
        font.pixelSize: 20
        color: "darkred"
    }
    TextInput {
        x: 10
        y: 10
        width: 418
        height: 40
        text: show_text
        anchors.verticalCenterOffset: 3
        anchors.horizontalCenterOffset: -2
        anchors.centerIn: parent
        focus: set_focus
        cursorVisible: focus
        horizontalAlignment: Text.AlignLeft
        font.family: "GothamRounded"
        font.pixelSize: 20
        color: "darkred"
//        clip: true
        visible: true
    }
}
