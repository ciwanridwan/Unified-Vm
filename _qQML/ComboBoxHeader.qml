import QtQuick 2.0

Item {
    id: comboBox
    property var globalParent;
    property var model;
    property int selectedIndex;
    signal comboItemSelected(int index);

    function openPopup() {
        var marginPoint = comboBox.mapToItem(globalParent, 0, comboBox.height);
        var options = {
            model: comboBox.model,
            selectedIndex: comboBox.selectedIndex,
            leftPadding: marginPoint.x,
            topPadding: marginPoint.y,
        };

         var component = Qt.createComponent("ComboBoxDropdown.qml");
         var instance = component.createObject(globalParent, options);
         instance.comboItemSelected.connect(comboBox.comboItemSelected);
    }


    Rectangle {
        id: header
        anchors.fill: parent
        color: "white"

        Text {
            text: comboBox.model[comboBox.selectedIndex]
            font.family: 'Microsoft YaHei'
            font.pixelSize: 20
            color: "gray"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: { openPopup() }
        }
    }
}


