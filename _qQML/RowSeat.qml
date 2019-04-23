import QtQuick 2.0

Rectangle{
    id: base_rec

    property var seat_no: "1"
    property var seat_pos: "BACK"
    property var seat_type: "REGULAR"
    property var seat_a: "01A#DUMMY"
    property var seat_b: "01B#AVAILABLE"
    property var seat_c: "01C#NOT_AVAILABLE"
    property var seat_d: "01D#AVAILABLE"
    property var seat_e: "01E#EMERGENCY"
    property var seat_f: "01F#EMERGENCY"
    property var textFront: 'FRONT'
    property var textBack: 'BACK'
//    property var selectedSeat: undefined

    property int itemSize: 50
    property int itemRadius: 15
    property int spacePerSeat: 1
    property int spacePerRow: 70
    property bool canSelect: true
    property var delimit: '#'

    property var idParent: undefined

    signal externalResetKey(string str)

    color: 'transparent'
    width: (itemSize*6) + spacePerRow + (6*spacePerSeat) + (spacePerRow-itemSize)
    height: (seat_pos=='MIDDLE') ? (itemSize+20) : (itemSize*2)+20

    Component.onCompleted: {
        externalResetKey.connect(reset_seat);
    }

    Component.onDestruction: {
        externalResetKey.disconnect(reset_seat);
    }


    Rectangle{
        id: front_rec
        color: 'darkred'
        anchors.top: parent.top
        anchors.topMargin: 0
        width: parent.width
        height: itemSize-10
        visible: (seat_pos=='FRONT') ? true : false
        Text{
            anchors.fill: parent
            text: textFront
            font.pixelSize: 30
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
        }
    }

    Rectangle{
        id: back_rec
        color: 'darkred'
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        width: parent.width
        height: itemSize-10
        visible: (seat_pos=='BACK') ? true : false
        Text{
            anchors.fill: parent
            text: textBack
            font.pixelSize: 30
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
        }
    }

    Rectangle{
        id: seat1
        y: 5
        color: get_seat_color(seat_a)
        visible: (seat_a.split(delimit)[1]!='DUMMY') ? true : false
        width: itemSize
        height: itemSize
        radius: itemRadius
        anchors.bottomMargin: (seat_pos!='BACK') ? 5 : 60
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.bottom: parent.bottom
        Text{
            anchors.fill: parent
            text: seat_a.split(delimit)[0]
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
            visible: (seat_a.split(delimit)[1]!='EMERGENCY') ? true : false
        }
        MouseArea{
            anchors.fill: parent
            enabled: (seat_a.split(delimit)[1]=='AVAILABLE' && canSelect) ? true : false
//            onClicked: sendKey(seat_a, seat1)
            onClicked: {
//                idParent.idSeat = base_rec;
                idParent.connectSeatSignal(seat_a.split(delimit)[0]);
            }
        }
    }

    Rectangle{
        id: seat2
        y: 5
        width: itemSize
        height: itemSize
        color: get_seat_color(seat_b)
        visible: (seat_b.split(delimit)[1]!='DUMMY') ? true : false
        radius: itemRadius
        anchors.left: seat1.right
        anchors.leftMargin: spacePerSeat
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (seat_pos!='BACK') ? 5 : 60
        Text{
            anchors.fill: parent
            text: seat_b.split(delimit)[0]
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
            visible: (seat_b.split(delimit)[1]!='EMERGENCY') ? true : false
        }
        MouseArea{
            anchors.fill: parent
            enabled: (seat_b.split(delimit)[1]=='AVAILABLE' && canSelect) ? true : false
//            onClicked: sendKey(seat_b, seat2)
            onClicked: {
//                idParent.idSeat = base_rec;
                idParent.connectSeatSignal(seat_b.split(delimit)[0]);
            }
        }
    }

    Rectangle{
        id: seat3
        y: 5
        width: itemSize
        height: itemSize
        color: get_seat_color(seat_c)
        visible: (seat_c.split(delimit)[1]!='DUMMY') ? true : false
        radius: itemRadius
        anchors.left: seat2.right
        anchors.leftMargin: spacePerSeat
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (seat_pos!='BACK') ? 5 : 60
        Text{
            anchors.fill: parent
            text: seat_c.split(delimit)[0]
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
            visible: (seat_c.split(delimit)[1]!='EMERGENCY') ? true : false
        }
        MouseArea{
            anchors.fill: parent
            enabled: (seat_c.split(delimit)[1]=='AVAILABLE' && canSelect) ? true : false
//            onClicked: sendKey(seat_c, seat3)
            onClicked: {
//                idParent.idSeat = base_rec;
                idParent.connectSeatSignal(seat_c.split(delimit)[0]);
            }
        }
    }

    Rectangle{
        id: seat4
        y: 5
        width: itemSize
        height: itemSize
        color: get_seat_color(seat_d)
        visible: (seat_d.split(delimit)[1]!='DUMMY') ? true : false
        radius: itemRadius
        anchors.left: seat3.right
        anchors.leftMargin: spacePerRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (seat_pos!='BACK') ? 5 : 60
        Text{
            anchors.fill: parent
            text: seat_d.split(delimit)[0]
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
            visible: (seat_d.split(delimit)[1]!='EMERGENCY') ? true : false
        }
        MouseArea{
            anchors.fill: parent
            enabled: (seat_d.split(delimit)[1]=='AVAILABLE' && canSelect) ? true : false
//            onClicked: sendKey(seat_d, seat4)
            onClicked: {
//                idParent.idSeat = base_rec;
                idParent.connectSeatSignal(seat_d.split(delimit)[0]);
            }
        }
    }

    Rectangle{
        id: seat5
        y: 5
        width: itemSize
        height: itemSize
        color: get_seat_color(seat_e)
        visible: (seat_e.split(delimit)[1]!='DUMMY') ? true : false
        radius: itemRadius
        anchors.left: seat4.right
        anchors.leftMargin: spacePerSeat
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (seat_pos!='BACK') ? 5 : 60
        Text{
            anchors.fill: parent
            text: seat_e.split(delimit)[0]
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
            visible: (seat_e.split(delimit)[1]!='EMERGENCY') ? true : false
        }
        MouseArea{
            anchors.fill: parent
            enabled: (seat_e.split(delimit)[1]=='AVAILABLE' && canSelect) ? true : false
//            onClicked: sendKey(seat_e, seat5)
            onClicked: {
//                idParent.idSeat = base_rec;
                idParent.connectSeatSignal(seat_e.split(delimit)[0]);
            }
        }
    }

    Rectangle{
        id: seat6
        y: 5
        width: itemSize
        height: itemSize
        color: get_seat_color(seat_f)
        visible: (seat_f.split(delimit)[1]!='DUMMY') ? true : false
        radius: itemRadius
        anchors.left: seat5.right
        anchors.leftMargin: spacePerSeat
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (seat_pos!='BACK') ? 5 : 60
        Text{
            anchors.fill: parent
            text: seat_f.split(delimit)[0]
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: 'white'
            visible: (seat_f.split(delimit)[1]!='EMERGENCY') ? true : false
        }
        MouseArea{
            anchors.fill: parent
            enabled: (seat_f.split(delimit)[1]=='AVAILABLE' && canSelect) ? true : false
//            onClicked: sendKey(seat_f, seat6)
            onClicked: {
//                idParent.idSeat = base_rec;
                idParent.connectSeatSignal(seat_f.split(delimit)[0]);
            }
        }
    }

    Rectangle{
        id: left_wall
        color: 'darkred'
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        height: parent.height
        width: 2
    }

    Rectangle{
        id: right_wall
        color: 'darkred'
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        height: parent.height
        width: 2
    }

    function reset_seat(e){
        console.log('[GET] External Seat Signal : ', e)
        seat1.color = get_seat_color(seat_a);
        seat2.color = get_seat_color(seat_b);
        seat3.color = get_seat_color(seat_c);
        seat4.color = get_seat_color(seat_d);
        seat5.color = get_seat_color(seat_e);
        seat6.color = get_seat_color(seat_f);
    }

    function sendKey(seat, idSeat){
        if (idParent==undefined) return;
//        console.log('Selected Seat :', seat);
//        canSelect = false;
//        idParent.selectedSeat = seat.split('#')[0];
//        idSeat.color = 'orange';
//        reset_seat(seat);
        idParent.connectSeatSignal(seat.split(delimit)[0]);
    }

    function get_seat_color(seat){
        if(seat.indexOf(idParent.selectedSeat) > -1) return 'orange';
        if(seat.split(delimit)[1]=='NOT_AVAILABLE') return 'red';
        if(seat.split(delimit)[1]=='EMERGENCY') return 'gray';
        return 'green';
    }

}

