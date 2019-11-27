import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:120
    height:70
    color:"transparent"
    property bool modeReverse: false
    property string button_text: 'batal'
    property real globalOpacity: .97

    Rectangle{
        anchors.fill: parent
        color: (modeReverse) ? 'white' : '#1D294D'
        opacity: globalOpacity
        radius: 30
    }

    Text {
        height: 80
        color: (modeReverse) ? '#1D294D' : 'white'
        anchors.fill: parent
        text: button_text
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 25
    }

}

