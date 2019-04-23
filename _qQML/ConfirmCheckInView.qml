import QtQuick 2.4
import QtQuick.Controls 1.2

Base{
    id:confirmation_checkin
    visible: false
    use_: 'confirmation'
    property var escapeFunction: 'closeWindow' //['closeWindow', 'backToMain', 'backToPrevious']
    property bool cancelAble: true
    property var modeLanguage: 'INA'
    property string detailEng: '
Before you proceed to confirm your itinerary, please ensure you are aware of our Conditions of Carriage before you travel with us.

WHAT MUST NOT BE TAKEN ON BOARD

It is against the law to bring into the aircraft, whether as cabin baggage or checked baggage, restricted items as defined by the Civil Aviation Safety Authority. The Company and airport or government officials may inspect and/or search your baggage with or without your presence. REMEMBER IF YOU TAKE DANGEROUS GOODS ON BOARD, EVEN INADVERTENTLY, YOU MAY BE LIABLE TO PROSECUTION AND A JAIL TERM.

1. EXPLOSIVES: fireworks, flares, toy gun caps.
2. COMPRESSED SUBSTANCE: gas cylinders, aerosols (other than medicines/toiletries).
3. FLAMMABLE SUBSTANCE: lighter fuel, paints, thinners, firelighters, cigarette lighters containing unabsorbed lighter fuel
4. OXIDIZERS: some bleaching powders, acids, chemicals.
5. ORGANIC PEROXIDES: hair or textile dyes, fibreglass repair kits, certain adhesives.
6. POISONS: arsenic, cyanide, weedkillers.
7. IRRITATING SUBSTANCES: tear gas devices such as mace, pepper sprays.
8. INFECTIOUS SUBSTANCES: biological products and/or diagnostic specimens containing pathogens.
9. RADIOACTIVE MATERIALS: medical or research samples which contain radioactive sources.
10. CORROSIVES: acids, alkalis, wet cell batteries, caustic soda, mercury.
11. MAGNETISED MATERIALS: magnetrons and anything containing strong magnets.'

    property string detailIna: '
Sebelum Anda melanjutkan untuk mengkonfirmasi jadwal Anda, pastikan Anda mengetahui Ketentuan Transportasi Kami sebelum Anda bepergian bersama kami.

APA YANG TIDAK BOLEH DIBAWA KE DALAM PESAWAT

Termasuk perbuatan melanggar hukum untuk membawa ke dalam pesawat (sebagai bawaan kabin atau bagasi), barang-barang berikut yang dibatasi sebagaimana ditentukan oleh Otoritas Keselamatan Penerbangan Sipil. Perusahaan dan bandara atau pejabat pemerintah dapat memeriksa dan / atau mencari bagasi Anda dengan atau tanpa kehadiran Anda. INGATLAH JIKA ANDA MEMBAWA BARANG BERBAHAYA KE DALAM PESAWAT, WALAUPUN KARENA KECEROBOHAN, ANDA AKAN DITUNTUT ATAUPUN DIHUKUM KURUNGAN PENJARA.

1. BAHAN LEDAKAN: kembang api, suar, topi senjata mainan.
2. BAHAN BERTEKANAN TINGGI: tabung gas, aerosol (selain obat / perlengkapan mandi).
3. PEMANTIK API: bahan bakar lebih ringan, cat, thinner, firelighters, pemantik rokok mengandung bahan bakar ringan yang tidak diserap
4. BAHAN KIMIA SAM TINGGI: beberapa bubuk pemutih, asam, bahan kimia.
5. ORGANIK PEROKSIDA: pewarna rambut atau tekstil, kit perbaikan fiberglass, perekat tertentu.
6. RACUN: arsenik, sianida, weedkillers.
7. BAHAN PENYEBAB IRITASI: gas air mata seperti gada, semprotan lada.
8. BAHAN PENYEBAB INFEKSI: produk biologi dan / atau spesimen diagnostik yang mengandung patogen.
9. MATERIAL RADIOAKTIF: sampel medis atau penelitian yang mengandung sumber radioaktif.
10. BAHAN KOROSIF: asam, alkali, baterai sel basah, soda kaustik, merkuri.
11. BAHAN MAGNETIS: magnetron dan apa pun yang mengandung magnet kuat.'

    property string mainTitleEng: 'DECLARATION AND CONFIRMATION'
    property string mainTitleIna: 'PERNYATAAN DAN KONFIRMASI'

    Rectangle{
        id: base_overlay
        anchors.fill: parent
        color: "gray"
        opacity: 0.6
    }
    Rectangle{
        id: notif_rec
        width: parent.width - 100
        height: parent.height - 100
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
//        Image  {
//            id: image
//            anchors.fill: parent
//            opacity: 0.2
//            source: 'aAsset/Which_Way.jpg'
//            fillMode: Image.Stretch
//        }
        Text {
            id: main_text
            color: "darkred"
            text: (modeLanguage=='INA') ? mainTitleIna : mainTitleEng
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenterOffset: 5
            font.family:"Microsoft YaHei"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
        }

        ScrollBarVertical{
            id: vertical_sbar
            flickable: text_box
            height: text_box.height
            color: "gray"
            expandedWidth: 15
        }

        Flickable{
            id: text_box
            width: 1100
            height: 680
            //            clip: true
            interactive: true
            flickDeceleration: 750
            maximumFlickVelocity: 1500
            boundsBehavior: Flickable.StopAtBounds
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            contentHeight: detail_text.height
            contentWidth: detail_text.width
            flickableDirection: Flickable.VerticalFlick
            clip: true
            focus: true
            Text {
                id: detail_text
                width: 1100
                color: "darkred"
                text: (modeLanguage=='INA') ? detailIna : detailEng
                height: 1000
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                //                font.bold: true
                font.family:"Microsoft YaHei"
                font.pixelSize: 25
            }
        }
        GroupBox{
            id: groupBox1
            flat: true
            x: 200
            y: 472
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            ConfirmButton{
                id: cancel_button
                visible: cancelAble
                width: 190
                anchors.left: parent.left
                anchors.leftMargin: 300
                text_: (modeLanguage=='INA') ? 'TIDAK SETUJU' : 'DISAGREE'
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        switch(escapeFunction){
                        case 'backToMain' : my_layer.pop(my_layer.find(function(item){if(item.Stack.index===0)return true}));
                            break;
                        case 'backToPrevious' : my_layer.pop();
                            break;
                        default: close();
                            break;
                        }
                    }
                }
            }
            ConfirmButton{
                id: ok_button
                width: 190
                anchors.right: parent.right
                anchors.rightMargin: 300
                text_: (modeLanguage=='INA') ? 'SETUJU' : 'AGREE'
            }
        }

//        MouseArea{
//            id: ok_confirm_view
//            x: 682; y:819
//            width: 190; height: 50;
//            onClicked: {
//                loading_view.show_text = (language=='INA') ? 'Memesan Kursi Anda...' : 'Reserving Your Seat...';
//                loading_view.open();
//                var param = JSON.stringify({'seat_no': selectedSeat});
//                console.log('Selected Seat : ', param);
//                _SLOT.start_get_boarding_pass(param);
//            }
//        }
    }

    function open(){
        confirmation_checkin.visible = true
    }

    function close(){
        confirmation_checkin.visible = false
    }
}
