import QtQuick 2.4
import QtQuick.Controls 1.2
import "config.js" as CONF


Rectangle{
    width:200
    height:200
    color:"transparent"
    property bool modeReverse: false
    property string button_text: 'ISI SALDO\nONLINE'
    property real globalOpacity: .95
    property int fontSize: 35

    Rectangle{
        anchors.fill: parent
        color: CONF.frame_color
        opacity: globalOpacity
        radius: width/2
    }

    Text {
        anchors.fill: parent
        color: CONF.text_color
        text: button_text.toUpperCase()
        style: Text.Sunken
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"GothamRounded"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: fontSize
        font.bold: true
    }

}


