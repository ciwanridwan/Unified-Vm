import QtQuick 2.4
import QtQuick.Controls 1.3

FocusScope {
    id: focusScope

    property color borderColor: "black"
    property color borderColorFocused: "gray"
    property int borderWidth: 1
    property alias borderRadius: borderRect.radius
    property alias backgroundColor: borderRect.color
    property alias hint: hintComponent
    property bool hasClearButton: true
    property alias clearButton: clearButtonComponent
    property alias textInput: textInputComponent
    property var useMode: 'origin' //'destination'

    signal accepted
    signal enterPressed
    signal upPressed
    signal downPressed
    signal fromParentSignal(string str)


   Rectangle {
        id: borderRect
        anchors.fill: parent
        border {
            width: focusScope.borderWidth
//            color: (parent.activeFocus || textInputComponent.activeFocus) ? focusScope.borderColorFocused : focusScope.borderColor
            color: focusScope.borderColorFocused
        }
        radius: 4
        color: "white"
    }

    Text {
        id: hintComponent
        anchors.fill: parent; anchors.leftMargin: 4
        verticalAlignment: Text.AlignVCenter
//        text: "Type something..."
        color: "gray"
        font.italic: true
        font.pixelSize: 18
        font.family: 'Microsoft YaHei'
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
//            focusScope.focus = true;
            base_select_plan.fromSuggest(useMode + '||focus');
        }
    }

    TextInput {
        id: textInputComponent
        anchors { left: parent.left; leftMargin: 4; right: clearButtonComponent.left; rightMargin: 4; verticalCenter: parent.verticalCenter }
        focus: true
        selectByMouse: true
        color: "black"
        font.pixelSize: 18
        font.family: 'Microsoft YaHei'
        onAccepted: focusScope.accepted()
        Keys.onUpPressed: focusScope.upPressed()
        Keys.onDownPressed: focusScope.downPressed()
        Keys.onEnterPressed: focusScope.enterPressed()
    }

    ButtonSuggest {
        id: keyboardButtonComponent
        color: "transparent"
//        visible: true
//        anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
        anchors.fill: parent
//        enabled: !focusScope.focus
        onClicked: {
            textInput.text = '';
            focusScope.focus = true;
            base_select_plan.fromSuggest(useMode + '||activate');
        }

//        Image {
//            width: 20
//            height: 20
////            visible: !focusScope.focus
//            anchors.centerIn: parent
//            source: "source/keyboard-icon-black.jpg"
//            fillMode: Image.PreserveAspectFit
//        }
    }


    ButtonSuggest {
        id: clearButtonComponent
        opacity: 0
        color: "transparent"
//        visible: !keyboardButtonComponent.visible
        visible: false

        anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }

        onClicked: {
            textInput.text = '';
            focusScope.focus = true;
            base_select_plan.fromSuggest(useMode + '||clear');
            keyboardButtonComponent.visible = true;
        }

        Image {
            width: 20
            height: 20
            anchors.centerIn: parent
            source: "source/clear-text-rtl.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    states: State {
        name: "hasText"; when: textInput.text != ''
        PropertyChanges { target: hintComponent; opacity: 0 }
        PropertyChanges { target: clearButtonComponent; opacity: 1 }
//        PropertyChanges { target: keyboardButtonComponent; visible: false }
    }


    transitions: [
        Transition {
            from: ""; to: "hasText"
            NumberAnimation { exclude: hintComponent; properties: "opacity" }
        },
        Transition {
            from: "hasText"; to: ""
            NumberAnimation { properties: "opacity" }
        }
    ]
}
