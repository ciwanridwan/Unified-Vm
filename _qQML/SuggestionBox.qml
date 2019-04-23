import QtQuick 2.4
import QtQuick.Controls 1.3


Rectangle {
    id: container

    // --- properties
    property QtObject model: undefined
    property int count: filterItem.model.count
    property alias currentIndex: popup.selectedIndex
    property alias currentItem: popup.selectedItem
    property alias suggestionsModel: filterItem.model
    property alias filter: filterItem.filter
    property alias property: filterItem.property
    signal itemSelected(variant item)

    // --- behaviours
    z: parent.z + 100
    visible: filter.length > 0 && suggestionsModel.count > 0 && !filterMatchesLastSuggestion()
    height: visible ? childrenRect.height : 0
    Behavior on height {
        NumberAnimation{}
    }
    function filterMatchesLastSuggestion() {
        return suggestionsModel.count == 1 && suggestionsModel.get(0).name === filter
    }


    // --- defaults
    color: "#cbd2db"
    radius: 0
    border {
        width: 1
        color: "white"
    }


    FilterSuggest {
        id: filterItem
        sourceModel: container.model
    }


    // --- UI
    Column {
        id: popup
        clip: true
        height: childrenRect.height
        width: parent.width
        anchors.centerIn: parent

        property int selectedIndex: -1
        property variant selectedItem: selectedIndex === -1 ? undefined : model.get(selectedIndex)
        signal suggestionClicked(variant suggestion)

        opacity: container.visible ? 1.0 : 0
        Behavior on opacity {
            NumberAnimation { }
        }


        Repeater {
            id: repeater
            model: container.suggestionsModel
            delegate: Item {
                id: delegateItem
                property bool keyboardSelected: popup.selectedIndex === suggestion.index
                property bool selected: itemMouseArea.containsMouse
                property variant suggestion: model

                height: textComponent.height + 8
                width: container.width

                Rectangle {
//                    border.width: delegateItem.keyboardSelected ? 1 : 0
//                    border.color: "white"
                    radius: 0
                    height: textComponent.height + 8
                    color: delegateItem.selected ? "white" : "#cbd2db"
                    width: parent.width
                    Text {
                        id: textComponent
                        color: delegateItem.selected ? "darkred" : "white"
                        text: suggestion.name
                        width: parent.width
                        height: 28
                        font.family: 'Microsoft YaHei'
                        font.pixelSize: 18
                        font.italic: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: container.itemSelected(delegateItem.suggestion)
                }
            }
        }
    }

}

