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
                var formated_price = 'Rp. ' + FUNC.insert_dot(p[i]['rs_price']) + ',-';
                var prod_name = p[i]['category'].toUpperCase() + ' - ' + p[i]['operator'] + ' ' + formated_price;
                var desc = p[i]['description'];
                if (['TAGIHAN', 'TAGIHAN AIR'].indexOf(p[i]['category'].toUpperCase()) > -1 ) {
                    prod_name = p[i]['category'].toUpperCase() + ' - ' + p[i]['description'];
                    desc = 'Plus Biaya Admin ' + formated_price;
                }
                if (['VOUCHER', 'ZAKAT', 'PAKET INTERNET', 'UANG ELEKTRONIK', 'GAME', 'OJEK ONLINE', 'PULSA', 'LISTRIK'].indexOf(p[i]['category'].toUpperCase()) > -1 ) {
                    prod_name = p[i]['description'];
                    desc = p[i]['operator'] + ' ' + 'Rp. ' + FUNC.insert_dot(p[i]['rs_price']) + ',-';
                }
                product_model.append({
                                         'ppob_name': prod_name,
                                         'ppob_desc': desc,
                                         'ppob_price': formated_price,
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
        press = '0';
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
        press = '0';
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
                _SLOT.user_action_log('press "KEMBALI" In PPOB Product Page');
                my_timer.stop()
                my_layer.pop()
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: 180
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Pilih Nominal / Item Produk'
        visible: !popup_loading.visible
        size_: 50
        color_: "white"

    }

    Item  {
        id: flickable_items
        width: 1100
        height: 750
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
            cellHeight: 170
            cellWidth: 1010
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentHeight: 150
            contentWidth: 1000
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
            LongItemPPOB{
                id: item_ppob;
                text_: ppob_name;
                text2_: ppob_desc;
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        _SLOT.user_action_log('choose "'+ppob_name+'" PPOB Product');
                        var details = {
                            category: raw.category,
                            operator: raw.operator,
                            description: raw.description,
                            product_id: raw.product_id,
                            rs_price: raw.rs_price,
                            amount: raw.amount
                        }
                        console.log('Set Selected Product Into Input Layer: ', JSON.stringify(details));
                        my_layer.push(global_input_number, {selectedProduct: details, mode: 'PPOB'});
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

