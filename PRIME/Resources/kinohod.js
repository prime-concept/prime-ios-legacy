function setEmail(email)
{
    document.getElementById("email").value=email;
}

function setCardNumber(cardNumber)
{
    document.getElementById("insert_number").value = cardNumber;
}

function setExpirationYear(expirationYear)
{
    document.getElementById("insert_srokY").value = expirationYear.substring(2);
}

function setExpirationMonth(expirationMonth)
{
    document.getElementById("insert_srokM").value = expirationMonth;
}