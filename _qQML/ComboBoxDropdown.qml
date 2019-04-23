import QtQuick 2.0

Item {
    id: dropdownComponent
    anchors.fill: parent

    property alias model: dropDownItems.model
    property alias selectedIndex: dropDownItems.currentIndex

    property double topPadding: 10
    property double leftPadding: 3

    signal comboItemSelected(int index)
    function closePopup() { dropdownComponent.destroy() }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel.accepted = true
        onClicked: {
            mouse.accepted = true
            closePopup()
        }
    }

    Rectangle {
        id: dropDown
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: dropdownComponent.leftPadding
        anchors.topMargin: dropdownComponent.topPadding
        color: "silver"
        visible: false
        width: 200
        height: 0
        state: "down"

        ListView {
            id: dropDownItems
            anchors.fill: parent

            delegate: Rectangle {
                width: parent.width
                height: 20

                Text { text: modelData }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        comboBox.state = ""
                        if (index !== comboBox.selectedIndex) {
                            comboBox.selectedIndex = index
                            comboItemSelected(index)
                        }
                    }
                }
            }
        }

        states: State {
            name: "down";
            PropertyChanges {
                target: dropDown;
                height: 20 * dropDownItems.count
                visible: true
            }
        }
    }
}

