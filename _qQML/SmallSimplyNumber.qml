import QtQuick 2.0
import QtGraphicalEffects 1.0


Rectangle {
    id: main_rectangle
    property bool modeReverse: true
    property var itemName: '1.000'
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
        font.family: "GothamRounded"
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
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignHCenter
        font.family: "GothamRounded"
    }

    Text{
        visible: buttonActive || isSelected
        color: "white"
        text: '.000'
        font.italic: true
        anchors.verticalCenterOffset: 15
        anchors.horizontalCenterOffset: 100
        anchors.verticalCenter: parent.verticalCenter
        style: Text.Sunken
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pixelSize: 28
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignHCenter
        font.family: "GothamRounded"
    }

    function set_active(){
        isSelected = true;
    }

    function do_release(){
        isSelected = false;
    }



}

