import QtQuick 2.4
import QtQuick.Controls 1.2
import "screen.js" as SCREEN


Rectangle {
    id:base
    width: parseInt(SCREEN.size.width)
    height: parseInt(SCREEN.size.height)
    color: 'transparent'
    property var top_color: "#f03838"
    property var language: "INA"
    property var globalBoxName: 'VM01 - Box Name'
    property bool mediaOnPlaying: false

    //==================================================================================================//
    signal result_get_file_list(string str)
    signal result_get_gui_version(string str)
    signal result_get_kiosk_name(string str)
    signal result_set_plan(string str)
    signal result_create_schedule(string str)
    signal result_create_chart(string str)
    signal result_post_person(string str)
    signal result_create_booking(string str)
    signal result_create_payment(string str)
    signal result_create_print(string str)
    signal result_clear_person(string str)
    signal result_sale_edc(string str)
    signal result_get_device(string str)
    signal result_confirm_schedule(string str)
    signal result_accept_mei(string str)
    signal result_dis_accept_mei(string str)
    signal result_stack_mei(string str)
    signal result_return_mei(string str)
    signal result_store_es_mei(string str)
    signal result_return_es_mei(string str)
    signal result_dispense_cou_mei(string str)
    signal result_float_down_cou_mei(string str)
    signal result_dispense_val_mei(string str)
    signal result_float_down_all_mei(string str)
    signal result_return_status(string str)
    signal result_init_qprox(string str)
    signal result_debit_qprox(string str)
    signal result_auth_qprox(string str)
    signal result_balance_qprox(string str)
    signal result_topup_qprox(string str)
    signal result_ka_info_qprox(string str)
    signal result_online_info_qprox(string str)
    signal result_init_online_qprox(string str)
    signal result_stop_qprox(string str)
    signal result_airport_name(string str)
    signal result_generate_pdf(string str)
    signal result_general(string str)
    signal result_passenger(string str)
    signal result_flight_data_sorted(string str)
    signal result_kiosk_status(string str)
    signal result_price_setting(string str)
    signal result_collect_cash(string str)
    signal result_list_cash(string str)
    signal result_booking_search(string str)
    signal result_reprint(string str)
    signal result_recreate_payment(string str)
    signal result_get_settlement(string str)
    signal result_print_global(string str)
    signal result_process_settlement(string str)
    signal result_void_settlement(string str)
    signal result_check_booking_code(string str)
    signal result_get_boarding_pass(string str)
    signal result_print_boarding_pass(string str)
    signal result_admin_key(string str)
    signal result_wallet_check(string str)
    signal result_cd_hold(string str)
    signal result_cd_move(string str)
    signal result_cd_stop(string str)
    signal result_product_stock(string str)
    signal result_store_transaction(string str)
    signal result_topup_amount(string str)
    signal result_topup_readiness(string str)
    signal result_sale_print(string str)
    signal result_multiple_eject(string str)
    signal result_store_topup(string str)
    signal result_user_login(string str)
    signal result_kiosk_admin_summary(string str)
    signal result_change_stock(string str)
    signal result_grg_status(string str)
    signal result_grg_receive(string str)
    signal result_grg_stop(string str)
    signal result_do_topup_bni(string str)
    signal result_admin_print(string str)
    signal result_reprint_global(string str)
    signal result_init_grg(string str)
    signal result_activation_bni(string str)
    signal result_cd_readiness(string str)
    signal result_mandiri_settlement(string str)
    signal result_update_app(string str)
    signal result_get_ppob_product(string str)
    signal result_get_payment_method(string str)
    signal result_sync_ads(string str)
    signal result_check_ppob(string str)
    signal result_trx_ppob(string str)
    signal result_check_trx(string str)
    signal result_get_qr(string str)
    signal result_pay_qr(string str)
    signal result_check_qr(string str)
    signal result_confirm_qr(string str)


    //==================================================================================================//

    StackView {
        id: my_layer
        anchors.fill: base
        initialItem: home_page

        delegate: StackViewDelegate {
            function transitionFinished(properties)
            {
                properties.exitItem.opacity = 1.0
            }

            pushTransition: StackViewTransition {
                PropertyAnimation {
                    target: enterItem
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                }
                PropertyAnimation {
                    target: exitItem
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                }
            }
        }
    }

    Component{id: admin_manage
        AdministratorPage{}
    }


    Component{id: admin_login
        AdministratorLogin{}
    }

    Component{id: topup_prepaid_denom
        PrepaidTopupDenom{}
    }

    Component{id: process_shop
        ProcessShop{}
    }

    Component{id: select_prepaid_provider
        SelectPrepaidProvider{}
    }

    Component{id: shop_prepaid_card
        ShopPrepaidCard{}
    }

    Component{id: check_balance
        CheckPrepaidBalance{}
    }


    Component{id: checkin_success
        CheckInSuccess{}
    }

    Component{id: select_seat
        SelectSeatView{}
    }

    Component{id: checkin_page
        CheckInPage{}
    }

    Component{id: backdooor_login
        BackDoorLogin{}
    }

    Component{id: test_payment_page
        TestPaymentPage{}
    }

    Component {id: home_page
        HomePage{}  
    }

    Component {id: home_page_event
        HomePageEvent{}
    }

    Component {id: media_page
        MediaPage{}
    }

    Component {id: coming_soon
        ComingSoon{}
    }

//    Component {id: buy_ticket
//        BuyTicketWebPage{}
//    }

    Component {id: select_ticket
        SelectTicketView{}
    }

    Component {id: select_plan
        SelectPlanView{}
    }

    Component {id: input_number
        InputGeneralNumber{}
    }

    Component {id: input_details
        InputDetails{}
    }

    Component {id: select_payment
        SelectPayment{}
    }

    Component {id: loading_view
        LoadingView{}
    }

    Component {id: global_web_view
        GlobalWebView{}
    }

    Component {id: faq_ina
        FAQPageINA{}
    }

    Component {id: faq_en
        FAQPageEN{}
    }

    Component {id: test_view
        GeneralTemplate{}
    }

    Component {id: reprint_view
        ReprintPage{}
    }

    Component {id: reprint_detail_view
        ReprintDetailPage{}
    }

    Component {id: home_page_tj
        HomePageTJ{}
    }

    Component {id: mandiri_shop_card
        MandiriShopCard{}
    }

    Component {id: mandiri_payment_process
        MandiriPaymentProcess{}
    }

    Component {id: ppob_category
        PPOBCategoryPage{}
    }

    Component {id: ppob_product
        PPOBProductPage{}
    }

    Component {id: global_input_number
        GlobalInputNumber{}
    }

//    Component {id: global_confirm_frame
//        GlobalConfirmationFrame
//    }

}




