import QtQuick 2.4
import QtQuick.Controls 1.2

Base{
    id:loading
    visible: false
    use_: "media"
//    property var show_gif: "source/loader.gif" //"source/loading_plane.gif"
    property var show_text: "Being Processed..."
    property var img_path: "../_iImage/"
    property variant qml_pic: []
    property string pic_source: ""
    property int index_pic: 0
    property int duration: 3000
    property bool show_caption: true

//    AnimatedImage  {
//        id: loading_image
//        width: 250
//        height: 250
//        fillMode: Image.PreserveAspectFit
//        anchors.verticalCenter: base_overlay.verticalCenter
//        anchors.horizontalCenter: base_overlay.horizontalCenter
//        source: show_gif
//    }

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            _SLOT.get_file_list(img_path);
            open();
        }
        if(Stack.status==Stack.Deactivating){
            close();
        }
    }

    Component.onCompleted: {
        _SLOT.get_file_list(img_path);
        base.result_get_file_list.connect(parse_result);
    }

    Component.onDestruction: {
        base.result_get_file_list.disconnect(parse_result);
    }

    function parse_result(r){
//        console.log('parse_result', r);
        if (r.length > 0) {
            if (JSON.parse(r).dir == img_path){
                qml_pic = JSON.parse(r).result
                loader.sourceComponent = loader.Null;
                pic_source = img_path + qml_pic[0];
                loader.sourceComponent = component;
                slider_timer.start();
            }
        }
    }

    Timer{
        id:slider_timer
        interval:duration
        repeat:true
        running:false
        triggeredOnStart:false
        onTriggered:{
            if(index_pic < qml_pic.length){
                index_pic += 1;
                if(index_pic == qml_pic.length){
                    slider_timer.restart();
                    loader.sourceComponent = loader.Null;
                    pic_source = img_path + qml_pic[0];
                    loader.sourceComponent = component;
                    index_pic = 0;
                }else{
                    slider_timer.restart();
                    loader.sourceComponent = loader.Null;
                    pic_source = img_path + qml_pic[index_pic];
                    loader.sourceComponent = component;
                }
            }
        }
    }

    Component {
        id: component
        Rectangle {
            AnimatedImage {
                id:ad_pic
                x: 0
                y: 100
                width: loading.width
                height: loading.height - 100
                source: pic_source
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    Loader { id: loader }

    Rectangle{
        id: base_overlay
        width: parent.width; height: 50
        color: "#472f2f"
        opacity: 0.7
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        visible: show_caption
        Text {
            id: loading_text
            color: "white"
            anchors.fill: parent
            text: show_text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family:"Ubuntu"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
        }
    }

    function open(){
        loading.visible = true;
    }
    function close(){
        loading.visible = false;
        slider_timer.stop()
    }
}
