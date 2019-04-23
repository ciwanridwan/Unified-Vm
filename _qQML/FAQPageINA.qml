import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: base_page
    mode_: "reverse"
    isPanelActive: true
    textPanel: "Pertanyaan Umum"
    property int timer_value: 60

    Stack.onStatusChanged:{
        if(Stack.status==Stack.Activating){
            abc.counter = timer_value
            my_timer.start()

        }
        if(Stack.status==Stack.Deactivating){
            my_timer.stop()
            loading_view.close()
        }
    }

    Component.onCompleted:{
    }

    Component.onDestruction:{
    }

    Rectangle{
        id: rec_timer
        width:10
        height:10
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
                abc.counter -= 1
                if(abc.counter < 0){
                    my_timer.stop()
                    my_layer.pop(my_layer.find(function(item){if(item.Stack.index === 0) return true }))
                }
            }
        }
    }

    BackButton{
        id:back_button
        x: 100 ;y: 40;
        MouseArea{
            anchors.fill: parent
            onClicked: {
                my_layer.pop()
            }
        }
    }

    //==============================================================
    //PUT MAIN COMPONENT HERE

    Item{
        id: container
        width: 980
        height: 600
        anchors.top: parent.top
        anchors.topMargin: 125
        anchors.left: parent.left
        anchors.leftMargin: 300
        focus: true

        ScrollBarVertical{
            id: vertical_sbar
            y: 0
            x: container.width + 75
            flickable: contents
            height: container.height
            color: "gray"
            expandedWidth: 18
        }

        Flickable{
            id: contents
            x: 0
            y: 0
            width: 940
            height: 900
            interactive: true
            flickDeceleration: 750
            maximumFlickVelocity: 1500
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: rows_group.height
            contentWidth: rows_group.width
            clip: true
            focus: true

            Column{
                id: rows_group
                width: 900
                spacing: 5

                //==========================
                TextTemplate{
                    content: "1. Apa kegunaan dari mesin ini ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Mesin ini untuk pembelian tiket pesawat Lion Air/Wings Air/Batik Air secara mandiri (Self Service).";
                }
                //==========================
                TextTemplate{
                    content: "2. Apakah Mesin ini bisa menerima uang Tunai dan Kartu ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Ya, Mesin ini bisa menerima Uang Tunai yang dimasukkan ke dalam Bill Acceptor, tetapi mesin ini tidak bisa mengembalikan kelebihan uang, dan bisa membatalkan pembayaran jika Anda memasukkan kelebihan uang, siapkan Uang yang sesuai dengan harga pesawat.";
                }
                TextTemplate{
                    content: "Saat ini pembayaran menggunakan kartu Debit/Kredit belum bisa dilakukan, karena sedang dalam proses pengaktifkan, dan akan dapat digunakan dalam waktu dekat.";
                }
                //==========================
                TextTemplate{
                    content: "3. Apakah tiket bisa digunakan untuk Check-In ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Tiket yang dikeluarkan dari mesin ini, langsung dapat digunakan untuk Check-In di counter yang tersedia dalam bandara.";
                }
                //==========================
                TextTemplate{
                    content: "4. Apakah saya dapat membeli tiket bolak-balik (Return/PP) ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Ya, Mesin ini dapat melakukan transaksi tiket Bolak-balik dengan satu kode booking, satu tiket dengan dua data penerbangan.";
                }
                //==========================
                TextTemplate{
                    content: "5. Berapa maksimum jumlah lembar yang bisa digunakan dalam sekali transaksi ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Jumlah lembar yang bisa digunakan dalam satu kali transaksi adalah 55 lembar, jika nominal tiket Anda di atas 4 juta rupiah, disarankan untuk menggunakan pecahan 100 ribu rupiah untuk menghindari kekurangan uang.";
                }
                TextTemplate{
                    content: "Usahakan gunakan pecahan besar agar menghindari maksimal jumlah lembar yang bisa diterima dalam satu transaksi.";
                }
                //==========================
                TextTemplate{
                    content: "6. Jika Saya batal membeli tiket, Apakah uang bisa keluar secara otomatis ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Jika Anda sudah memasukkan uang, dan dibatalkan atau di pilih Batal pada saat konfirmasi, maka uang akan dikeluarkan secara otomatis sebanyak uang yang Anda masukkan sebelumnya.";
                }
                //==========================
                TextTemplate{
                    content: "7. Apakah ada batas Waktu Transaksi dari mulai pemilihan penerbangan ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Batas Waktu (Timeout) dalam satu transaksi adalah sebanyak 10 menit, jika melewati batas timeout, maka transaksi akan dibatalkan dan uang akan dikeluarkan sebanyak uang yang dimasukkan.";
                }
                //==========================
                TextTemplate{
                    content: "8. Jika ada pertanyaan atau informasi gangguan, bisa menghubungi siapa ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Untuk Informasi pertanyaan dan gangguan, bisa menghubungi 021 - 6379 8000 atau via WhatsApp 081286365322.";
                }
                //==========================
                TextTemplate{
                    content: " ";
                }
                //==========================

                }
            }
    }






    //==============================================================

    ConfirmView{
        id: confirm_view
        show_text: "Dear Customer"
        show_detail: "Proceed This ?."
        z: 99
        MouseArea{
            id: ok_confirm_view
            x: 668; y:691
            width: 190; height: 50;
            onClicked: {
            }
        }
    }

    NotifView{
        id: notif_view
        isSuccess: false
        show_text: "Dear Customer"
        show_detail: "Please Ensure You have set Your plan correctly."
        z: 99
    }

    LoadingView{
        id:loading_view
        z: 99
        show_text: "Finding Flight..."
    }




}

