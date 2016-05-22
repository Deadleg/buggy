$(function() {
    $.getJSON("/api/account/me/basic", function(data) {
        console.log(data);
        $("#signin-link").attr('href', '/account/signout');
        $("#signin-link").text(data.username);
    });
})

