import QtQuick 2.0

Item {
    id: scrollbar
    property Flickable flickable : undefined
    property int basicWidth: 10
    property int expandedWidth: 20
    property alias color : scrl.color
    property alias radius : scrl.radius

    width: basicWidth
    anchors.right: flickable.right;
    anchors.top: flickable.top
    anchors.bottom: flickable.bottom

    clip: true
    visible: flickable.visible
    z:1

    Binding {
        target: scrollbar
        property: "width"
        value: expandedWidth
        when: ma.drag.active || ma.containsMouse
    }
    Behavior on width {NumberAnimation {duration: 150}}

    Rectangle {
        id: scrl
        clip: true
        anchors.left: parent.left
        anchors.right: parent.right
        height: flickable.visibleArea.heightRatio * flickable.height
        visible: flickable.visibleArea.heightRatio < 1.0
        radius: 10
        color: "white"

        opacity: ma.pressed ? 1 : ma.containsMouse ? 0.65 : 0.4
        Behavior on opacity {NumberAnimation{duration: 150}}

        Binding {
            target: scrl
            property: "y"
            value: !isNaN(flickable.visibleArea.heightRatio) ? (ma.drag.maximumY * flickable.contentY) / (flickable.contentHeight * (1 - flickable.visibleArea.heightRatio)) : 0
            when: !ma.drag.active
        }

//        Connections{
//            target: ma
//            onClicked: {
//                if(ma.drag.active && flickable !== undefined){
//                    flickable.contentY = scrl.get_binding()
//                }
//            }
//        }

        Binding {
            target: flickable
            property: "contentY"
            value: scrl.get_binding()
            when: ma.drag.active && flickable !== undefined
        }

        function get_binding(){
            return ((flickable.contentHeight * (1 - flickable.visibleArea.heightRatio)) * scrl.y) / ma.drag.maximumY
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            drag.target: parent
            drag.axis: Drag.YAxis
            drag.minimumY: 0
            drag.maximumY: flickable.height - scrl.height
            preventStealing: true
        }
    }
}
