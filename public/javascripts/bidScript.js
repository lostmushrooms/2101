function check(event) {
	// Get Values
	var start  = $('#datetimepicker6').data("DateTimePicker").date();
	var end  = $('#datetimepicker7').data("DateTimePicker").date();
	var ctstart  = new Date(document.getElementById('ctstart').value);
	var ctend  = new Date(document.getElementById('ctend').value);
	var price   = document.getElementById('price').value;
	
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
		alert("Start date should be earlier then end date");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(ctstart > start) {
		alert("Your start date should be same or later than the available start date posted by caretaker");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(ctend < end) {
		alert("Your end date should be same or earlier than the end start date posted by caretaker");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(!price) {
		alert("You must offer a price");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(price < 0 || price > 10000) {
		alert("You must select a valid price");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
}