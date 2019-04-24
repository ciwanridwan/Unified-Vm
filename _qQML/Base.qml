import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0


Rectangle{
    id: main
    x:0
    y:0
    width: 1920
    height: 1080
    color: "transparent"
    property string mode_: "normal"
    property var use_
    property var boxName: base.globalBoxName
//    property var boxName: 'VM Shelter Blok M 01'
    property bool logo_vis: true
    property int header_height: 125
    property int idx_bg: 0
    //Change Background Asset
    property variant backgrounds: ['aAsset/mandiri_background.png', 'aAsset/mandiri_background.png', 'aAsset/mandiri_background.png', 'aAsset/mandiri_background.png' ]
    // Old Property Not Used But Cannot Be Removed
    property bool isPanelActive: false
    property bool isBoxNameActive: true
    property bool isHeaderActive: true
    property string imgPanel: "aAsset/rocket.png"
    property string textPanel: ""
    property string colorPanel: "white"
    property int panelWidth: 400
    property var imgPanelScale: .9
    property var show_img: (mode_!='normal') ? "aAsset/logo_white_.png" : "aAsset/logo_red_.png"
    property var top_color: (mode_!='normal') ? "#f03838" : "white"


    Image{
        id: img_background
        visible: true
        source: 'aAsset/mandiri_background.png'
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
    }

    Rectangle{
        id: header_opacity
        width: parent.width
        height: header_height
        color: 'white'
        visible: true
        opacity: 0.1
    }

    Image{
        id: img_logo_left
        width: 275
        height: 100
        anchors.verticalCenter: header_opacity.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 50
        source: "aAsset/emoney_logo.png"
        fillMode: Image.PreserveAspectFit
        visible: true
    }

    Image{
        id: img_logo_right
        width: 275
        height: 100
        anchors.verticalCenter: header_opacity.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50
        source: "aAsset/mandiri_logo.png"
        fillMode: Image.PreserveAspectFit
        visible: true
    }

    Text {
        id: boxNameText
        width: 500
        height: 50
        text: boxName
        visible: isBoxNameActive
        style: Text.Sunken
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.italic: false
        verticalAlignment: Text.AlignVCenter
        font.family:"Microsoft YaHei"
        font.pixelSize:35
        color:"#ffffff"
        z: 10

    }

//    Rectangle{
//        id: base_overlay_clock
//        color: 'black'
//        opacity: .5
//        width: 300
//        height: 100
//        radius: 25
//        visible: !isPanelActive
//        anchors.right: parent.right
//        anchors.rightMargin: -20
//        anchors.top: parent.top
//        anchors.topMargin: 0
//        z: 10
//    }


    Text {
        id: timeText
        x: 0
        width: 150
        height: 35
        style: Text.Sunken
        text: new Date().toLocaleTimeString(Qt.locale("id_ID"), "hh:mm:ss")
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family:"Microsoft YaHei"
        font.pixelSize:30
        color:"#ffffff"
        visible: isBoxNameActive

    }

    Text {
        id: dateText
        x: 0
        width: 250
        height: 25
        style: Text.Sunken
        text: new Date().toLocaleDateString(Qt.locale("id_ID"), Locale.LongFormat)
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.italic: false
        verticalAlignment: Text.AlignVCenter
        font.family:"Microsoft YaHei"
        font.pixelSize:20
        color:"#ffffff"
        visible: isBoxNameActive
    }

    Timer {
        id: timer_clock
        interval: 1000
        repeat: true
        running: isBoxNameActive
        onTriggered:
        {
            timeText.text = new Date().toLocaleTimeString(Qt.locale("en_EN"), "hh:mm:ss")
        }
    }

//    Image {
//        id: img_logo_kasirku
//        width: 150
//        height: 80
//        anchors.left: parent.left
//        anchors.leftMargin: 120
//        fillMode: Image.PreserveAspectFit
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 20
//        source: "aAsset/kasirku_inacraft.png"
//        visible: !isPanelActive
//        z: 10
//    }

//    Image {
//        id: img_logo_jaklinggo
//        width: 150
//        height: 80
//        scale: 0.9
//        anchors.left: img_logo_kasirku.right
//        anchors.leftMargin: 0
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 20
//        source: "aAsset/logo_jaklinggo.png"
//        visible: !isPanelActive
//        z: 10
//    }



    Rectangle{
        id: rec_left_panel
        y: header_height
        width: panelWidth
        height: parent.height - header_height
//        visible: isPanelActive
        visible: false
        color: '#9E4305'
        opacity: .97
//        Rectangle{
//            id: opacity
//            color: colorPanel
//            opacity: .7
//            anchors.fill: parent
//        }
//        Image {
//            id: img_pattern
//            source: "aAsset/ornament_header.png"
//            anchors.fill: parent
//            opacity: .20
//            fillMode: Image.Tile
//        }
        Image{
            id: img_left_panel
            x: 0
            width: panelWidth
            height: 600
            scale: imgPanelScale
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 125
            source: imgPanel
            fillMode: Image.PreserveAspectFit
            visible: false
        }
        ColorOverlay {
            id: reverse_color_image
            anchors.fill: img_left_panel
            source: img_left_panel
            color: 'white'
            scale: imgPanelScale
        }
        Text{
            id: text_left_panel
            color: "white"
            text: textPanel
            anchors.topMargin: 150
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            font.pixelSize: 40
            font.family:"Microsoft YaHei"
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    }

}
