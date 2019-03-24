function check(event) {
	// Get Values
	var userName  = document.getElementById('userName').value;
	var email  = document.getElementById('email').value;
	var password   = document.getElementById('password').value;
	var phoneNumber = document.getElementById('phoneNumber').value;

	// Simple Check
	if(userName.length <=3) {
		alert("Please set a longer user name");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(password.length < 9) {
		alert("Password should include 9 or more characters");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(phoneNumber.length != 8) {
		alert("Invalid invalid phone number");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}