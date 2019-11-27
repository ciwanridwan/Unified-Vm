import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import "base_function.js" as FUNC

Rectangle{
    property var language_ : base.language
    property var mode_: "adt"
    color: "white"
    radius: 1
    width: 280
    height: 100
    Image{
        id: img_button
        x: 8
        y: 13
        height: 75
        width: 75
        source: FUNC.get_source_image(mode_)
        //        source: "source/adult.png"
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: text_button
        font.family:"Ubuntu"
        color: "gray"
        text: FUNC.get_text_type(mode_, language_)
//        text: "Adult (Above 12 Years)"
        font.italic: true
        anchors.verticalCenterOffset: 34
        anchors.horizontalCenterOffset: 44
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
        font.pixelSize: 11
    }

    Image{
        x: 95
        y: 19
        width: 50
        height: 50
        source: "source/minus_circle.png"
        fillMode: Image.Stretch
        opacity: 0.7

    }
    Image{
        x: 222
        y: 19
        width: 50
        height: 50
        source: "source/plus_circle.png"
        fillMode: Image.Stretch
        opacity: 0.7

    }

}
