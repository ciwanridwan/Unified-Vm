import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

ComboBox {
    id: comboRoot
    width: 200
    height: 50

    property alias comboBoxModel: comboRoot.model
    signal indexChanged()
    property alias currentIndex: comboRoot.currentIndex
    property alias currentText: comboRoot.currentText

    property Component comboBoxStyleBackground: Component { Rectangle{} }
    property Component dropDownMenuStyleFrame: Component { Rectangle{} }

    function setComboBoxStyleBackground(background) {
        comboBoxStyleBackground = background
    }

    function setDropDownMenuStyleFrame(frame) {
        dropDownMenuStyleFrame = frame
    }

    model: ListModel {
        id: cbItems
        ListElement { text: "" }
    }

    style: ComboBoxStyle {
        id: comboBoxStyle
        background: comboBoxStyleBackground
        label: Text {
            color: "black"
            width: comboRoot.width
            height: comboRoot.height
            text: control.currentText
        }

        __dropDownStyle: MenuStyle {
            id: dropDownMenuStyle
            frame: dropDownMenuStyleFrame
            itemDelegate.label: Text {
                width:comboRoot.width - 50
                height: comboRoot.height
                color: styleData.selected ? "blue" : "black"
                text: styleData.text
            }

            itemDelegate.background: Rectangle {
                z: 1
                opacity: 0.5
                color: styleData.selected ? "darkGray" : "transparent"
            }
        }
    }

    onCurrentIndexChanged: {
        comboRoot.indexChanged()
    }
}
