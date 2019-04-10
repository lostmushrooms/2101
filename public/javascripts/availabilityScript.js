function check(event) {
	// Get Values
	var start  = $('#datetimepicker6').data("DateTimePicker").date();
	var end  = $('#datetimepicker7').data("DateTimePicker").date();
	
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
	if(start > end) {
		alert("You must select a valid date range");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}