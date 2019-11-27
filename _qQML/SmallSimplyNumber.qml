import QtQuick 2.0
import QtGraphicalEffects 1.0


Rectangle {
    id: main_rectangle
    property bool modeReverse: true
    property var itemName: '25'
    property bool buttonActive: true
    property bool isSelected: false

    width: 359
    height: 183
    color: 'transparent'
    visible: true

    Text{
        id: master_not_active_text
        visible: !buttonActive
        color: "white"
        text: 'NOT ACTIVE'
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.italic: true
        style: Text.Sunken
        font.bold: true
        font.pixelSize: 35
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family: "Ubuntu"
    }

    Rectangle{
        id: not_active_rec
        visible: !buttonActive || isSelected
        color: 'black'
        anchors.fill: parent
        opacity: .8
    }

    Rectangle {
        anchors.fill: parent
        color: (modeReverse) ? "white" : "black"
        opacity: .2
        visible: buttonActive && !isSelected
    }

    Text{
        id: master_text
        visible: buttonActive || isSelected
        height: 80
        color: "white"
        text: itemName
        font.italic: true
        anchors.horizontalCenterOffset: -50
        anchors.verticalCenter: parent.verticalCenter
        style: Text.Sunken
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pixelSize: 75
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.family: "Ubuntu"
    }

    Text{
        visible: buttonActive || isSelected
        color: "white"
        text: '.000'
        anchors.left: master_text.right
        anchors.leftMargin: 10
        anchors.bottom: master_text.bottom
        anchors.bottomMargin: 10
        font.italic: true
        style: Text.Sunken
        font.bold: true
        font.pixelSize: 35
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignLeft
        font.family: "Ubuntu"
    }

    function set_active(){
        isSelected = true;
    }

    function do_release(){
        isSelected = false;
    }



}

