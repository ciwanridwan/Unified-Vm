import QtQuick 2.0

Rectangle{
    id: rectangle1
    property var labelName: 'Name'
    property int labelSize: 20
    property var labelContent: '---'
    property var contentSize: 20
    property int heightCell: 30
    property int paddingLeft: 75
    property int separatorPoint: 325
    property bool withBackground: false
    property var theme: 'darkred'
    property int globalWidth: 900

    color: 'transparent'
    width: globalWidth
    height: heightCell

    Text{
        id: label_text
        height: parent.height
        text: labelName
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
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: separatorPoint
        wrapMode: Text.WordWrap
        font.pixelSize: labelSize
        font.family: 'Ubuntu'
        color: theme
        font.bold: true

    }

    Rectangle{
        id: bground_content_text
        y: 0
        color: (content_text.text=='CONFIRMED') ? "green" : "darkred"
        width: 200
        height: parent.height
        radius: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: separator_text.right
        anchors.leftMargin: 51
        visible: withBackground
        Text{
            id: content_text
            width: parent.width
            height: parent.height
            text: labelContent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            wrapMode: Text.WordWrap
            font.pixelSize: contentSize
            font.family: 'Ubuntu'
            font.bold: (labelName=='Payment Status') ? true : false
            color: (labelContent=='CONFIRMED'||labelContent=='WAITING') ? 'white' : 'darkred'

        }
    }

    Text{
        id: content_text2
        width: parent.width
        height: parent.height
        text: labelContent
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

