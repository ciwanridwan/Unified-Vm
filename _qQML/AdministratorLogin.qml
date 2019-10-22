import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: base_page
    property var press: '0'
    property int timer_value: 30
    property var usernameInput: ''
    property var passwordInput: ''
    property int stepInput: 0
    property var loginPurpose: 'adminPage'
    textPanel: "Masuk Mode Administrator"
    imgPanel: 'source/icon/lock_key.png'

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value;
            my_timer.start();
            usernameInput = '';
            passwordInput =  '';
            press = '0'
            stepInput = 0;
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
        }
    }

    Component.onCompleted:{
        base.result_user_login.connect(define_user_login);
    }

    Component.onDestruction:{
        base.result_user_login.disconnect(define_user_login);
    }

    function define_user_login(l){
        console.log('define_user_login', l);
        popup_loading.close();
        if (l.indexOf('ERROR') > -1){
            false_notif('Mohon Maaf|Gagal Melakukan Login. Pastikan Username dan Password Anda Benar')
            reset_input();
            return;
        }
        if (l.indexOf('OFFLINE') > -1){
            false_notif('Mohon Maaf|Gagal Melakukan Login. Pastikan Koneksi Internet Mesin Berjalan Dengan Baik')
            reset_input();
            return;
        }
        var _userData = JSON.parse(l.replace('SUCCESS|', ''));
        if (_userData.active==1 && _userData.isAbleTerminal==1) {
            my_layer.push(admin_manage, {userData: _userData});
        } else {
            false_notif('Mohon Maaf|Gagal Login, User Anda Tidak Aktif, Silakan Hubungi Master Admin')
            reset_input();
        }
    }

    function reset_input(){
        usernameInput = '';
        passwordInput = '';
        press = '0';
    }

    Rectangle{
        id: rec_timer
        width:10
        height:10
        y:10
        color:"transparent"
        QtObject{
            id:abc
            property int counter
            Component.onCompleted:{
                abc.counter = timer_value
            }
        }

        Timer{
            id:my_timer
            interval:1000
            repeat:true
            running:true
            triggeredOnStart:true
            onTriggered:{
                abc.counter -= 1
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    BackButton{
        id:back_button
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        z: 10
        visible: !popup_loading.visible
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    property int globalFontSize: 40
    property int globalLabelSize: 40
    property int textRecWidth: 700
    property int textRecHeigth: 80


    Rectangle{
        id: rec_parent
        color: "transparent"
        anchors.verticalCenterOffset: 50
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 1200
        height: 900
        visible: (!popup_loading.visible && !standard_notif_view.visible) ? true : false

        Label{
            id: username_label
            width: 250
            height: textRecHeigth
            text: 'Pengguna : '
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.left: parent.left
            anchors.leftMargin: 140
            textFormat: Text.PlainText
            font.pixelSize: globalLabelSize
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: 'white'
            font.family: "Ubuntu"

        }

        TextRectangle{
            id: textUsernameRectangle
            usedBy: inputUsernameText
            y:150
            width: 600
            height: textRecHeigth
            anchors.left: username_label.right
            anchors.leftMargin: 50
            anchors.verticalCenter: username_label.verticalCenter
            placeHolder: ""
            borderColor: "white"
            baseColor: "white"
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    stepInput = 0;
                    usernameInput = "";
                }
            }
        }

        TextInput {
            id: inputUsernameText
            anchors.centerIn: textUsernameRectangle;
            text: usernameInput
            cursorVisible: (stepInput==0) ? true : false
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: globalFontSize
            color: "black"
            clip: true
            visible: true
            focus: (stepInput==0) ? true : false
        }

        Label{
            id: password_label
            width: 250
            height: textRecHeigth
            text: 'Kata Sandi : '
            anchors.top: parent.top
            anchors.topMargin: 250
            anchors.left: parent.left
            anchors.leftMargin: 140
            textFormat: Text.PlainText
            font.pixelSize: globalLabelSize
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: 'white'
            font.family: "Ubuntu"

        }

        TextRectangle{
            id: textPasswordRectangle
            usedBy: inputPasswordText
            y:textUsernameRectangle.y + 125
            width: 600
            height: textRecHeigth
            anchors.left: password_label.right
            anchors.leftMargin: 50
            anchors.verticalCenter: password_label.verticalCenter
            placeHolder: ""
            borderColor: "white"
            baseColor: "white"
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    stepInput = 1;
                }
            }
        }

        TextInput {
            id: inputPasswordText
            anchors.centerIn: textPasswordRectangle;
            text: passwordInput
            cursorVisible: (stepInput==1) ? true : false
            horizontalAlignment: Text.AlignLeft
            font.family: "Ubuntu"
            font.pixelSize: globalFontSize
            color: "black"
            clip: true
            visible: true
            focus: (stepInput==1) ? true : false
            echoMode: TextInput.Password
        }

        FullKeyboard{
            id:virtual_keyboard
            x:332;
            width: 930; height: 371;
            anchors.top: parent.top
            anchors.topMargin: 500
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            isShifted: false
            isHighlighted: false
            alphaOnly: false
            numberOnly: false
            property int count:0
            visible: (!popup_loading.visible && !standard_notif_view.visible) ? true : false
            scale: visible ? 1.0 : 0.1
            Behavior on scale {
                NumberAnimation  { duration: 500 ; easing.type: Easing.InOutBounce  }
            }

            Component.onCompleted: {
                virtual_keyboard.strButtonClick.connect(typeIn)
                virtual_keyboard.funcButtonClicked.connect(functionIn)
            }

            function functionIn(str){
                if(str == "OK"){
                    if (press != '0') return
                    press = '1'
                    if (usernameInput==""){
                        press = '0';
                        false_notif('Mohon Maaf|Pastikan Username Yang Dimasukkan Benar')
                        return
                    } else if (passwordInput==""){
                        press = '0';
                        false_notif('Mohon Maaf|Pastikan Password Yang Dimasukkan Benar')
                        return
                    } else {
                        count = 0;
                        if (loginPurpose=='adminPage'){
                            popup_loading.open();
                            _SLOT.get_kiosk_login(usernameInput, passwordInput);
                        } else if (usernameInput.toLowerCase() == 'vm--reb00t' && passwordInput.toLowerCase() == '0ffl1n3') {
                            false_notif('Mohon Tunggu|Mesin VM Akan Dinyalakan Kembali Dalam Beberapa Saat.');
                            standard_notif_view.buttonEnabled = false;
                            reboot_button_action.enabled = true;
                        } else if (usernameInput.toLowerCase() == 'grg--res37' && passwordInput.toLowerCase() == '0ffl1n3') {
                            false_notif('Mohon Tunggu|Mencobda Mereset GRG Dalam Beberapa Saat.');
                            __SLOT.start_init_grg();
                        } else {
                            false_notif('Dear User| No Action This Time For ['+loginPurpose+']');
                        }
                    }
                }
                if(str=="Back"){
                    if (count <= 0) {
                        count = 0;
                        if (stepInput==0) usernameInput = "";
                        if (stepInput==1) passwordInput = "";
                        return
                    }
                    press = "0";
                    count--;
                    if (stepInput==0) usernameInput = usernameInput.substring(0, usernameInput.length-1);
                    if (stepInput==1) passwordInput = passwordInput.substring(0, passwordInput.length-1);
                }
            }

            function typeIn(str){
    //            console.log("input :", str)
                var max_count = 20;
                if (stepInput==0) max_count = 20;
                if (stepInput!=0) max_count = 30;
                if (count >= max_count) {
                    count = max_count
                    return
                }
                count++;
                if (stepInput==0) usernameInput += str;
                if (stepInput==1) passwordInput += str;
                abc.counter = timer_value;
                my_timer.restart();
            }
        }
    }

    function false_notif(param){
        press = '0';
        standard_notif_view.z = 100;
        standard_notif_view._button_text = 'tutup';
        if (param==undefined){
            standard_notif_view.show_text = "Mohon Maaf";
            standard_notif_view.show_detail = "Terjadi Kesalahan Pada Sistem, Mohon Coba Lagi Beberapa Saat";
        } else {
            standard_notif_view.show_text = param.split('|')[0];
            standard_notif_view.show_detail = param.split('|')[1];
        }
        standard_notif_view.open();
    }

    //==============================================================


    StandardNotifView{
        id: standard_notif_view
        withBackground: false
        modeReverse: true
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
        MouseArea{
            id: reboot_button_action
            x: 1020; y: 694
            width: 180
            height: 90
            enabled: false
            onClicked: {
                _SLOT.start_safely_shutdown('RESTART');
            }
        }
    }

    PopupLoading{
        id: popup_loading
    }

}
