import QtQuick 2.4
import QtQuick.Controls 1.2
import QtWebKit 3.0

Base{
    property var geturl: "http://103.28.14.165:88/tibox/index.php?tid=110001"
    property int timer_value: 300

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.restart()
            loader.sourceComponent = component
        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
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
                countShow_test.text = abc.counter
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
            ScrollView {
                width: 1280
                height: 1024
                WebView {
                    id: webview
                    url: geturl
                    anchors.fill: parent
                    onLinkHovered:{
                        abc.counter = timer_value
                        my_timer.restart()
                        geturl = hoveredUrl
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
        y:20

        MouseArea {
            anchors.fill: parent
            onClicked: {
                my_layer.pop()
            }
        }
    }

    Text{
        id:countShow_test
        x:10
        y:738
        color:"#FFFF00"
        font.family:"GothamRounded"
        font.pixelSize:16
        visible: false
    }

}

