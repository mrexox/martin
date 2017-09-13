document.addEventListener("DOMContentLoaded", function(event) {
	document.getElementById("submitButton").addEventListener("click", function(e) {
		e.preventDefault();
		var login = document.getElementById('inputLogin').value;
		var password = document.getElementById('inputPassword').value;
		
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open('POST', '/login');
		xmlhttp.setRequestHeader('Content-Type', 'application/json');
		xmlhttp.onload = function() {
			if (xmlhttp.status === 200) {
				var address = JSON.parse(xmlhttp.responseText).address;
				window.location.href = location.protocol + '//'+ location.hostname + ':' + location.port + address;
			} else  {
				
			}	
		};
		xmlhttp.send(JSON.stringify({login:login, password:password}));
	});
});
