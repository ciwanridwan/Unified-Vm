import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    width:120
    height:120
    color:"transparent"
    property bool modeReverse: false
    property string button_text: 'ISI SALDO\nOFFLINE'
    property real globalOpacity: .50
    property int fontSize: 30

    Rectangle{
        anchors.fill: parent
        color: (button_text=='BATAL') ? 'red' : 'white'
        opacity: (button_text=='BATAL') ? 1 : globalOpacity
        radius: width/2
    }

    Text {
        anchors.fill: parent
        color: (modeReverse) ? 'white' : 'black'
        text: button_text.toUpperCase()
        style: Text.Sunken
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family:"Ubuntu"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: (button_text.length > 5 ) ? 23 : fontSize
        font.bold: true
    }

}


