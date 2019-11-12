import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property var sourceImage:"source/ppob_category/pulsa.png"
    property bool modeReverse: true
    width: 359
    height: 183
    color: 'transparent'
    visible: true

    Rectangle {
        anchors.fill: parent
        color: (modeReverse) ? "white" : "black"
        opacity: .4
    }

    Image{
        anchors.fill: parent
        scale: 1
        source: sourceImage
        fillMode: Image.PreserveAspectFit
    }

}

