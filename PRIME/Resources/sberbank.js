function formAction()
{
    return document.getElementById('formPayment').action;
}

function cardNumber()
{
	return document.getElementById("iPAN").value;
}

function holderName()
{
	return document.getElementById("iTEXT").value;
}

function expirationYear()
{
	return document.getElementById("year").value;
}

function expirationMonth()
{
	return document.getElementById("month").value;
}

function setCardNumber(cardNumber)
{
	document.getElementById("iPAN").value = cardNumber;
	document.getElementById("iPAN_sub").value = cardNumber;
}

function setHolderName(holderName)
{
	document.getElementById("iTEXT").value = holderName;
}

function setExpirationYear(expirationYear)
{
	document.getElementById("year").value = expirationYear;
	$('#year').change();
}

function setExpirationMonth(expirationMonth)
{
	document.getElementById("month").value = expirationMonth;
	$('#month').change();
}