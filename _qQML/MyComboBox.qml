import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

IComboBox {
    id: root
    width: 200
    height: 50

    property int m_userLevel: 1
    comboBoxModel: ListModel {
        id: cbItems
        ListElement { text: "1" }
        ListElement { text: "2" }
        ListElement { text: "3" }
        ListElement { text: "4" }
    }


    Component {
        id: comboBoxStyleBackground
//        IUserLevelImage {
//            anchors.fill: parent
//            userLevel: m_userLevel
//        }
    }


    Component {
        id: dropDownMenuStyleFrame
//        IUserLevelImage1 {
//        }
    }
    onIndexChanged: {
        m_userLevel = currentIndex + 1
    }
    Component.onCompleted: {
        setComboBoxStyleBackground(comboBoxStyleBackground)
        setDropDownMenuStyleFrame(dropDownMenuStyleFrame)
    }
}
