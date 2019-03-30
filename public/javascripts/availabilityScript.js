function check(event) {
	// Get Values
	var start  = $('#datepicker6').data("DatePicker").date();
	var end  = $('#datepicker7').data("DatePicker").date();
	
	// Simple Check
	if(!start) {
		alert("You must select a start date");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(!end) {
		alert("You must select an end date");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}