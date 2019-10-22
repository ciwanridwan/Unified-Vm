import QtQuick 2.4
import QtQuick.Controls 1.2

Base{
    id:notification
    visible: false
    use_ : 'notification'
    property bool isSuccess: true
    property var show_img: (isSuccess==true) ? "source/success.png" : "source/failed.png"
    property var show_text: qsTr("Congratulation")
    property var show_detail: qsTr("Your Order is Successfully processed")
    property var escapeFunction: 'closeWindow' //['closeWindow', 'backToMain', 'backToPrevious']
    property bool closeButton: true
    property bool withBackground: true

    Rectangle{
        id: base_overlay
        visible: withBackground
        anchors.fill: parent
        color: "#472f2f"
        opacity: 0.7
    }
    Rectangle{
        id: notif_rec
        width: 750
        height: 600
        color: "silver"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Image{
            id: image_close
            source: "source/close.png"
            width: 80
            height: 80
            anchors.top: parent.top
            anchors.topMargin: -30
            anchors.right: parent.right
            anchors.rightMargin: -30
            visible: closeButton
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    switch(escapeFunction){
                    case 'backToMain' : my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
                        break;
                    case 'backToPrevious' : my_layer.pop();
                        break;
                    default: close();
                        break;
                    }
                }
            }
        }
        Image  {
            id: image
            width: 300
            height: 300
            scale: 0.8
            anchors.verticalCenterOffset: -32
            anchors.horizontalCenterOffset: 0
            source: show_img
            fillMode: Image.PreserveAspectCrop
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            id: main_text
            color: "darkred"
            text: show_text
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenterOffset: 5
            font.family:"Ubuntu"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
        }
        Text {
            id: detail_text
            height: 100
            width: parent.width
            color: "darkred"
            text: show_detail
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            font.bold: true
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            font.family:"Ubuntu"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 25
        }

    }

    function open(){
        notification.visible = true
    }

    function close(){
        notification.visible = false
    }
}
