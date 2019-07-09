import QtQuick 2.4
import QtQuick.Controls 1.2
import QtWebKit 3.0
import "screen.js" as SCREEN

Base{
    property int timer_value: 300
    property var consId: "16718"
    property var ipServer: "202.4.170.9"
    property var webUrl: "http://"+ipServer+"/LionWebCheckIn/StartWebCheckIn.aspx?consID="+consId

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.restart()
            loader.sourceComponent = component
            webUrl = "http://"+ipServer+"/LionWebCheckIn/StartWebCheckIn.aspx?consID="+consId
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
        }

    }

    Component.onCompleted: {
        base.result_general.connect(handle_general);
    }

    Component.onDestruction: {
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
            notif_view.show_text = qsTr("Dear User")
            notif_view.show_detail = qsTr("This Kiosk Machine will be rebooted in 30 seconds.")
            notif_view.open()
        }
    }


    Rectangle{
        width:39
        height:11
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
                counting_text.text = "Time Left : " + abc.counter
                abc.counter -= 1
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    Component {
        id: component
        Rectangle {
            y: 100; x: 0;
            ScrollView {
                width: parseInt(SCREEN.size.width)
                height: 924
                WebView {
                    id: webview
                    url: webUrl
                    anchors.fill: parent
                    onLinkHovered:{
                        abc.counter = timer_value
                        my_timer.restart()
                        webUrl = hoveredUrl
                        loader.sourceComponent = component
                    }
                }
            }
        }
    }

    Loader { id: loader }

    BackButton{
        id:back_button
        x:20
        y:8
        MouseArea {
            anchors.fill: parent
            onClicked: {
                my_layer.pop()
            }
        }
    }

    Text{
        id:counting_text
        x:10
        y:738
        color:"#FFFF00"
        font.family:"Ubuntu"
        font.pixelSize:16
        visible: false
    }

    NotifView{
        id: notif_view
        isSuccess: false
        z: 99
    }
}

