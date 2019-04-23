import QtQuick 2.4

Item {
    id: container;
    property string style;
    property real topwidth: 850;
    property real globalHeight;
    property real leftPadding: 70;
    property string content: "Sample text";
    property color paint: "darkred";
    property real fontsize: (style=="Header") ? 18 : 15;
    property bool fontbold: (style=="Header") ? true : false;

    x: (style=="Header") ? 30 : leftPadding;
    height: (style=="container") ? globalHeight : template.height + 5;
    width: topwidth;

 Text {
     id:template;
     width: (style=="Header") ? 500 : topwidth;
     color:paint;
     font.pointSize: fontsize;
     font.bold: fontbold;
     font.family: "Microsoft YaHei";
     wrapMode: Text.WrapAtWordBoundaryOrAnywhere;
     text:content;
     }
}
