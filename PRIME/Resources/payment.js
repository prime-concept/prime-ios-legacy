function getElById(id)
{
    return document.getElementById(id);
}

function getElByNm(name)
{
    var nl = document.getElementsByName(name);
    if (nl.length > 0) {
        return nl[0];
    }
    return null;
}

function isValidSberbankForm()
{
    if (
        !getElByNm('PaymentForm') ||
        !getElById('formPayment') ||
        !getElByNm('1PAN') ||
        !getElById('iPAN') ||
        !getElById('iPAN_sub') ||
        !getElByNm('MM') ||
        !getElById('month') ||
        !getElByNm('YYYY') ||
        !getElById('year') ||
        !getElByNm('TEXT') ||
        !getElById('iTEXT') ||
        !getElByNm('$CVC') ||
        !getElById('iCVC') ||
        !getElByNm('SendPayment2') ||
        !getElById('buttonPayment')
        ) return false;
    return true;
}

function isValidRuruForm()
{
    if (
        !getElById('form-payment') ||
        !getElByNm('pan_mko1') ||
        !getElByNm('pan_mko2') ||
        !getElByNm('pan_mko3') ||
        !getElByNm('pan_mko4') ||
        !getElByNm('exp_mko1') ||
        !getElByNm('exp_mko2') ||
        !getElByNm('cardholder_mko') ||
        !getElByNm('cvc_mko') ||
        !getElByNm('user_agreement') ||
        !getElById('payment_submit')
        ) return false;
    return true;
}

function isValidAlfabankForm()
{
    if (
        !getElByNm('PaymentForm') ||
        !getElById('formPayment') ||
        !getElByNm('$PAN') ||
        !getElById('iPAN') ||
        !getElById('pan_visible') ||
        !getElByNm('MM') ||
        !getElById('month') ||
        !getElByNm('YYYY') ||
        !getElById('year') ||
        !getElByNm('TEXT') ||
        !getElById('iTEXT') ||
        !getElByNm('$CVC') ||
        !getElById('iCVC') ||
        !getElById('buttonPayment')
        ) return false;
    return true;
}

function isValidRsbForm()
{
    if(
       !getElById('cardentry') ||
       !getElByNm('trans_id') ||
       !getElById('cardnr') ||
       !getElByNm('cardnr') ||
       !getElById('cvc2') ||
       !getElByNm('cvc2') ||
       !getElById('expmonth') ||
       !getElByNm('validMONTH') ||
       !getElById('expyear') ||
       !getElByNm('validYEAR') ||
       !getElById('cardname') ||
       !getElByNm('cardname') ||
       !getElByNm('sendPayment') ||
       !getElById('buttonPayment')
       ) return false;
    return true;
}

function isValidSberbankKnhdForm()
{
    if(
       !getElById('insert_number') ||
       !getElById('insert_srokM')||
       !getElById('insert_srokY')||
       !getElById('insert_kod_cvc')
       ) return false;
    return true;
}
