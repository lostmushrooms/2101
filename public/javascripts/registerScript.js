function check(event) {
	// Get Values
	var userName  = document.getElementById('username').value;
	var email  = document.getElementById('email').value;
	var password   = document.getElementById('password').value;
	var phoneNumber = document.getElementById('phoneNumber').value;
	var userType = document.getElementById('petOwnerRadio').checked || document.getElementById('careTakerRadio').checked;
	
	// Simple Check
	if(userName.length <=3) {
		alert("User name must have more than 3 characters");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(password.length < 8) {
		alert("Password should include 8 or more characters");
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
	if(!userType) {
		alert("You must select an user type");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}