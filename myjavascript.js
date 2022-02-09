function myFunction() {
	var x;
	x = Number(document.getElementById("Demo").innerHTML);
	if (isNaN(x))
		x = 0;
	else
		x += 1;
	
	document.getElementById("Demo").innerHTML = x;
	
}