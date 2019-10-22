import QtQuick 2.4
import QtQuick.Controls 1.3

Base{
    id:payment
    visible: false
    property var show_text: "Please insert your cash into the cash slot below, Kindly ensure it is clean and not folded."
//    property var show_text: "Please Insert Your Card Into The Reader, and Key In Your PIN Code to proceed payment."
    property var useMode//: "EDC" //["EDC", "MEI", "QPROX"]
    property var count100: "0"
    property var count50: "0"
    property var count20: "0"
    property var count10: "0"
    property var count5: "0"
    property var count2: "0"
    property var totalCount: "0"//"470000"
    property var count5R: "0"//"2"
    property var count2R: "0"//"10"
    property var totalCountR: "0"//"30000"
    property var totalAmount: "0"//"399000"
    property var escapeFunction: "closeWindow"

    Rectangle{
        id: base_overlay
        anchors.fill: parent
        color: "#472f2f"
        opacity: 0.7
    }

    Rectangle{
        id: white_base_rec
        visible: (useMode!="MEI") ? true : false
        color: "silver"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 750; height: 525
        Image{
            id: image_close
            source: "source/close.png"
            width: 80
            height: 80
            anchors.top: parent.top
            anchors.topMargin: -30
            anchors.right: parent.right
            anchors.rightMargin: -30
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
        Row{
            id: row_edc
            visible: (useMode=="EDC") ? true : false
            anchors.top: parent.top
            anchors.topMargin: 75
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            AnimatedImage{
                width: 300; height: 200;
                source: "source/insert_card_.png"
                fillMode: Image.PreserveAspectFit
            }
            AnimatedImage{
                width: 300; height: 200;
                source: "source/keyin_pin_.png"
                fillMode: Image.PreserveAspectFit
            }
        }
        Row{
            id: row_qprox
            visible: (useMode=="QPROX") ? true : false
            anchors.top: parent.top
            anchors.topMargin: 75
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            AnimatedImage{
                width: 300; height: 200;
                source: "source/cards_.png"
                fillMode: Image.PreserveAspectFit
            }
            AnimatedImage{
                width: 300; height: 200;
                source: "source/tap_card_.png"
                fillMode: Image.PreserveAspectFit
            }
        }
        Text {
            id: payment_text
            height: 120; width: parent.width - 50;
            color: "darkred"
            text: show_text
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            font.italic: true
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"
            font.pixelSize: 21
        }
    }

    Rectangle{
        id: mei_base_rec
        visible: (useMode=="MEI") ? true : false
        color: "silver"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 900; height: 650
        Image{
            id: image_close1
            source: "source/close.png"
            width: 80
            height: 80
            anchors.top: parent.top
            anchors.topMargin: -30
            anchors.right: parent.right
            anchors.rightMargin: -30
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

        Row{
            id: row_mei
            anchors.top: parent.top
            anchors.topMargin: 25
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25
            visible: parent.visible
            AnimatedImage{
                width: 300; height: 200;
                source: "source/prepare_cash_.png"
                fillMode: Image.PreserveAspectFit
            }
            AnimatedImage{
                width: 300; height: 200;
                source: "source/insert_cash_.png"
                fillMode: Image.PreserveAspectFit
            }
        }
        Row{
            id: row_text_notes
            width: parent.width; height: 30
            anchors.bottom: rows_images_notes.top
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            visible: parent.visible
            Rectangle{
                width: parent.width/2; height: parent.height
                color: "orange"
                Text{
                    text: "COUNT OF RECEIVED NOTES"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Ubuntu"
                    font.pixelSize: 20
                    font.bold: true
                    color: "darkred"
                    anchors.fill: parent
                }
            }
            Rectangle{
                width: parent.width/2; height: parent.height
                color: "darkred"
                Text{
                    text: "AVAILABLE RETURN NOTES"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Ubuntu"
                    font.pixelSize: 20
                    font.bold: true
                    color: "white"
                    anchors.fill: parent
                }
            }
        }
        Row{
            id: rows_images_notes
            height: 350; width: parent.width;
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 25
            spacing: 100
            visible: parent.visible
            Column{
                id: bill_notes_receive
                spacing : 10
                Row{
                    spacing: 25
                    Image{
                        id: img_count_100
                        width: 100; height: 50;
        //                rotation: 45
                        source: "source/100rb.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        id: count_100_text
                        text: "     x     " + count100
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Ubuntu"
                        font.pixelSize: 25
                        font.bold: true
                        color: "darkred"
                    }
                }
                Row{
                    spacing: 25
                    Image{
                        id: img_count_50
                        width: 100; height: 50;
        //                rotation: 45
                        source: "source/50rb.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        id: count_50_text
                        text: "     x     " + count50
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Ubuntu"
                        font.pixelSize: 25
                        font.bold: true
                        color: "darkred"
                    }
                }
                Row{
                    spacing: 25
                    Image{
                        id: img_count_20
                       width: 100; height: 50;
        //                rotation: 45
                        source: "source/20rb.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        id: count_20_text
                        text: "     x     " + count20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Ubuntu"
                        font.pixelSize: 25
                        font.bold: true
                        color: "darkred"
                    }
                }
                Row{
                    spacing: 25
                    Image{
                        id: img_count_10
                        width: 100; height: 50;
        //                rotation: 45
                        source: "source/10rb.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        id: count_10_text
                        text: "     x     " + count10
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Ubuntu"
                        font.pixelSize: 25
                        font.bold: true
                        color: "darkred"
                    }
                }
                Row{
                    spacing: 25
                    Image{
                        id: img_count_5
                        width: 100; height: 50;
        //                rotation: 45
                        source: "source/5rb.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        id: count_5_text
                        text: "     x     " + count5
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Ubuntu"
                        font.pixelSize: 25
                        font.bold: true
                        color: "darkred"
                    }
                }
                Row{
                    spacing: 25
                    Image{
                        id: img_count_2
                        width: 100; height: 50;
        //                rotation: 45
                        source: "source/2rb.png"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        id: count_2_text
                        text: "     x     " + count2
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: "Ubuntu"
                        font.pixelSize: 25
                        font.bold: true
                        color: "darkred"
                    }
                }
    //            Image{
    //                width: 100; height: 50;
    //                rotation: 45
    //                source: "source/1rb.png"
    //                fillMode: Image.PreserveAspectFit
    //            }
            }

        }
        Column{
            id: bill_notes_return
            anchors.top: row_text_notes.bottom
            anchors.topMargin: 13
            anchors.left: row_text_notes.right
            anchors.leftMargin: -425
            spacing : 10
            Row{
                spacing: 25
                Image{
                    id: img_count_5R
                    width: 100; height: 50;
    //                rotation: 45
                    source: "source/5rb.png"
                    fillMode: Image.PreserveAspectFit
                }
                Text{
                    id: count_5R_text
                    text: "     x     " + count5R
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Ubuntu"
                    font.pixelSize: 25
                    font.bold: true
                    color: "darkred"
                }
            }
            Row{
                spacing: 25
                Image{
                    id: img_count_2R
                    width: 100; height: 50;
    //                rotation: 45
                    source: "source/2rb.png"
                    fillMode: Image.PreserveAspectFit
                }
                Text{
                    id: count_2R_text
                    text: "     x     " + count2R
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Ubuntu"
                    font.pixelSize: 25
                    font.bold: true
                    color: "darkred"
                }
            }
        }
        Row{
            id: row_text_total_return
            x: 475; y: 389
            width: 300; height: 50;
            anchors.right: parent.right
            anchors.rightMargin: 125
            spacing: 0
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "#1D294D"; border.width: 2; border.color: "#1D294D";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: false
                    font.pixelSize: 15
                    text: "Available Change "
                    wrapMode: Text.NoWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    color: "white"
                }
            }
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "white"; border.width: 2; border.color: "#1D294D";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: true
                    font.pixelSize: 20
                    text: totalCountR
//                    text: "99.000"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "#1D294D"
                }
            }
        }
        Row{
            id: row_text_total_cost
            x: 475; y: 513
            width: 300; height: 50;
            anchors.right: parent.right
            anchors.rightMargin: 125
            spacing: 0
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "darkred"; border.width: 2; border.color: "darkred";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: false
                    font.pixelSize: 15
                    text: "Total Paid "
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    color: "white"
                }
            }
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "white"; border.width: 2; border.color: "darkred";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: true
                    font.pixelSize: 20
                    text: totalAmount
//                    text: "799.000"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "darkred"
                }
            }
        }
        Row{
            id: row_text_total_amount
            x: 475; y: 469
            width: 300; height: 50;
            anchors.right: parent.right
            anchors.rightMargin: 125
            spacing: 0
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "darkgreen"; border.width: 2; border.color: "darkgreen";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: false
                    font.pixelSize: 15
                    text: "Money Received "
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    color: "white"
                }
            }
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "white"; border.width: 2; border.color: "darkgreen";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: true
                    font.pixelSize: 20
                    text: totalCount
//                    text: "799.000"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "darkgreen"
                }
            }
        }
        Row{
            id: row_text_return_back
            x: 475; y: 569
            width: 300; height: 50;
            anchors.right: parent.right
            anchors.rightMargin: 125
            spacing: 0
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "orange"; border.width: 2; border.color: "orange";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: true
                    font.pixelSize: 15
                    text: "Change "
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    color: "black"
                }
            }
            Rectangle{
                width: parent.width/2; height: parent.height;
                color: "white"; border.width: 2; border.color: "orange";
                Text{
                    anchors.fill: parent;
                    font.family: "Ubuntu"
                    font.bold: true
                    font.pixelSize: 20
                    text: (parseInt(totalCount) - parseInt(totalAmount)).toString()
//                    text: "799.000"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "black"
                }
            }
        }
    }


    function open(){
        payment.visible = true
    }
    function close(){
        payment.visible = false
    }
}
