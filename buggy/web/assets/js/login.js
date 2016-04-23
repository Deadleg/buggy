function onSignIn(googleUser) {
    var profile = googleUser.getBasicProfile();
    var data = {
        token: googleUser.getAuthResponse().id_token
    }

    $.post(
        "/api/account/login/google",
        JSON.stringify(data)
    ).fail(function(e) {
        console.log(e);
    });
    console.log(profile.getName());
    console.log(googleUser.getAuthResponse().id_token);
    window.location = "/";
}

function signOut() {
    console.log("ajsdadsn");
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.signOut().then(function() {
        console.log("signed out");
        $("signin-link").text("sign-out");
        $("signin-link").attr("href", "$/account/login");
        $("signin-link").unbind("click");
    });
}
