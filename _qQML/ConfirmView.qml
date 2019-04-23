import QtQuick 2.4
import QtQuick.Controls 1.2

Base{
    id:confirmation
    visible: false
    use_: 'confirmation'
    property string show_text: qsTr("Confirmation")
    property string show_detail: qsTr("Do you want to proceed this flight arrangement?\n(You cannot go back after this.)")
    property var escapeFunction: 'closeWindow' //['closeWindow', 'backToMain', 'backToPrevious']
    property bool cancelAble: true
    Rectangle{
        id: base_overlay
        anchors.fill: parent
        color: "gray"
        opacity: 0.6
    }
    Rectangle{
        id: notif_rec
        width: 750
        height: 600
        color: "silver"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Image  {
            id: image
            anchors.fill: parent
            opacity: 0.2
            source: 'aAsset/Which_Way.jpg'
            fillMode: Image.Stretch
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
            font.family:"Microsoft YaHei"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
        }
        Text {
            id: detail_text
            height: 212
            color: "darkred"
            text: show_detail
            anchors.topMargin: 155
            anchors.verticalCenterOffset: -39
            anchors.verticalCenter: parent.verticalCenter
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: true
            font.family:"Microsoft YaHei"
            font.pixelSize: 25
        }
        GroupBox{
            id: groupBox1
            flat: true
            x: 200
            y: 472
            width: parent.width
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            ConfirmButton{
                id: cancel_button
                visible: cancelAble
                y: 0
                width: 190
                anchors.left: parent.left
                anchors.leftMargin: 150
                text_: qsTr("Cancel")
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
            ConfirmButton{
                id: ok_button
                y: 0
                width: 190
                anchors.right: parent.right
                anchors.rightMargin: 150
                text_: qsTr("OK")
            }
        }
    }

    function open(){
        confirmation.visible = true
    }

    function close(){
        confirmation.visible = false
    }
}
