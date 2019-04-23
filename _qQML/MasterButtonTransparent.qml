import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property bool modeReverse: false
    property var color_: (modeReverse) ? "white" : "#9E4305"
    property var img_:""
    property var text_:"TIket Pesawat"
    property var text2_:"Flight Ticket"
    property var text_color: (modeReverse) ? "#9E4305" : "white"
    width: 320
    height: 400
    color: 'transparent'
    Rectangle{
        id: background_base
        anchors.fill: parent
        color: color_
        radius: 20
        opacity: .97
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
        scale: 0.6
        color: "#ffffff"
    }
    Text{
        id: text_button
        color: text_color
        text: text_
        font.pixelSize: 20
        font.bold: true
        anchors.bottomMargin: 50
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.family: "Microsoft YaHei"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
    Text{
        id: text2_button
        color: text_color
        text: text2_
        font.pixelSize: 15
        font.italic: true
        anchors.bottomMargin: 30
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.family: "Microsoft YaHei"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}

