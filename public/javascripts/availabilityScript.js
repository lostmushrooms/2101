function check(event) {
	// Get Values
	var start  = $('#datetimepicker6').data("DateTimePicker").date().toDate().setHours(0,0,0);
	start = Math.floor(start/1000)*1000;
	var end  = $('#datetimepicker7').data("DateTimePicker").date().toDate().setHours(0,0,0);
	end = Math.floor(end/1000)*1000;
	
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