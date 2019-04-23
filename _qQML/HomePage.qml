import QtQuick 2.4
import QtQuick.Controls 1.2

Base{
    id: base_page
    property var press: "0"
    property var gui_version: ""
    property int tvc_timeout: 60
    property bool isMedia: true
    property bool kioskStatus: false


    Stack.onStatusChanged:{
        if(Stack.status == Stack.Activating){
            _SLOT.get_kiosk_status()
            _SLOT.start_idle_mode()
            press = "0";
            timer_clock.restart();
            if(isMedia){
                tvc_loading.counter = tvc_timeout;
                show_tvc_loading.start();
            }
        }
        if(Stack.status==Stack.Deactivating){
            loading_view.close();
            timer_clock.stop();
            show_tvc_loading.stop();
        }
    }

    Component.onCompleted: {
        base.result_get_gui_version.connect(get_gui_version);
        base.result_generate_pdf.connect(get_pdf);
        base.result_general.connect(handle_general);
        base.result_kiosk_status.connect(get_kiosk_status);
    }

    Component.onDestruction: {
        base.result_get_gui_version.disconnect(get_gui_version);
        base.result_generate_pdf.disconnect(get_pdf);
        base.result_general.disconnect(handle_general);
        base.result_kiosk_status.disconnect(get_kiosk_status);
    }

    function get_kiosk_status(r){
        console.log("get_kiosk_status : ", r)
        if (r=="ONLINE" || r=="AVAILABLE") {
            kioskStatus = true;
        } else {
            kioskStatus = false;
            loading_view.close()
            notif_view.z = 99
            notif_view.isSuccess = false
            notif_view.show_text = qsTr("Out Of Service")
            notif_view.show_detail = qsTr("This Kiosk Machine is not Connected into The Server.")
            notif_view.open()
        }
    }

    function not_authorized(){
        loading_view.close()
        notif_view.z = 99
        notif_view.isSuccess = false
        notif_view.show_text = qsTr("Out Of Service")
        notif_view.show_detail = qsTr("This Kiosk Machine cannot be used at This Moment.")
        notif_view.open()
    }

    function handle_general(result){
        console.log("handle_general : ", result)
        if (result=='') return
        if (result=='REBOOT'){
            loading_view.close()
            notif_view.z = 99
            notif_view.isSuccess = false
            notif_view.closeButton = false
            notif_view.show_text = qsTr("Dear User")
            notif_view.show_detail = qsTr("This Kiosk Machine will be rebooted in 30 seconds.")
            notif_view.open()
        }
    }


    function get_pdf(pdf){
        console.log("get_pdf : ", pdf)
    }

    function get_gui_version(result){
        console.log("GUI VERSION : ", result)
        gui_version = result
    }

    MasterButton {
        id: ticket_button
        x: 0
        y: 100
        x_pos: 0
        y_pos: 61
        widht_: 642
        height_: 639
        color_: "beige"
        img_: "aAsset/belitiket_black.png"
        text_: qsTr("Tiket Pesawat")
        text2_: qsTr("Flight Ticket")
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (kioskStatus===true){
                    if (press!="0") return
                    press = "1"
                    my_layer.push(select_plan)
                    _SLOT.start_restart_mdd_service()
    //                loading_view.open()
                    _SLOT.set_tvc_player("STOP")
                    _SLOT.stop_idle_mode()
                    show_tvc_loading.stop()
                } else {
                    not_authorized();
                }
            }
        }
    }

    MasterButton {
        id: checkbook_button
        x: 642
        y: 100
        width: 638
        height: 639
        x_pos: 642
        y_pos: 61
        widht_: 642
        height_: 639
        color_: "orangered"
        img_: "aAsset/check-in_counter.png"
        text_: qsTr("Check-In")
        text2_: qsTr("Check-In")
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (kioskStatus===true){
                    if (press!="0") return
                    press = "1"
//                    my_layer.push(global_web_view, {ipServer: "202.4.170.9", consId: "16718"})
                    my_layer.push(checkin_page)
                    _SLOT.set_tvc_player("STOP")
                    _SLOT.stop_idle_mode()
                    show_tvc_loading.stop()
                } else {
                    not_authorized();
                }
            }
        }
    }


    MasterButton {
        id: faq_button
        x: 0
        y: 736
        width: 318
        height: 288
        x_pos: 0
        y_pos: 700
        widht_: 318
        height_: 324
        color_: "MEDIUMSEAGREEN"
        img_: "aAsset/faq_black.png"
        text_: qsTr("Pertanyaan Umum")
        text2_: qsTr("F A Q")
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (kioskStatus===true){
                    if (press!="0") return
                    press = "1"
                    if (base.language=="INA") {
                        my_layer.push(faq_ina)
                    } else {
                        my_layer.push(faq_en)
                    }
                    _SLOT.set_tvc_player("STOP")
                    _SLOT.stop_idle_mode()
                    show_tvc_loading.stop()
                } else {
                    not_authorized();
                }
            }
        }
    }

    MasterButton {
        id: print_button
        x: 318
        y: 736
        width: 324
        height: 288
        x_pos: 318
        y_pos: 700
        widht_: 323
        height_: 324
        color_: "GOLD"
        img_: "aAsset/print_ticket.png"
        text_: qsTr("Cetak Ulang")
        text2_: qsTr("Re-Print")
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (kioskStatus===true){
                    if (press!="0") return
                    press = "1"
                    my_layer.push(reprint_view)
                    _SLOT.set_tvc_player("STOP")
                    _SLOT.stop_idle_mode()
                    show_tvc_loading.stop()
                } else {
                    not_authorized();
                }
            }
        }
    }

    MasterButton {
        id: buy_button
        x: 642
        y: 736
        width: 318
        height: 288
        x_pos: 642
        y_pos: 700
        widht_: 638
        height_: 324
        color_: "GOLDENROD"
        img_: "aAsset/icon_pembelian_black.png"
        text_: qsTr("Belanja")
        text2_: qsTr("Shop")
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (kioskStatus===true){
                    if (press!="0") return
                    press = "1"
                    my_layer.push(coming_soon)
                    _SLOT.set_tvc_player("STOP")
                    _SLOT.stop_idle_mode()
                    show_tvc_loading.stop()
                } else {
                    not_authorized();
                }
            }
        }
    }


    MasterButton {
        id: payment_button
        x: 960
        y: 736
        width: 320
        height: 288
        x_pos: 642
        y_pos: 61
        widht_: 638
        height_: 325
        color_: "DODGERBLUE"
        img_: "aAsset/pembayaran_black.png"
        text_: qsTr("Pembayaran")
        text2_: qsTr("Payment")
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (kioskStatus===true){
                    if (press!="0") return
                    press = "1"
                    my_layer.push(coming_soon)
                    _SLOT.set_tvc_player("STOP")
                    _SLOT.stop_idle_mode()
                    show_tvc_loading.stop()
                } else {
                    not_authorized();
                }
            }
        }
    }


    Rectangle{
        id: timer_tvc
        width: 10
        height: 10
        x:0
        y:0
        visible: false
        QtObject{
            id:tvc_loading
            property int counter
            Component.onCompleted:{
                tvc_loading.counter = tvc_timeout;
            }
        }
        Timer{
            id:show_tvc_loading
            interval:1000
            repeat:true
            running:false
            triggeredOnStart:true
            onTriggered:{
                tvc_loading.counter -= 1
                if(tvc_loading.counter == 0){
                    console.log("starting tvc player...")
                    _SLOT.set_tvc_player("START")
                    tvc_loading.counter = tvc_timeout
                    show_tvc_loading.restart()
                }
            }
        }
    }


    Text {
        id: timeText
        x: 8
        y: 16
        width: 150
        height: 35
        text: new Date().toLocaleTimeString(Qt.locale("en_EN"), "hh:mm:ss")
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.family:"Microsoft YaHei"
        font.pixelSize:30
        color:"darkred"
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
        x: 8
        y: 52
        height: 25
        text: new Date().toLocaleDateString(Qt.locale("en_EN"), Locale.LongFormat)
        font.italic: false
        verticalAlignment: Text.AlignVCenter
        font.family:"Microsoft YaHei"
        font.pixelSize:20
        color:"darkred"
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


    LoadingView{
        id:loading_view
        z: 99
        show_text: qsTr("Preparing...")
    }

    NotifView{
        id: notif_view
        isSuccess: false
        z: 99
    }

}
