    function replace_non_char(t){
    if(t !== undefined){
        var newstrT="";
        newstrT = t.replace(/[^A-Za-z]/g, "")
        return newstrT;
    }else{
        return t;
    }
}

function insert_dot(a){
    if(a !== undefined){
        var newstrA="";
        newstrA = a.replace(/(\d{1,3})(?=(?:\d{3})+(?!\d))/g,'$1.');
        return newstrA;
    }else{
        return a;
    }
}

function replace_non_number(n){
    if(n !== undefined){
        var newstrN="";
        newstrN = n.replace(/[^0-9]/g, "")
        return newstrN;
    }else{
        return n;
    }
}

function validate_email(e){
    var re = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()\.,;\s@\"]+\.{0,1})+[^<>()\.,;:\s@\"]{2,})$/;
    return re.test(e);
}

function get_source_image(s){
    if(s===undefined) return s
    if(s==='inf'){
        return "source/infant2.png";
    } else if(s==='cnn'){
        return "source/child2.png";
    } else{
        return "source/adult2.png";
    }
}

function get_text_type(t, l){
    if(t===undefined) return t
    if(t==='inf'){
        if (l=='INA') {
            return "Bayi (di bawah 2 tahun)";
        } else {
            return "Infant (Below 2 Years)";
        }
    } else if(t==='cnn'){
        if (l=='INA'){
            return "Anak Kecil (di bawah 12 tahun)";
        }else{
            return "Child (Below 12 Years)";
        }
    } else{
        if (l=='INA'){
            return "Dewasa (di atas 12 tahun)";
        }else{
            return "Adult (Above 12 Years)";
        }
    }
}

function get_color(m){
    if (m==="eco"){
        return "green";
    } else if (m==="promo"){
        return "red";
    } else {
        return "blue";
    }
}

function get_total_price(p, l){
    var price = parseInt(p);
    var big = 0;
    var small = 0;
    for (var i in l){
        if(i!=="inf"){
            big += 1;
        } else {
            small += 1;
        }
    }
    var total = (price * big) + (price * small);
    return total;
}

function get_index_value(o, i){
    var value_ = o[i];
    return value_;
}

function translate_index_text(i, l){
    if(i=="adt"){
        if (l=='INA') {
            return "Dewasa";
        } else {
            return "Adult";
        }
    } else if(i=="cnn"){
        if (l=='INA'){
            return "Anak Kecil";
        } else {
            return "Child";
        }
    } else if(i=="inf"){
        if (l=='INA'){
            return "Anak Bayi";
        } else {
            return "Infant";
        }
    }
}

function get_flight_logo(f){
    if(f.indexOf('JT') > -1){
        return "source/lion_air_logo.jpg";
    }else if(f.indexOf('ID') > -1){
        return "source/batik_air_logo.jpg";
    }else if(f.indexOf('IW') > -1){
        return "source/wings_air_logo.png";
    }else if(f.indexOf('SL') > -1){
        return "source/thai_lion_logo.png";
    }else if(f.indexOf('OD') > -1){
        return "source/malindo_air_logo.png";
    }
}

function get_plane_image(s){
    if(s=='DEPARTURE'){
        return "source/departure.png";
    } else {
        return "source/returning.png";
    }
}

function get_plane_image_tiny(s){
    if(s=='DEPARTURE'){
        return "source/departure_h50.png";
    } else {
        return "source/returning_h50.png";
    }
}

function clean_up_text(t){
    return t.replace('OK|', '').replace('?', ' - ');
}

function get_payment_text(m, l){
    if (m=="EDC"){
        if (l=='INA'){
            return "Silakan masukkan kartu pada slot dan masukkan kode PIN untuk melanjutkan.";
        } else {
            return "Please insert your card into the reader, Key in your PIN code to proceed payment.";
        }
    }else if (m=="MEI"){
        if (l=='INA'){
            return "Silakan masukkan uang kertas pada slot, Pastikan tidak basah dan tidak terlipat.";
        } else {
            return "Please insert your cash into the cash slot below, Kindly ensure it is clean and not folded.";
        }
    }else if(m=="QPROX"){
        if (l=='INA'){
            return "Silakan tempelkan kartu prabayar Anda, Pastikan saldo Anda mencukupi untuk transaksi."
        } else {
            return "Please tap your prepaid card into the reader below, Ensure your balance is sufficient.";
        }
    }else {
        if (l=='INA'){
            return "Tidak ada metode bayar terpilih."
        } else {
            return "No Method Selected";
        }
    }
}

function round_fare(f, n){
    if (n==undefined || n==null) n = 3;
    var x_f = (n/100) * parseInt(f);
    var r_f = (parseInt(f)+x_f)%10000;
    var res = 0;
    if(r_f!=0){
        res = x_f + (10000 - r_f);
    } else {
        res = x_f + 10000;
    }
    return parseInt(f) + parseInt(res);
}

/*
def rounding_price(f, n=3):
    x_f = (n/100) * int(f)
    r_f = (int(f) + x_f) % 10000
    if r_f != 0:
        x_f_ = x_f + (10000 - r_f)
    else:
        x_f_ = x_f + 10000
    return int(f) + int(x_f_)
*/

function get_diff(a, b){
    var diff = parseInt(a) - parseInt(b);
    return Math.abs(diff).toString();
}

function get_ticket_color(t, o){
    if (t==1) return "#cbd2db";
    if (o!=1) return "silver";
    return "white";
}

function get_ticket_height(t){
    if (t==1) return 190;
    return 100;
}

function change_renaming(t){
    if (t==undefined) return ''
    var new_t = t.split(' - ')
    return new_t[0] + " (" + new_t[1] + ")"
}

function serialize_text(strA, strB, len){
    var m = parseInt(len) - (strA.length + strB.length);
    var space = '';
    for (var i = 0; i < m; i++) {
        space += ' ';
    }
    return strA + ' : ' +  strB + space + '\n';
}

function insert_space_four(str){
    return str.replace(/[^\dA-Z]/g, '').replace(/(.{4})/g, '$1   ');
}

function strip(str){
    return str.split(' ').join('');
}

function get_value(v){
    if (v==undefined) return '';
    return v;
}

function count_size(obj){
    var count = 0;
    for (var i in obj) {
       if (obj.hasOwnProperty(i)) count++;
    }
    return count;
}

function convert_obj(obj){
    var newObj = {};
    for (var i in obj) {
       if (obj.hasOwnProperty(i)) newObj[i] = obj[i];
    }
    return newObj;
}

function empty(s){
    return (s.length == 0 || parseInt(s) == 0);
}

function divide_thousand(n){
    return parseInt(n)/1000;
}


