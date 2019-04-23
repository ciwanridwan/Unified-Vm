import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: check_in_success
    mode_: "reverse"
    isPanelActive: true
    textPanel: (language=="INA") ?  "Dapatkan Boarding Pass" : "Get Your Boarding Pass"
    imgPanel: "aAsset/icon/boarding-pass-white.png"
    imgPanelScale: 0.85
    property int timer_value: 60

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.start()

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
        base.result_print_boarding_pass.connect(handle_print);
    }

    Component.onDestruction:{
        base.result_print_boarding_pass.disconnect(handle_print);
    }

    function handle_print(result){
        console.log('Printing Result : ', result)
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
                timer_text.text = abc.counter
                abc.counter -= 1
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    Row{
        x: 1100
        y: 40
        spacing: 5
        z: 100
        Text{
            text: (language=='INA') ? qsTr("Sisa Waktu : ") : qsTr("Time Left : ")
            font.pixelSize: 20
            color: "yellow"
            font.family: "Microsoft YaHei"
        }
        Text{
            id: timer_text
            font.pixelSize: 20
            text: "500"
            color: "yellow"
            font.family: "Microsoft YaHei"
        }
    }

//    BackButton{
//        id:back_button
//        x: 100 ;y: 40;
//        MouseArea{
//            anchors.fill: parent
//            onClicked: {
//                my_layer.pop()
//            }
//        }
//    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    property string mainTextEng:  "Congratulations, You've Been Successfully Checked In For Your Flights."
    property string mainTextIna:  'Selamat, Anda Telah Berhasil CheckIn Pada Penerbangan Anda.'
    property string slaveTextEng: 'Please Take The Printed Boarding Pass Below And Bring It Along.'
    property string slaveTextIna: 'Silakan Ambil Boarding Pass Anda Yang Tercetak di Bawah.'
    property int mainTextSize: 28
    property string oneTextEng: '1. Ensure That Your Baggages Is In Your Possesion All The Times.'
    property string oneTextIna: '1. Selalu Pastikan Barang Bawaan Selalu Dalam Pantauan Anda.'
    property string twoTextEng: '2. You Must Be Aware of The Contents in Your Baggage.'
    property string twoTextIna: '2. Anda Harus Memahami Isi Barang-barang Anda.'
    property string threeTextEng: '3. You Need To Be Aware That The Above Classified Goods Are Not Permitted in Your Baggage.'
    property string threeTextIna: '3. Anda Harus Memahami Bahwa Klasifikasi di Atas Tidak Diperkenankan Ada Pada Barang Anda.'

    property string secondTitleEng: 'DO NOT CARRY DANGEROUS GOODS IN YOUR BAGS OR ON YOUR PERSON'
    property string secondTitleIna: 'JANGAN MEMBAWA BARANG-BARANG BERBAHAYA INI BERSAMA ANDA ATAU REKAN ANDA'

    property string finalTextEng: 'By Printing Your Boarding Pass In This Kiosk,\nYou Are Deemed To Have Agreed And Complied With The Above Security Requirements.'
    property string finalTextIna: 'Dengan Mencetak Boarding Pass Anda Melalui Kiosk Ini,\nAnda Dianggap Telah Setuju Dan Memenuhi Persyaratan Keamanan Di Atas.'

    property string importantOneEng: '1. Boarding Gate Closes 15 Minutes Before Departure Time.'
    property string importantOneIna: '1. Gerbang Keberangkatan Ditutup 15 Menit Sebelum Waktu Keberangkatan.'
    property string importanttwoEng: '2. Check In Your Baggage at Baggage Drop Counter Not Later Than 60 Minutes Prior to Departure.'
    property string importanttwoIna: '2. Masukkan Barang Bagasi Anda Di Kaunter Bagasi Tidak Lebih dari 60 Menit Sebelum Waktu Keberangkatan.'
    property string importantthreeEng: '3. If you do not report at our Boarding Gate at least 30 minutes before departure then you will be offloaded from the flight. You will be then liable for gate no-show fee.'
    property string importantthreeIna: '3. Jika Anda Tidak Melapor Di Gerbang Keberangkatan Hingga 30 Menit Sebelum Keberangkatan, Maka Anda Akan Diturunkan Dari Penerbangan Dan Anda Bertanggungjawab Atas Biaya Keterlambatan'


    Text{
        id: congrat_text
        width: 950
        height: mainTextSize + 5
        text: (language=='INA') ? mainTextIna : mainTextEng
        font.italic: true
        anchors.left: parent.left
        anchors.leftMargin: 300
        anchors.top: parent.top
        anchors.topMargin: 110
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: 'darkred'
        font.bold: false
        font.pixelSize: mainTextSize
        font.family: 'Microsoft YaHei'

    }

    Text{
        id: get_boarding_text
        width: 950
        height: mainTextSize + 5
        text: (language=='INA') ? slaveTextIna : slaveTextEng
        anchors.topMargin: 10
        font.italic: true
        anchors.left: parent.left
        anchors.leftMargin: 300
        anchors.top: congrat_text.bottom
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: 'darkred'
        font.bold: false
        font.pixelSize: mainTextSize
        font.family: 'Microsoft YaHei'

    }

    Text{
        id: important_text_title
        width: 950
        height: 24
        text: (language=='INA') ? 'Catatan Penting' : 'Important Notes'
        anchors.topMargin: 20
        font.italic: false
        anchors.left: parent.left
        anchors.leftMargin: 310
        anchors.top: get_boarding_text.bottom
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: 'darkred'
        font.bold: true
        font.pixelSize: 22
        font.family: 'Microsoft YaHei'

    }

    Text{
        id: important_one_text
        width: 950
        height: 24
        text: (language=='INA') ? importantOneIna : importantOneEng
//        text: importantOneEng
        anchors.topMargin: 5
        font.italic: false
        anchors.left: parent.left
        anchors.leftMargin: 310
        anchors.top: important_text_title.bottom
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: 'darkred'
//        font.bold: true
        font.pixelSize: 18
        font.family: 'Microsoft YaHei'

    }

    Text{
        id: important_two_text
        width: 950
        height: 48
        text: (language=='INA') ? importanttwoIna : importanttwoEng
//        text: importanttwoEng
        anchors.topMargin: 5
        font.italic: false
        anchors.left: parent.left
        anchors.leftMargin: 310
        anchors.top: important_one_text.bottom
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: 'darkred'
//        font.bold: true
        font.pixelSize: 18
        font.family: 'Microsoft YaHei'

    }

    Text{
        id: important_three_text
        width: 950
        height: 48
        text: (language=='INA') ? importantthreeIna : importantthreeEng
//        text: importantthreeEng
        anchors.topMargin: 5
        font.italic: false
        anchors.left: parent.left
        anchors.leftMargin: 310
        anchors.top: important_two_text.bottom
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: 'darkred'
//        font.bold: true
        font.pixelSize: 18
        font.family: 'Microsoft YaHei'

    }



    GroupBox{
        id: security_info
        flat: true
        width: 980
        height: 500
        anchors.top: parent.top
        anchors.topMargin: 380
        anchors.left: parent.left
        anchors.leftMargin: 300

        Column{
            anchors.fill: parent
            spacing: 10
            Rectangle{
                id: title_security_info
                width: parent.width
                height: 30
                color: 'darkred'
                Text{
                    text: (language=='INA') ? 'Persyaratan Keamanan' : 'Security Requirements'
                    width: parent.width
                    height: parent.height
                    font.pixelSize: 24
//                    font.bold: true
                    font.family: 'Microsoft YaHei'
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'white'
                }

            }

            Text{
                text: (language=='INA') ? secondTitleIna : secondTitleEng
//                text: secondTitleEng
                width: parent.width
                height: 30
                font.pixelSize: 19
                font.bold: true
                font.family: 'Microsoft YaHei'
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                color: 'darkred'
            }


            Image{
                id: good_security
                source: 'aAsset/goods_policy.png'
                fillMode: Image.PreserveAspectFit
                width: parent.width
                height: 300
                scale: 0.9
            }

            Rectangle{
                id: no_1_info
                width: parent.width
                height: 25
                color: 'transparent'
                Text{
                    text: (language=='INA') ? oneTextIna : oneTextEng
                    width: parent.width
                    height: parent.height
                    font.pixelSize: 20
//                    font.bold: true
                    font.family: 'Microsoft YaHei'
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: 'darkred'
                }

            }

            Rectangle{
                id: no_2_info
                width: parent.width
                height: 25
                color: 'transparent'
                Text{
                    text: (language=='INA') ? twoTextIna : twoTextEng
                    width: parent.width
                    height: parent.height
                    font.pixelSize: 20
//                    font.bold: true
                    font.family: 'Microsoft YaHei'
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: 'darkred'
                }

            }

            Rectangle{
                id: no_3_info
                width: parent.width
                height: 25
                color: 'transparent'
                Text{
                    text: (language=='INA') ? threeTextIna : threeTextEng
                    width: parent.width
                    height: parent.height
                    font.pixelSize: 20
//                    font.bold: true
                    font.family: 'Microsoft YaHei'
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: 'darkred'
                }

            }

            Rectangle{
                width: parent.width
                height: 30
                color: 'transparent'
            }

            Rectangle{
                id: final_info
                width: parent.width
                height: 80
                color: 'red'
                Text{
                    text: (language=='INA') ? finalTextIna : finalTextEng
//                    text: finalTextEng
                    width: parent.width
                    height: parent.height
                    font.pixelSize: 21
                    font.family: 'Microsoft YaHei'
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: 'white'
                }

            }
        }

    }





    //==============================================================

    ConfirmView{
        id: confirm_view
        show_text: "Dear Customer"
        show_detail: "Proceed This ?."
        z: 99
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
            }
        }
    }

    NotifView{
        id: notif_view
        isSuccess: false
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: "Finding Flight..."
    }




}

