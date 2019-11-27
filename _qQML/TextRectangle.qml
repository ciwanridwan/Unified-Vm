import QtQuick 2.0

Rectangle{
    id: rectangle1
    property var usedBy: undefined
    property var borderColor: "#8b0000"
    property var placeHolder: ""
    property var baseColor: 'transparent'

    width: 500
    height: 50
    color: baseColor
//    radius: 20
    border.color: borderColor
    border.width: 3
    Text{
        visible: (usedBy!=undefined) ? true : false
        text: placeHolder
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignLeft
        font.family: "Gotham"
        font.pixelSize: 30
        font.italic: true
        color: "silver"
        opacity: .6
    }
}
