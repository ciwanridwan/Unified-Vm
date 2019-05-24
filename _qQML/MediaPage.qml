import QtQuick 2.4
import QtQuick.Controls 1.2
import Qt.labs.folderlistmodel 1.0
import QtMultimedia 5.0


Rectangle{
    id:parent_root
    color: "black"
    width: 1920
    height: 1080
    property var img_path: "/_vVideo/"
    property url img_path_: ".." + img_path
    property var qml_pic
    property string pic_source: ""
    property int num_pic
    property string mode // ["staticVideo", "mediaPlayer", "liveView"]
//    property var list_pic: img_files
    property variant media_files: []
    property int index: 0

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            console.log('ads mode : ' +  mode)
            if(mode=="mediaPlayer" && media_files.length == 0){
                _SLOT.get_file_list(img_path);
            }
        }
        if(Stack.status==Stack.Deactivating){
            player.stop()
            while (media_files.length > 0) {
                media_files.pop();
            }
        }
    }

    Component.onCompleted: {
        base.result_get_file_list.connect(get_result);
        base.result_general.connect(handle_general);
    }

    Component.onDestruction: {
        base.result_get_file_list.disconnect(get_result);
        base.result_general.disconnect(handle_general);
    }


    function handle_general(result){
        console.log("handle_general : ", result)
        if (result=='') return
        if (result=='REBOOT'){
            loading_view.close()
            notif_view.z = 99
            notif_view.isSuccess = false
            notif_view.closeButton = false
            notif_view.show_text = "Dear User"
            notif_view.show_detail = "This Kiosk Machine will be rebooted in 30 seconds."
            notif_view.open()
        }
    }


    function get_result(result){
        console.log('get_result : ', result);
        if (result == "ERROR" || result == ""){
            console.log("No Media Files!");
        } else {
            var files = JSON.parse(result);
            if (files.dir == img_path){
                media_files = files.result;
                console.log("Media Files (" + media_files.length + ") : " + media_files)
                if (media_files.length > 0){
                    if (!mediaOnPlaying) media_mode.setIndex(0);
                    console.log("Media is Being Played Already!")
                } else{
                    console.log("Cannot Play Media!")
                }
            }
        }
    }


    // Play Multiple Videos
    Rectangle {
        id: media_mode
        visible: (mode=="mediaPlayer") ? true : false
        anchors.fill: parent
        color: "black"

        function setIndex(i){
            index = i;
            index %= media_files.length;
            player.source = img_path_ + media_files[index];
//            slot_handler.start_post_tvclog(media_files[index])
            player.play();
            mediaOnPlaying = true;
        }

        function next(){
            setIndex(index + 1);
        }

        function previous(){
            setIndex(index - 1);
        }

        Connections {
            target: player
            onStopped: {
                if (player.status == MediaPlayer.EndOfMedia) {
                    if (index==media_files.length-1){ //Looping start from beginning
                        media_mode.setIndex(0);
                    } else{
                        media_mode.next();
                    }
                }
            }
        }

        MediaPlayer {
            id: player
        }

        VideoOutput {
            anchors.fill: parent
            source: player
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                player.stop();
                while (media_files.length > 0) {
                    media_files.pop();
                }
                my_layer.pop();
                mediaOnPlaying = false;
            }
            onDoubleClicked: {
                player.stop();
                while (media_files.length > 0) {
                    media_files.pop();
                }
                my_layer.pop();
                mediaOnPlaying = false;
            }
        }
    }

    Rectangle{
        id: header_opacity
        width: parent.width
        height: 125
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
    }

    Rectangle{
        id: running_text_box
        width: parent.width
        height: 100
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle{
            id: opacity_background
            anchors.fill: parent
            color: 'white'
            opacity: .4
        }

        Text{
            id: moving_text
            x: parent.width
            anchors.fill: rec_bottom
            color: "darkblue"
            text: 'Mesin Ini Hanya Menerima Pembelian Dan Isi Ulang Kartu e-Money Mandiri.                          <<<Sentuh Layar Untuk Memulai Transaksi>>>'
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 55
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"

            NumberAnimation on x{
                from: running_text_box.width
                to: -1 * moving_text.width
                loops: Animation.Infinite
                duration: (parent.width/60) * 500
            }
        }
    }

}

