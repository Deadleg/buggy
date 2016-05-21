var React = require("react");

var Login = React.createClass({
    render: function() {
        return (
            <div className="container">
                <div className="row">
                    <div className="col-sm-12">
                        <div className="g-signin2" data-onsuccess="onSignIn"></div>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <a id="login" href="https://steamcommunity.com/openid/login?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&amp;openid.mode=checkid_setup&amp;openid.return_to=http%3A%2F%2Flocalhost:8000%2Flogin%2Fsteam&amp;openid.realm=http%3A%2F%2Flocalhost:8000&amp;openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&amp;openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&amp;openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select"><img src="https://steamcommunity-a.akamaihd.net/public/images/signinthroughsteam/sits_small.png"/></a>
                    </div>
                </div>
            </div>
        );
    }
});

module.exports = Login;
