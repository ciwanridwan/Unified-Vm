import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:180
    height:90
    color:"transparent"
    property string button_text: 'lanjut'
    property bool modeReverse: false
    property int fontSize: 30
    property bool modeRadius: true

    Rectangle{
        anchors.fill: parent
        color:(modeReverse) ? 'white' : '#9E4305'
        opacity: .97
        radius: (modeRadius) ? fontSize : 0
    }

    Text {
        color: (modeReverse) ? '#9E4305' : 'white'
        anchors.fill: parent
        text: button_text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Microsoft YaHei"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: fontSize
    }



}

