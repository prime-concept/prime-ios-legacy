function formAction()
{
    return document.getElementById('cardentry').action;
}

function cardNumber()
{
	return document.getElementById("cardnr").value;
}

function holderName()
{
	return document.getElementById("cardname").value;
}

function expirationYear()
{
	return document.getElementById("expyear").value;
}

function expirationMonth()
{
	return document.getElementById("expmonth").value;
}

function setCardNumber(cardNumber)
{
	document.getElementById("cardnr").value = cardNumber;
}

function setHolderName(holderName)
{
	document.getElementById("cardname").value = holderName;
}

function setExpirationYear(expirationYear)
{
	document.getElementById("expyear").value = expirationYear;
	$('#year').change();
}

function setExpirationMonth(expirationMonth)
{
	document.getElementById("expmonth").value = expirationMonth;
	$('#month').change();
}