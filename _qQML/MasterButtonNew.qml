import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property bool modeReverse: false
    property var color_: (modeReverse) ? "white" : "#1D294D"
    property var img_:""
    property var text_:"Tiket Pesawat"
    property var text2_:"Flight Ticket"
    property var text_color: (modeReverse) ? "#1D294D" : "white"
    width: 350
    height: 350
    color: 'transparent'
    Rectangle{
        id: background_base
        anchors.fill: parent
        color: 'white'
        opacity: .2
    }
    Image{
        id: button_image
        anchors.topMargin: -100
        anchors.fill: parent
        scale: 0.4
        source: img_
        fillMode: Image.PreserveAspectFit
        visible: modeReverse
    }
    ColorOverlay {
        visible: !modeReverse
        anchors.fill: button_image
        source: button_image
        scale: 0.4
        color: "#ffffff"
    }
    Text{
        id: text_button
        color: 'white'
        text: text_.toUpperCase()
        font.pixelSize: 30
        anchors.bottomMargin: 30
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.family:"Ubuntu"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

}

