import * as React from "react";
import { signinUser } from "./user";
import { browserHistory } from "react-router";
import { connect } from "react-redux";

export class Login extends React.Component<any, any> {
    constructor() {
        super();
    }

    googleSignIn = (googleUser) => {
        var self = this;
        var profile = googleUser.getBasicProfile();
        var data = {
            token: googleUser.getAuthResponse().id_token
        }

        $.post(
            "/api/account/login/google",
            JSON.stringify(data)
        ).done((data) => {
            $.getJSON("/api/account/me/basic", function(data) {
                console.log(data);
                $("#signin-link").attr('href', '/account/signout');
                $("#signin-link").text(data.username);
                self.props.addUser(data);
                browserHistory.push('/');
            }).fail(function(e) {
                console.log(e);
            });
        })
        .fail(function(e) {
            console.log(e);
        });


        console.log(profile.getName());
    }

    componentDidMount = () => {
          gapi.signin2.render('google-signin', {
            'onsuccess': this.googleSignIn
          });
    }

    render() {
        return (
            <div className="container">
                <div className="row">
                    <div className="col-sm-12">
                        <div id="google-signin"></div>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <a href="https://steamcommunity.com/openid/login?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&amp;openid.mode=checkid_setup&amp;openid.return_to=http%3A%2F%2Flocalhost:8000%2Flogin%2Fsteam&amp;openid.realm=http%3A%2F%2Flocalhost:8000&amp;openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&amp;openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&amp;openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select"><img src="https://steamcommunity-a.akamaihd.net/public/images/signinthroughsteam/sits_small.png"/></a>
                    </div>
                </div>
            </div>
        );
    }
};

const mapDispatchToProps = (dispatch) => {
    return {
        addUser: (userdata) => { dispatch(signinUser(userdata)); }
    };
}

export const LoginContainer = connect(null, mapDispatchToProps)(Login);