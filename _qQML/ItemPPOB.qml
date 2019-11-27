import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property bool modeReverse: false
    property var color_: (modeReverse) ? "white" : "black"
    property var img_:"source/topup_kartu.png"
    property var text_:"Telkomsel 100000"
    property var text2_:"100000"
    property var text_color: (modeReverse) ? "black" : "white"
    property bool showText2: false
    width: 300
    height: 400
    color: 'transparent'
    visible: true

    Rectangle{
        id: background_base
        anchors.fill: parent
        color: color_
        opacity: .3
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
        width: parent.width
        color: text_color
        text: text_.toUpperCase()
        wrapMode: Text.WordWrap
        style: Text.Sunken
        font.pixelSize: (text_.length < 16) ? 30 : 25
        anchors.bottomMargin: 75
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.family:"Gotham"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
    Text{
        id: price_text
        color: text_color
        text: text2_.toUpperCase()
        font.pixelSize: 25
        anchors.bottomMargin: 10
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.family:"Gotham"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        visible: showText2
    }

}

