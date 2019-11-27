import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import "base_function.js" as FUNC

Rectangle{
    property var price_
    property bool active_
    property var mode_
    property bool selected_: false
    color: (active_==true) ? FUNC.get_color(mode_) : "silver"
    radius: 15
    width: 130
    height: 60
//    visible: active_
    Rectangle{
        visible: selected_
        anchors.fill: parent
        radius: parent.radius
        color: "gray"
    }
    Text {
        id: text1
        font.family:"Ubuntu"
        color: (selected_!==true) ? "white" : "black"
        text: (active_==true) ? price_ : "-"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
        font.pixelSize: 25
    }

}

