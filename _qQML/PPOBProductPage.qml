import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: ppob_product
    property int timer_value: 60*5
    isPanelActive: false
    isHeaderActive: true
    isBoxNameActive: false
    textPanel: 'Pilih Produk'
    property var ppobData
    property bool frameWithButton: false
    property var selectedCategory


    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.start()
            popup_loading.open()
            if (ppobData!=undefined) parse_item_category(selectedCategory)
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
    }

    Component.onDestruction:{
    }


    function parse_item_category(c){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('parse_item_category', now, c);
        product_model.clear();
        gridViewPPOB.model = product_model;
        var p = JSON.parse(ppobData)
        for (var i=0;i < p.length;i++){
            if (p[i]['category']==c){
                product_model.append({
                                         'ppob_text': p[i]['description'],
                                         'ppob_url': 'source/ppob_icon/' + p[i]['operator'] + '.png',
                                         'ppob_price': 'Rp. ' + FUNC.insert_dot(p[i]['amount']) + ',-',
                                         'raw': p[i]
                                      })
            }

        }

        popup_loading.close();
    }


    function false_notif(closeMode, textSlave){
        if (closeMode==undefined) closeMode = 'backToMain';
        if (textSlave==undefined) textSlave = '';
        press = '0';
        switch_frame('source/smiley_down.png', 'Maaf Sementara Mesin Tidak Dapat Digunakan', textSlave, closeMode, false )
        return;
    }

    function switch_frame(imageSource, textMain, textSlave, closeMode, smallerText){
        frameWithButton = false;
        if (closeMode.indexOf('|') > -1){
            closeMode = closeMode.split('|')[0];
            var timer = closeMode.split('|')[1];
            global_frame.timerDuration = parseInt(timer);
        }
        global_frame.imageSource = imageSource;
        global_frame.textMain = textMain;
        global_frame.textSlave = textSlave;
        global_frame.closeMode = closeMode;
        global_frame.smallerSlaveSize = smallerText;
        global_frame.withTimer = true;
        global_frame.open();
    }

    function switch_frame_with_button(imageSource, textMain, textSlave, closeMode, smallerText){
        frameWithButton = true;
        global_frame.imageSource = imageSource;
        global_frame.textMain = textMain;
        global_frame.textSlave = textSlave;
        global_frame.closeMode = closeMode;
        global_frame.smallerSlaveSize = smallerText;
        global_frame.withTimer = false;
        global_frame.open();
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


    CircleButton{
        id:back_button
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        button_text: 'KEMBALI'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_timer.stop()
                my_layer.pop()
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    Item  {
        id: flickable_items
        width:320*4
        height:parent.height-200
        anchors.verticalCenterOffset: 100
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        ScrollBarVertical{
            id: vertical_sbar
            flickable: gridViewPPOB
            height: flickable_items.height
            color: "white"
            expandedWidth: 15
        }

        GridView{
            id: gridViewPPOB
            cellHeight: 420
            cellWidth: 320
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentHeight: 400
            contentWidth: 300
            flickDeceleration: 750
            maximumFlickVelocity: 1500
            layoutDirection: Qt.LeftToRight
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: 500
            keyNavigationWraps: true
            snapMode: ListView.SnapToItem
            clip: true
            focus: true
            delegate: component_ppob
            add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 500 }
                    NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 500 }
                }
        }

        ListModel {
            id: product_model
        }

        Component{
            id: component_ppob
            ItemPPOB{
                id: item_ppob;
                showText2: true;
                text2_: ppob_price;
                text_: ppob_text;
                img_: ppob_url;
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        console.log('Selected Product : ', JSON.stringify(raw));
                        my_layer.push(global_input_number, {selectedProduct: raw, mode: 'PPOB'});
                    }
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

    PopupLoading{
        id: popup_loading
    }

    GlobalFrame{
        id: global_frame
    }




}

