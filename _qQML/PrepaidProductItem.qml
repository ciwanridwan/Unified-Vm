import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "base_function.js" as FUNC


Rectangle{
    id: rectangle1
    width:800
    height:400
    color:"transparent"
    property var itemName: 'Product Name'
    property var itemImage: 'aAsset/tapcash-card.png'
    property var itemPrice: '19000'
    property var itemStock: 10
    property var itemDesc: 'Product Description Product Description Product Description Product Description Product Description Product Description'

    Rectangle{
        id: base_ground
        color: 'white'
        opacity: 0.6
        anchors.fill: parent
        radius: 25
    }

    AnimatedImage {
        id: item_img
        source: itemImage
        height: 300
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: -15
        scale: 0.8
        fillMode: Image.PreserveAspectFit
        width: 400
    }

    Text {
        id: item_name
        width: 400
        color: "#323683"
        text: itemName
        anchors.right: parent.right
        anchors.rightMargin: 25
        horizontalAlignment: Text.AlignRight
        anchors.top: parent.top
        anchors.topMargin: 25
        font.bold: false
        font.pointSize: 30
    }

    Text {
        id: item_desc
        width: 400
        height: 200
        color: "#323683"
        text: itemDesc
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

    Text {
        id: item_price
        width: 400
        height: 60
        color: "#323683"
        text: 'Rp. ' + FUNC.insert_dot(itemPrice) + ',-'
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        font.pointSize: 35
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: item_stock
        color: "#323683"
        text: 'Stock : ' + itemStock
        horizontalAlignment: Text.AlignHCenter
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        font.pointSize: 25
        verticalAlignment: Text.AlignVCenter
    }


}

