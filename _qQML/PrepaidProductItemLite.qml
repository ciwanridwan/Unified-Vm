import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC


Rectangle{
    id: rectangle1
    width:400
    height:450
    color:"transparent"
    property var itemName: 'Product Name'
    property var itemImage: 'aAsset/card_tj_original.png'
    property var itemPrice: '19000'
    property var itemStock: 10
    property var itemDesc: 'Product Description Product Description Product Description Product Description Product Description Product Description'

    AnimatedImage {
        id: item_img
        source: itemImage
        height: 300
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
        scale: 0.8
        fillMode: Image.PreserveAspectFit
        width: 400
    }

    ColorOverlay{
        source: item_img
        anchors.fill: item_img
        color: 'gray'
        opacity: .7
        scale: 0.8
        visible: (itemStock > 0) ? false : true
    }

    Text {
        id: item_name
        width: 400
        color: "white"
        text: itemName
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 120
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.bold: false
        font.pointSize: 20
    }

    Text {
        id: item_desc
        width: 400
        height: 200
        color: "#9E4305"
        text: itemDesc
        visible: false
        horizontalAlignment: Text.AlignLeft
        anchors.verticalCenterOffset: 0
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        font.italic: true
        font.pointSize: 20
    }

    Rectangle{
        id: base_button_price
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: 300
        height: 60
        color: 'white'
        radius: 20
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            id: item_price
            color: '#9E4305'
            text: (itemStock > 0) ? 'Rp. ' + FUNC.insert_dot(itemPrice) + ',-' : 'HABIS'
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 30
            verticalAlignment: Text.AlignVCenter
        }
    }


    Text {
        id: item_stock
        color: "#9E4305"
        text: 'Stock : ' + itemStock
        visible: false
        anchors.bottom: item_img.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 20
        verticalAlignment: Text.AlignVCenter
    }


}

