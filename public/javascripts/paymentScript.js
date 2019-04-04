function check(event) {
	// Get Values
	var comment  = document.getElementById('ocomment').value;
	var rating  = document.getElementById('ctRating').value;
	
	// Simple Check
	if(!rating || rating == null || rating.length == 0) {
		alert("Please give a rating to the caretaker");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(ocomment.length > 2000) {
		alert("Please write a shorter comment");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}