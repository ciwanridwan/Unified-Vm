import QtQuick 2.4
import QtQuick.Controls 1.3
import "airport.js" as AIRPORTS

Base {
    id: base_page
    mode_ : "reverse"
    property var __data: []
    ListModel { id: __model }

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            fill_data(AIRPORTS.get_list());
        }
        if(Stack.status==Stack.Deactivating){
            __data = [];
        }
    }

    Item {
        id: contents_origin
        x: 321
        y: 224
        width: 430
//        height: parent.height

        LineEditSuggest {
            id: inputFieldOrigin
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            hint.text: "Enter Origin City..."
            borderColor: "white"

            function activateSuggestionAt(offset) {
                var max = suggestionsBoxOrigin.count
                if(max == 0)
                    return
                var newIndex = ((suggestionsBoxOrigin.currentIndex + 1 + offset) % (max + 1)) - 1
                suggestionsBoxOrigin.currentIndex = newIndex
            }
            onUpPressed: activateSuggestionAt(-1)
            onDownPressed: activateSuggestionAt(+1)
            onEnterPressed: processEnter()
            onAccepted: processEnter()
//            onTextInputChanged: console.log(textInput.text)

            Component.onCompleted: {
                inputFieldOrigin.forceActiveFocus()
            }

            function processEnter() {
                if (suggestionsBoxOrigin.currentIndex === -1) {
                    console.log("Enter pressed in input field")
                } else {
                    suggestionsBoxOrigin.complete(suggestionsBoxOrigin.currentItem)
                }
            }
        }

        SuggestionBox {
            id: suggestionsBoxOrigin
            model: __data
            width: parent.width - 50
            anchors.top: inputFieldOrigin.bottom
            anchors.left: inputFieldOrigin.left
            filter: inputFieldOrigin.textInput.text
            property: "name"
            onItemSelected: complete(item)

            function complete(item) {
                suggestionsBoxOrigin.currentIndex = -1
                if (item !== undefined)
                    inputFieldOrigin.textInput.text = item.name
            }
        }

    }

    Item {
        id: contents_destination
        x: 821
        y: 224
        width: 430
//        height: parent.height - 500

        LineEditSuggest {
            id: inputFieldDestination
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            hint.text: "Enter Origin Airport City.."
            borderColor: "white"

            function activateSuggestionAt(offset) {
                var max = suggestionsBoxDestination.count
                if(max == 0)
                    return
                var newIndex = ((suggestionsBoxDestination.currentIndex + 1 + offset) % (max + 1)) - 1
                suggestionsBoxDestination.currentIndex = newIndex
            }
            onUpPressed: activateSuggestionAt(-1)
            onDownPressed: activateSuggestionAt(+1)
            onEnterPressed: processEnter()
            onAccepted: processEnter()
//            onTextInputChanged: console.log(textInput.text)

            Component.onCompleted: {
                inputFieldDestination.forceActiveFocus()
            }

            function processEnter() {
                if (suggestionsBoxDestination.currentIndex === -1) {
                    console.log("Enter pressed in input field")
                } else {
                    suggestionsBoxDestination.complete(suggestionsBoxDestination.currentItem)
                }
            }
        }

        SuggestionBox {
            id: suggestionsBoxDestination
            model: __data
            width: parent.width - 50
            anchors.top: inputFieldDestination.bottom
            anchors.left: inputFieldDestination.left
            filter: inputFieldDestination.textInput.text
            property: "name"
            onItemSelected: complete(item)

            function complete(item) {
                suggestionsBoxDestination.currentIndex = -1
                if (item !== undefined)
                    inputFieldDestination.textInput.text = item.name
            }
        }

    }

    function fill_data(list){
//        console.log(list);
        var data_temp = [];
        for (var i = 1; i < list.length; i++){
            data_temp.push({'name' : list[i]});
        }
        for (var x = 0; x < data_temp.length; x++){
            __model.append(data_temp[x]);
        }
        __data = __model
    }

    Component.onCompleted: {

    }

    Component.onDestruction: {

    }

}
