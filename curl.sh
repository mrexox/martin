function delete_message {
		curl -X DELETE \
				 -H "Authorization-Key: $2" \
				 http://localhost:8080/message/1
}

function create_done_order {
		local new_order='
{
"description": "Our new project from Bear Inc.",
"photo": "woo.jpg",
"response": "Nice job, guys!",
"site_href": "my-site.ru",
"valyay_comment": "Easy!",
"ian_comment": "Real talk!"
}'
		curl -X POST \
				 -H "Content-Type: application/json" \
				 -H "Authorization-Key: $2" \
				 -d $new_order \
				 http://localhost/create_done_order
}

function update_done_order {
		local changed_order='
{
"description": "Something new",
"photo": "new_photo.jpg",
"response": "Old response",
"site_href": "my-site.ru",
"valyay_comment": "Eaasy!",
"ian_comment": "Reasl talk!"
}'
		curl -X PUT \
				 -H "Content-Type: application/json" \
				 -H "Authorization-Key: $2" \
				 -d $changed_order \
				 http://localhost:8080/update_done_order/1
}

function delete_done_order {
		curl -X DELETE \
				 -H "Autorization-Key: $2" \
				 http://localhost:8080/done_order/1
}

function ask_key {
		curl http://localhost:8080/login \
				 -d "login=ian&password=password"
}

$1
