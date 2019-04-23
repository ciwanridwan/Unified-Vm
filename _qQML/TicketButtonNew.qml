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
    property var fromTo : "CGK - DPS - SUB"
//    property var color__: (flight_no.indexOf("ID") > -1) ? "purple" : "red"
    property var color__: "purple"
    property var raw1: undefined
    property var raw2: undefined
    property var raw3: undefined
//    property var raw0: undefined
    property var f_type//: "900-ER"
    property var f_status//: "DEPARTURE"
    property var is_transit//: 1
    property var is_same_origin//: 0
    property var trans_flight_time//: '10:30 - 11:40'
    property var trans_flight_no//: 'IW-1835'
    property var trans_flight_point//: 'SUB'
    property var new_origin: undefined
    property var __color__: "white"
    property var __height__: 190
    property int priceMargin: 3

//    property bool clearSelected: false

    radius: 0;
    width: 900;
    color: __color__;
    height: __height__;

    /*{
'origin': 'CGK',
'promo_price': 0,
'eco_qty': '11',
'flight_time_int': 5.0,
'trans_flight_point': 'SUB',
'raw_data_eco': '11|1362000.0000|0|0|B?JT?690?2018-05-31T05:00:00?2018-05-31T06:30:00?1?I?CGK?SRG?SUB?IW?1835?2018-05-31T10:30:00?2018-05-31T11:40:00?2?',
'flight_status': 'DEPARTURE',
'bus_price': 0,
'flight_time': '05:00 - 06:30',
'trans_flight_no': 'IW-1835',
'is_transit': 1,
'bus_qty': 0,
'raw_data_promo':
'??JT?690?2018-05-31T05:00:00?2018-05-31T06:30:00?1?I?CGK?SRG?SUB?IW?1835?2018-05-31T10:30:00?2018-05-31T11:40:00?2?',
'trans_flight_time': '10:30 - 11:40',
'promo_qty': 0,
'raw_data_bus': '??JT?690?2018-05-31T05:00:00?2018-05-31T06:30:00?1?I?CGK?SRG?SUB?IW?1835?2018-05-31T10:30:00?2018-05-31T11:40:00?2?',
'flight_date': '2018-05-31',
'eco_price': 1362000,
'flight_no': 'JT-690',
'is_same_origin': 1,
'flight_type': '737-900ER',
'route_trip': 'CGK - SUB - SRG'
}
*/

    function get_final_time(){
        if (is_transit==1){
            var takeOff = f_time.split(" - ")[0];
            var landing = trans_flight_time.split(" - ")[1];
            return  takeOff + " - " + landing;
        }
        return f_time;
    }

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

    Image{
        id: base_image_trans
        x: 0; y: 100
        width: 265
        visible: (is_transit==1) ? true : false
        height: 95
        source: (is_transit==1) ? FUNC.get_flight_logo(trans_flight_no) : ""
        scale: 0.7
        opacity: 1
        fillMode: Image.PreserveAspectFit
    }

    GroupBox{
        y: -8
        id: main_flight_group
        width: 450
        height: 95
        flat: true

        Text {
            id: text_flight_no
            x: 150
            y: 0
            font.family:"Microsoft YaHei"
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
            font.family:"Microsoft YaHei"
            color: "black"
            text: f_type
            font.italic: true
            anchors.top: parent.top
            anchors.topMargin: 60
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 15
        }

        Image{
            id: img_status
            x: 269
            y: 40
            source: FUNC.get_plane_image_tiny(f_status)
//            source: "aAsset/departure.png"
            fillMode: Image.PreserveAspectFit
            width: 50
            height: 50
        }

        Text {
            id: text_flight_time
            x: 99
            y: -3
            color: "black"
//            text: get_final_time()
            text: f_time
            anchors.horizontalCenterOffset: 130
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 48
            font.bold: false
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.PlainText
            font.pixelSize: 25
        }

        Rectangle{
            color: "black"
            x: 327; y: 50
            visible: (is_same_origin==1) ? false : true
            width: text_from_to.width
            height: text_from_to.height
        }

        Text {
            id: text_from_to
            x: 327
            y: 50
            color: (is_same_origin==1) ? "black" : "white"
            text: fromTo.substring(0, 9)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            font.bold: (is_same_origin==1) ? true : false
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            textFormat: Text.PlainText
            font.pixelSize: 20
        }

    }

    GroupBox{
        y: 90
        id: transit_flight_group
        width: 450
        height: 95
        flat: true
        visible: (is_transit==1) ? true : false

        Rectangle{
            x: 0; y: -3
            color: "darkred"
            width: 80; height: 20
            Text{
                anchors.fill: parent;
                color: "white"
                text: "TRANSIT"
                font.pixelSize: 15
                font.family:"Microsoft YaHei"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.PlainText
            }

        }

        Text {
            id: text_flight_no_trans
            x: 150
            y: 0
            font.family:"Microsoft YaHei"
            color: "black"
            text: trans_flight_no
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 51
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 20
        }

        Image{
            id: img_status_trans
            x: 271
            y: 40
            source: FUNC.get_plane_image_tiny(f_status)
            //            source: "aAsset/departure.png"
            fillMode: Image.PreserveAspectFit
            width: 50
            height: 50
        }

        Text {
            id: text_flight_time_trans
            x: 99
            y: -3
            color: "black"
            text: trans_flight_time
            anchors.horizontalCenterOffset: 130
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 48
            font.bold: false
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.PlainText
            font.pixelSize: 25
        }

        Text {
            id: text_from_to_trans
            x: 327
            y: 48
            color: "black"
            text: fromTo.substring(6, fromTo.length)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Microsoft YaHei"
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
            font.family:"Microsoft YaHei"
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
            font.family:"Microsoft YaHei"
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
            color: "darkblue"
            font.bold: true
            font.family:"Microsoft YaHei"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            font.pixelSize: 15
        }

    }

    Row{
        x: 482
        y: (is_transit==1) ? 60 : 25;
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: 10
        TicketChildButton{
            id: image_button1
            price_: FUNC.insert_dot(FUNC.round_fare(price1, priceMargin).toString())
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
                        "fromTo": fromTo, "f_status": f_status, "f_new_origin": new_origin,
                        "f_is_same_origin": is_same_origin, "f_is_transit": is_transit,
                        "f_trans_flight_point": trans_flight_point,
                        "f_trans_flight_no": trans_flight_no, "f_trans_flight_time" : trans_flight_time,
                        "f_logo": FUNC.get_flight_logo(f_no)
                    }
                    base_select_ticket.get_selected_price(JSON.stringify(param))
                    parent.selected_ = true;
                }
            }
        }
        TicketChildButton{
            id: image_button2
            price_: FUNC.insert_dot(FUNC.round_fare(price2, priceMargin).toString())
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
                        "fromTo": fromTo, "f_status": f_status, "f_new_origin": new_origin,
                        "f_is_same_origin": is_same_origin, "f_is_transit": is_transit,
                        "f_trans_flight_point": trans_flight_point,
                        "f_trans_flight_no": trans_flight_no, "f_trans_flight_time" : trans_flight_time,
                        "f_logo": FUNC.get_flight_logo(f_no)
                    }
                    base_select_ticket.get_selected_price(JSON.stringify(param))
                    parent.selected_ = true;
                }
            }
        }
        TicketChildButton{
            id: image_button3
            price_: FUNC.insert_dot(FUNC.round_fare(price3, priceMargin).toString())
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
                        "fromTo": fromTo, "f_status": f_status, "f_new_origin": new_origin,
                        "f_is_same_origin": is_same_origin, "f_is_transit": is_transit,
                        "f_trans_flight_point": trans_flight_point,
                        "f_trans_flight_no": trans_flight_no, "f_trans_flight_time" : trans_flight_time,
                        "f_logo": FUNC.get_flight_logo(f_no)
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

