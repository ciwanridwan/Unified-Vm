import QtQuick 2.0
import QtGraphicalEffects 1.0


Rectangle {
    id: main_rectangle
    property bool modeReverse: true
    property var itemName: '100'
    property bool buttonActive: true
    property bool isSelected: false
    property variant imageMode: ['10', '20', '50', '100']

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

    Image {
        anchors.fill: parent
        visible: (imageMode.indexOf(itemName) > -1)
        source: "source/money/"+itemName+"000.png"
        fillMode: Image.Stretch
    }


    Text{
        id: master_text
        visible: buttonActive || isSelected
        height: 80
        color: (imageMode.indexOf(itemName) > -1) ? "transparent" : "white"
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
        color: (imageMode.indexOf(itemName) > -1) ? "transparent" : "white"
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

