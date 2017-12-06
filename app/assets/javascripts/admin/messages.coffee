# messages.coffee

$(document).ready ->
    $(".message__delete").on "click", deleteMessage


deleteMessage = (e) ->
    message = e.target
    message = message.parentNode while message.tagName != "TR"
    console.log message
    message_id = message.getAttribute("data-message-id")
    $.ajax(method: "DELETE", url: "/admin/messages/" + message_id, success: -> console.log 1, error: -> true)
