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
            </div>
        );
    }
});

module.exports = Login;
