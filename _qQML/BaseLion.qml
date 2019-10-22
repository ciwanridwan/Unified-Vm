import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    x:0
    y:0
    width:1280
    height:1024
    color: "white"
    property string mode_: "normal"
    property var use_
    property bool logo_vis: true
    property var show_img: (mode_!='normal') ? "source/logo_white_.png" : "source/logo_red_.png"
    property var top_color: (mode_!='normal') ? "#f03838" : "white"
    property bool isPanelActive: false
    property string imgPanel: "source/rocket.png"
    property string textPanel: "Greeting From Lion Air"
    property string colorPanel: "#f03838"
    property var imgPanelScale: 1

    Rectangle{
        id: rec_header
        width:1280
        height:100
        color: top_color
//                color: "#f03838"
        Image{
            id: img_logo
            visible: logo_vis
            x:0
            y:0
            width: 200
            height: 100
            source: show_img
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
        }
        GroupBox{
            id: groupBox1
            x: 0
            width: 150
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 20
            flat: true
            visible: (mode_=='normal' && use_==undefined) ? true : false
            Column{
                id: col_1
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                width: 150
                Text{
                    id: languange_text_1
                    width: parent.width
                    text: 'BAHASA/LANGUAGE'
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 11
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: 'Microsoft YaHei'
                    font.bold: true
                    color: 'darkred'
                }
                Row{
                    x: 12
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Rectangle{
                        id: ina_button
                        width: (parent.width/2)-10; height: width
                        color: (language=="ENG") ? 'white' : 'darkred'
                        radius: width/2
                        Text{
                            text: 'INA'
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.top: parent.top
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.bold: true
                            color: (language=="ENG") ? 'darkred' : 'white'
                            font.pixelSize: 20
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    _SLOT.set_language('INA.qm');
                                    language = "INA";
                                }
                            }
                        }
                    }
                    Rectangle{
                        id: eng_button
                        width: (parent.width/2)-10; height: width
                        color: (language=="ENG") ? 'darkred' : 'white'
                        radius: width/2
                        Text{
                            text: 'ENG'
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.top: parent.top
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            color: (language=="ENG") ? 'white' : 'darkred'
                            font.bold: true
                            font.pixelSize: 20

                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    _SLOT.set_language('ENG.qm');
                                    language = "ENG";
                                }
                            }
                        }
                    }
                }
//                Text{
//                    id: languange_text_2
//                    width: 150
//                    text: 'CHOOSE LANGUAGE'
//                    verticalAlignment: Text.AlignVCenter
//                    horizontalAlignment: Text.AlignHCenter
//                    font.family: 'Microsoft YaHei'
//                    color: 'darkred'
//                    font.pixelSize: 8
//                    font.italic: true
//                }
            }
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
            font.family:"Ubuntu"
            color: "white"
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    }

}
