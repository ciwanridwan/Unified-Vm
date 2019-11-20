import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC
import "config.js" as CONF


Rectangle{
    id: rectangle
    width:400
    height:380
    color:"transparent"
    property var itemName: 'Product Name'
    property var itemImage: 'source/card/card_tj_original.png'
    property var itemPrice: '19000'
    property var itemStock: 10
    property var itemDesc: 'Product Description Product Description Product Description Product Description Product Description Product Description'
    property bool isSelected: false
    visible: false
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation  { duration: 500 ; easing.type: Easing.InOutQuad  }
    }

    function set_select(){
        isSelected = true;
        empty_text.text = 'TERPILIH'
    }

    function release_select(){
        isSelected = false;
        empty_text.text = 'TIDAK TERSEDIA'
    }


    AnimatedImage {
        id: item_img
        source: itemImage
        height: 300
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        scale: 1
        fillMode: Image.PreserveAspectFit
        width: 400
    }

    Rectangle{
        id: rec_empty_text
        anchors.fill: parent
        color: CONF.background_color
        opacity: .6
        visible: (itemStock == 0 || isSelected)
    }

    Text {
        id: empty_text
        anchors.fill: parent
        color: CONF.text_color
        text: 'TIDAK TERSEDIA'
        font.bold: true
        visible: (itemStock == 0 || isSelected)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 35
    }

    Text {
        id: item_name
        width: 400
        color: CONF.text_color
        text: itemName
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 70
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: false
        font.pixelSize: 20
    }

//    Text {
//        id: item_desc
//        width: 400
//        height: 200
//        color: "#1D294D"
//        text: itemDesc
//        visible: false
//        horizontalAlignment: Text.AlignLeft
//        verticalAlignment: Text.AlignTop
//        wrapMode: Text.WordWrap
//        font.italic: true
//        font.pixelSize: 20
//    }

    Rectangle{
        id: base_button_price
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        width: parent.width
        height: 60
        color: 'white'
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            id: item_price
            color: CONF.background_color
            text: (itemStock > 0) ? 'Rp. ' + FUNC.insert_dot(itemPrice) + ',-' : 'HABIS'
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 30
            verticalAlignment: Text.AlignVCenter
        }
    }


    Text {
        id: item_stock
        color: CONF.background_color
        text: itemStock
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
//        visible: false
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 15
        verticalAlignment: Text.AlignVCenter
    }


}

