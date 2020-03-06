import QtQuick 2.0

Rectangle{
    id: rectangle1
    property var labelName: 'Name'
    property int globalWidth: 400
    property int labelSize: 20
    property var labelContent: 'ABCDEFGHIJKLMN1234567890'
    property var contentSize: (globalWidth==400) ? 30 : 20
    property int heightCell: 35
    property int paddingLeft: 10
    property int separatorPoint: (globalWidth==400) ? 125 : 75
    property bool withBackground: false
    property var theme: 'white'
    property int leftMargin: (globalWidth==400) ? 20 : 10

    color: 'transparent'
    width: globalWidth
    height: heightCell * 2

    Text{
        id: label_text
        width: (globalWidth==400) ? 120 : 70
        height: parent.height
        text: labelName
        verticalAlignment: Text.AlignVCenter
        style: Text.Raised
        anchors.left: parent.left
        anchors.leftMargin: paddingLeft
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.WordWrap
        font.pixelSize: contentSize
        font.family: 'Microsoft YaHei'
        color: theme
    }

    Rectangle{
        id: bground_content_text
        y: 0
        color: 'white'
        anchors.right: parent.right
        anchors.rightMargin: 10
        border.width: 2
        border.color: theme
        width: globalWidth - separatorPoint - leftMargin - paddingLeft
        height: parent.height
        anchors.leftMargin: leftMargin
        Text{
            id: content_text
            anchors.fill: parent
            text: labelContent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAnywhere
            font.pixelSize: contentSize/2
            font.family: 'Microsoft YaHei'
            color: '#1D294D'

        }
    }

}

