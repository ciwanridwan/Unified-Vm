import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: ppob_category
    property int timer_value: 60*5
    isPanelActive: false
    isHeaderActive: true
    isBoxNameActive: false
    textPanel: 'Pilih Kategori Produk'
    property var ppobData
    property var category: []
    property bool frameWithButton: false

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.start()
            popup_loading.open()
            if (ppobData!=undefined) parse_category(ppobData)
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

    function parse_category(p){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('parse_category', now, p);
        p = JSON.parse(p)
        for (var i=0;i < p.length;i++){
            var get_category = p[i]['category']
//            console.log('>>>>>test parse_category', get_category, p[i]);
            if (category.indexOf(p[i]['category']) == -1) category.push(p[i]['category'])
        }
//        console.log('category update', category);
        if (category.length > 0) parse_item_category(category);
        else switch_frame('source/smiley_down.png', 'Maaf Sementara Layanan Ini Tidak Dapat Digunakan', '', 'backToMain', false );

    }

    function parse_item_category(c){
        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        console.log('parse_item_category', now, c);
        category_model.clear();
        gridViewPPOB.model = category_model;
        for (var _c=0; _c < category.length;_c++){
            var logo_category = FUNC.strip(category[_c].toLowerCase())
            category_model.append({
                                      'category_text': category[_c],
                                      'category_url': 'source/ppob_category/'+logo_category+'.png'
                                  })
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
        button_text: 'BATAL'
        modeReverse: true
        MouseArea{
            anchors.fill: parent
            onClicked: {
                _SLOT.user_action_log('press "KEMBALI" In PPOB Category Page');
                my_timer.stop()
                my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    MainTitle{
        anchors.top: parent.top
        anchors.topMargin: (globalScreenType == '1') ? 175 : 150
        anchors.horizontalCenter: parent.horizontalCenter
        show_text: 'Pilih Kategori Produk'
        visible: !popup_loading.visible
        size_: (globalScreenType == '1') ? 50 : 45
        color_: "white"

    }

    Item  {
        id: flickable_items
        width: (globalScreenType == '1') ? 1550 : parent.width
        height: 800
        anchors.verticalCenterOffset: 120
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        ScrollBarVertical{
            id: vertical_sbar
            flickable: gridViewPPOB
            height: flickable_items.height
            color: "white"
            expandedWidth: 15
        }

        GridView{
            id: gridViewPPOB
            cellHeight: 203
            cellWidth: 379
            anchors.fill: parent
            flickableDirection: Flickable.VerticalFlick
            contentHeight: 183
            contentWidth: 359
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
            id: category_model
        }

        Component{
            id: component_ppob
            SmallSimplyItemPPOB{
                id: item_ppob;
                modeReverse: true
                sourceImage: category_url
                categoryName: category_text
                MouseArea{
                    anchors.fill: parent;
                    onClicked: {
                        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                        console.log('Selected Category : ', now, category_text);
                        _SLOT.user_action_log('choose "'+category_text+'" PPOB Category');
                        my_layer.push(ppob_product, {ppobData: ppobData, selectedCategory: category_text})
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

