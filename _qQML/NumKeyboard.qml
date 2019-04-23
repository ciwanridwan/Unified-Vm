import QtQuick 2.4
import QtQuick.Controls 1.2

Rectangle{
    id:full_numpad
    width:268
    height:358
    color:"transparent"
    signal strButtonClick(string str)
    signal funcButtonClicked(string str)


    NumButton{
        x:0
        y:0
        show_text:"1"
    }
    NumButton{
        x:90
        y:0
        show_text:"2"
    }
    NumButton{
        x:180
        y:0
        show_text:"3"
    }
    NumButton{
        x:0
        y:90
        show_text:"4"
    }
    NumButton{
        x:90
        y:90
        show_text:"5"
    }
    NumButton{
        x:180
        y:90
        show_text:"6"
    }
    NumButton{
        x:0
        y:180
        show_text:"7"
    }
    NumButton{
        x:90
        y:180
        show_text:"8"
    }
    NumButton{
        x:180
        y:180
        show_text:"9"
    }
    NumButton{
        x:90
        y:270
        show_text:"0"
    }
    NumboardClear{
        x:0
        y:270
        color: "#5a5a5a"
        border.width: 0
        slot_text:"Clear"
    }
    NumboardBack{
        x:180
        y:270
        color: "#ffc125"
        border.width: 0
        slot_text: "Back"
    }
}
