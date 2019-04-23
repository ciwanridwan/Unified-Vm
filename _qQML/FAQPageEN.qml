import QtQuick 2.4
import QtQuick.Controls 1.3
import "base_function.js" as FUNC

Base{
    id: base_page
    mode_: "reverse"
    isPanelActive: true
    textPanel: "Frequently Asked Questions"
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
                spacing: 5

                //==========================
                TextTemplate{
                    content: "1. What is the usage of this machine ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "This machine is used to buy flight ticket from Lion Air/Wings Air/Batik Air in self service.";
                }
                //==========================
                TextTemplate{
                    content: "2. Can this machine be able to receive cash and card payment ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Yes, This machine can be able to receive cash with its Bill Acceptor, Unfortunately it cannot return any excess cash, but You still be able to cancel it when confirming. Please prepare the exact cash as per the ticket price.";
                }
                TextTemplate{
                    content: "This time card payment is not available yet, It is being activated and be able to used shortly.";
                }
                //==========================
                TextTemplate{
                    content: "3. Can this machine ticket be used for Check-In ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Yes, The output ticket from this machine will be received in the Check-In counter at the airport.";
                }
                //==========================
                TextTemplate{
                    content: "4. Can I purchase Round-trip ticket ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Yes, This machine can provide round-trip ticket purchase with one single booking code, one print out ticket flight with two flight data.";
                }
                //==========================
                TextTemplate{
                    content: "5. How many notes can be received in one transaction ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "The maximum bill-note per transaction is 55 notes on each transaction, if the transaction is above 4 million IDR, Strongly suggested to use the biggest note such 100.000 to avoid any lack of amount.";
                }
                TextTemplate{
                    content: "Kindly use biggest note to avoid the maximum note limit on each transaction.";
                }
                //==========================
                TextTemplate{
                    content: "6. If I cancel the ticket purchase once the money enterred, Can it be returned automatically ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Once You have enterred any bill-note and You wish to cancel the transaction, This machine will return all the bill-notes as per the amount You have enterred.";
                }
                //==========================
                TextTemplate{
                    content: "7. How many timeout time per transaction ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "Timeout time per transaction (started from select flight schedule) in one transaction is 10 minutes. In case it is expired, So the transaction will auto-cancel and all the enterred bill-notes will be returned.";
                }
                //==========================
                TextTemplate{
                    content: "8. For further information or any disruption, where I can contact ?";
                    style: "Header";
                }
                TextTemplate{
                    content: "You can contact our Customer Service in 021 - 6379 8000 or WhatsApp 081286365322 for futher information or any disruption appear when using this machine.";
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

