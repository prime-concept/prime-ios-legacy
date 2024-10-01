function formAction()
{
    return document.getElementById('form-payment').action;
}

function cardNumber()
{
	return document.getElementsByName("pan_mko1")[0].value+document.getElementsByName("pan_mko2")[0].value+document.getElementsByName("pan_mko3")[0].value+document.getElementsByName("pan_mko4")[0].value;
}

function holderName()
{
	return document.getElementsByName("cardholder_mko")[0].value;
}

function expirationYear()
{
	return document.getElementsByName("exp_mko2")[0].value;
}

function expirationMonth()
{
	return document.getElementsByName("exp_mko1")[0].value;
}

function setCardNumber(cardNumber)
{
	document.getElementsByName("pan_mko1")[0].value = cardNumber.substring(0,4);
	document.getElementsByName("pan_mko2")[0].value = cardNumber.substring(4,8);
	document.getElementsByName("pan_mko3")[0].value = cardNumber.substring(8,12);
	document.getElementsByName("pan_mko4")[0].value = cardNumber.substring(12,16);
}

function setHolderName(holderName)
{
	document.getElementsByName("cardholder_mko")[0].value = holderName;
}

function setExpirationYear(expirationYear)
{
	document.getElementsByName("exp_mko2")[0].value = expirationYear;
}

function setExpirationMonth(expirationMonth)
{
	document.getElementsByName("exp_mko1")[0].value = expirationMonth;
}