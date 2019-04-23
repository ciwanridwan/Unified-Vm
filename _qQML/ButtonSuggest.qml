import QtQuick 2.4
import QtQuick.Controls 1.3

Rectangle {
    id: buttonRoot
    property bool hovered: false

    width: 50
    height: 50

    signal clicked

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        onEntered: buttonRoot.hovered = true
        onExited: buttonRoot.hovered = false
        onClicked: {
            buttonRoot.clicked()
        }
    }
}
