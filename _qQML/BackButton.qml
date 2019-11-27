import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:180
    height:90
    color:"transparent"
    property bool modeReverse: false
    property string button_text: 'batal'
    property real globalOpacity: .97
    property int fontSize: 30
    property bool modeRadius: true

    Rectangle{
        anchors.fill: parent
        color: (modeReverse) ? 'white' : '#1D294D'
        opacity: globalOpacity
        radius: (modeRadius) ? fontSize : 0
    }

    Text {
        color: (modeReverse) ? '#1D294D' : 'white'
        anchors.fill: parent
        text: button_text.toUpperCase()
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Gotham"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: fontSize
    }

}

