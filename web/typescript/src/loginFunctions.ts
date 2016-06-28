export function signOut() {
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.signOut().then(function() {
        console.log("signed out");
        $("signin-link").text("sign-out");
        $("signin-link").attr("href", "$/account/login");
        $("signin-link").unbind("click");
    });
}
