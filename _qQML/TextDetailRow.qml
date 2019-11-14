import QtQuick 2.0

Rectangle{
    id: rectangle1
    property var labelName: 'undefined'
    property int labelSize: 35
    property var labelContent: 'undefined'
    property var contentSize: 35
    property int heightCell: 50
    property int paddingLeft: 0
    property int separatorPoint: 300
    property bool withBackground: false
    property var theme: 'white'
    property int globalWidth: 1200

    color: 'transparent'
    width: globalWidth
    height: heightCell
    visible: (labelName!='undefined')

    Text{
        id: label_text
        height: parent.height
        text: labelName
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.leftMargin: paddingLeft
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.WordWrap
        font.pixelSize: labelSize
        font.family: 'Ubuntu'
        color: theme
        font.bold: true

    }

    Text{
        id: separator_text
        height: parent.height
        text: ':'
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: separatorPoint
        wrapMode: Text.WordWrap
        font.pixelSize: labelSize * 1.2
        font.family: 'Ubuntu'
        color: theme
        font.bold: true

    }

    Text{
        id: content_text2
        width: parent.width - (paddingLeft+label_text.width)
        height: parent.height
        text: labelContent
        verticalAlignment: Text.AlignVCenter
        visible: !withBackground
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: separator_text.right
        anchors.leftMargin: 50
        wrapMode: Text.WordWrap
        font.pixelSize: contentSize
        font.family: 'Ubuntu'
        font.bold: false
        color: theme

    }





}

