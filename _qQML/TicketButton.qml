import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import "base_function.js" as FUNC

Rectangle{
    id: ticket_button
    property var price1 : "1555000"
    property var price2 : "2777000"
    property var price3 : "3999000"
    property var f_no: "ID-873"
    property var f_time: "04:30 - 07:20"
    property var selected_price: []
    property int qty1 : 1
    property int qty2 : 1
    property int qty3 : 1
    property var fromTo : "CGK - DPS"
//    property var color__: (flight_no.indexOf("ID") > -1) ? "purple" : "red"
    property var color__: "purple"
    property var raw1: undefined
    property var raw2: undefined
    property var raw3: undefined
//    property var raw0: undefined
    property var f_type: "900-ER"
    property var f_status: "DEPARTURE"
//    property bool clearSelected: false

    color: "white"
    radius: 0
    width: 900
    height: 100

    Image{
        id: base_image
        x: 0; y: 0
        width: 265
        height: 95
        scale: 0.7
        opacity: 1
        source: FUNC.get_flight_logo(f_no)
        fillMode: Image.PreserveAspectFit
    }

    GroupBox{
        y: -8
        width: 450
        height: 95
        flat: true

        Text {
            id: text_flight_no
            x: 91
            y: 0
            font.family:"GothamRounded"
            color: "black"
            text: f_no
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 51
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 20
        }

        Text {
            id: text_flight_type
            x: 159
            font.family:"GothamRounded"
            color: "black"
            text: f_type
            font.italic: true
            anchors.top: parent.top
            anchors.topMargin: 60
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 17
        }

        Image{
            id: img_status
            x: 269
            y: 44
            source: FUNC.get_plane_image_tiny(f_status)
//            source: "source/departure.png"
            fillMode: Image.PreserveAspectFit
            width: 50
            height: 50
        }

        Text {
            id: text_flight_time
            x: 99
            y: -3
            color: "black"
            text: f_time
            anchors.horizontalCenterOffset: 130
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 48
            font.bold: false
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "GothamRounded"
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.PlainText
            font.pixelSize: 25
        }

        Text {
            id: text_from_to
            x: 327
            y: 48
            color: "black"
            text: fromTo
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "GothamRounded"
            textFormat: Text.PlainText
            font.pixelSize: 20
        }

    }

    GroupBox{
        x: 528
        y: -1
        flat: true
        checked: false
        Text {
            id: text_promo
            x: -8
            y: -6
            text: "Promo"
            color: "darkred"
            font.bold: true
            font.family:"GothamRounded"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 15
        }
        Text {
            id: text_eco
            x: 119
            y: -6
            text: "Economy"
            color: "darkgreen"
            font.bold: true
            font.family:"GothamRounded"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 15
        }
        Text {
            id: text_business
            x: 260
            y: -6
            text: "Business"
            color: "#1D294D"
            font.bold: true
            font.family:"GothamRounded"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 15
        }

    }

    Row{
        x: 482
        y: 25
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: 10
        TicketChildButton{
            id: image_button1
            price_: FUNC.insert_dot(price1)
            active_: (qty1>0) ? true : false
            mode_: "promo"
//            selected_: clearSelected
            MouseArea{
                anchors.fill: parent
                enabled: parent.active_
                onClicked: {
                    if (base_select_ticket.press!="0") return;
//                    clearSelected = false;
                    console.log("[info] ticket_button pressed : ", parent.mode_ )
                    var param = { "price": price1, "raw": raw1, "master_raw": 'raw0',
                        "f_no": f_no, "f_type": f_type, "f_time": f_time,
                        "fromTo": fromTo, "f_status": f_status,
                        "f_logo": (color__=="purple") ? "source/batik_air_logo.jpg" : "source/lion_air_logo.jpg"
                    }
                    base_select_ticket.get_selected_price(JSON.stringify(param))
//                    base_select_ticket.selectedPrice.push(JSON.stringify(param))
                    parent.selected_ = true;
                }
            }
        }
        TicketChildButton{
            id: image_button2
            price_: FUNC.insert_dot(price2)
            active_: (qty2>0) ? true : false
            mode_: "eco"
//            selected_: clearSelected
            MouseArea{
                anchors.fill: parent
                enabled: parent.active_
                onClicked: {
                    if (base_select_ticket.press!="0") return;
//                    clearSelected = false;
                    console.log("[info] ticket_button pressed : ", parent.mode_ )
                    var param = { "price": price2, "raw": raw2, "master_raw": 'raw0',
                        "f_no": f_no, "f_type": f_type, "f_time": f_time,
                        "fromTo": fromTo, "f_status": f_status,
                        "f_logo": (color__=="purple") ? "source/batik_air_logo.jpg" : "source/lion_air_logo.jpg"
                    }
                    base_select_ticket.get_selected_price(JSON.stringify(param))
                    parent.selected_ = true;
                }
            }
        }
        TicketChildButton{
            id: image_button3
            price_: FUNC.insert_dot(price3)
            active_: (qty3>0) ? true : false
            mode_: "business"
//            selected_: clearSelected
            MouseArea{
                anchors.fill: parent
                enabled: parent.active_
                onClicked: {
                    if (base_select_ticket.press!="0") return;
//                    clearSelected = false;
                    console.log("[info] ticket_button pressed : ", parent.mode_ )
                    var param = { "price": price3, "raw": raw3, "master_raw": 'raw0',
                        "f_no": f_no, "f_type": f_type, "f_time": f_time,
                        "fromTo": fromTo, "f_status": f_status,
                        "f_logo": (color__=="purple") ? "source/batik_air_logo.jpg" : "source/lion_air_logo.jpg"
                    }
                    base_select_ticket.get_selected_price(JSON.stringify(param))
                    parent.selected_ = true;
                }
            }
        }
    }

    Rectangle {
        id: footer_button
        width: 900
        height: 2
        color: "gray"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }
}

