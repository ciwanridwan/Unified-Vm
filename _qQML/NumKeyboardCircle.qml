import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0


Rectangle{
    id:full_numpad
    width:320
    height:420
    color:"transparent"
    signal strButtonClick(string str)
    signal funcButtonClicked(string str)
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }


    NumButtonCircle{
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        show_text:"1"
    }
    NumButtonCircle{
        x:90
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        show_text:"2"
    }
    NumButtonCircle{
        x:180
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        show_text:"3"
    }
    NumButtonCircle{
        y:106
        anchors.left: parent.left
        anchors.leftMargin: 0
        show_text:"4"
    }
    NumButtonCircle{
        x:90
        y:106
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        show_text:"5"
    }
    NumButtonCircle{
        x:220
        y:106
        anchors.right: parent.right
        anchors.rightMargin: 0
        show_text:"6"
    }
    NumButtonCircle{
        y:212
        height: 100
        anchors.left: parent.left
        anchors.leftMargin: 0
        show_text:"7"
    }
    NumButtonCircle{
        x:90
        y:212
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        show_text:"8"
    }
    NumButtonCircle{
        x:220
        y:212
        anchors.right: parent.right
        anchors.rightMargin: 0
        show_text:"9"
    }
    NumButtonCircle{
        x:90
        y:270
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        show_text:"0"
    }
    NumboardClearCircle{
        y:270
        color: "#5a5a5a"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        border.width: 0
        slot_text:"Clear"
    }
    NumboardBackCircle{
        x:180
        y:270
        color: "#ffc125"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        border.width: 0
        slot_text: "Back"
    }
}
