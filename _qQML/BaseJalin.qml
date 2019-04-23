import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0


Rectangle{
    id: main
    x:0
    y:0
    width:1280
    height:1024
    color: "firebrick"
    property string mode_: "normal"
    property var use_
    property bool logo_vis: true
    property bool withSlider: false
    property int header_heigth: 100
    property int idx_bg: 0
    property variant backgrounds: ['aAsset/jalin-hero1.png', 'aAsset/jalin-hero2.png', 'aAsset/jalin-hero3.png', 'aAsset/jalin-hero4.png']
    // Old Property Not Used But Cannot Be Removed
    property bool isPanelActive: false
    property string imgPanel: "aAsset/rocket.png"
    property string textPanel: "Greeting From Lion Air"
    property string colorPanel: "#f03838"
    property var imgPanelScale: 1
    property var show_img: (mode_!='normal') ? "aAsset/logo_white_.png" : "aAsset/logo_red_.png"
    property var top_color: (mode_!='normal') ? "#f03838" : "white"



    Image{
        id: img_background
        visible: !withSlider
        opacity: 0.3
        source: backgrounds[idx_bg]
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
    }

    Rectangle{
        id: rec_header
        width:1280
        height:header_heigth
        color: "firebrick"
        opacity: .7
        Image {
            id: ornament
            source: "aAsset/ornament_header.png"
            anchors.fill: parent
            fillMode: Image.Tile
            visible: false
        }
        ColorOverlay {
            visible: !ornament.visible
            anchors.fill: ornament
            source: ornament
            opacity: .2
            color: "#000000"
        }
    }

    Image{
        id: img_logo_center
        visible: logo_vis
        x: 0
        z: 999
        width: 250
        height: 200
        anchors.top: parent.top
        anchors.topMargin: -28
        scale: 0.7
        source: "aAsset/gather-together-small.png"
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: rec_header.horizontalCenter
    }

    Image{
        id: img_logo_left
        x:0
        y:0
        width: 200
        height: header_heigth
        scale: 0.65
        source: "aAsset/jalin-logo.png"
        anchors.verticalCenter: rec_header.verticalCenter
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    Image{
        id: img_logo_mdd
        x:0
        y:0
        width: 200
        height: header_heigth
        source: "aAsset/mdd-logo.png"
        anchors.verticalCenter: rec_header.verticalCenter
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    ColorOverlay {
        anchors.fill: img_logo_mdd
        source: img_logo_mdd
        color: "#ffffff"
        anchors.leftMargin: 10
    }

    Text {
        id: timeText
        x: 0
        y: 15
        width: 150
        height: 35
        text: new Date().toLocaleTimeString(Qt.locale("id_ID"), "hh:mm:ss")
        anchors.right: parent.right
        anchors.rightMargin: 20
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.family:"Microsoft YaHei"
        font.pixelSize:30
        color:"#ffffff"
        MouseArea{
            id: secret_button
            anchors.fill: parent;
            onClicked: {
                if(parent.text.indexOf(':3')> - 1){
                    my_layer.push(backdooor_login);
                } else {
                    return
                }
            }
        }
    }

    Text {
        id: dateText
        x: 0
        y: 50
        width: 250
        height: 25
        text: new Date().toLocaleDateString(Qt.locale("id_ID"), Locale.LongFormat)
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.rightMargin: 20
        font.italic: false
        verticalAlignment: Text.AlignVCenter
        font.family:"Microsoft YaHei"
        font.pixelSize:20
        color:"#ffffff"
    }

    Timer {
        id: timer_clock
        interval: 1000
        repeat: true
        running: true
        onTriggered:
        {
            timeText.text = new Date().toLocaleTimeString(Qt.locale("en_EN"), "hh:mm:ss")
        }
    }

    Rectangle{
        id: rec_left_panel
        y: 100
        width: 300
        height: parent.height - 100
        visible: isPanelActive
        color: colorPanel
        Image{
            id: img_left_panel
            x: 0
            width: 300
            height: 628
            scale: imgPanelScale
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            source: imgPanel
            fillMode: Image.PreserveAspectFit
        }
        Text{
            id: text_left_panel
            text: textPanel
            anchors.topMargin: 100
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            style: Text.Sunken
            wrapMode: Text.WordWrap
            font.pixelSize: 45
            font.family:"Microsoft YaHei"
            color: "white"
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    }


}
