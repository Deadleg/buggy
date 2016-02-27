var React = require("react");
var Link = require('react-router').Link

module.exports = React.createClass({
    getInitialState: function() {
        return {programId: this.props.params.programId, issues: []};
    },
    componentDidMount: function() {
        var self = this;

        $.getJSON("/api/programs/" + this.props.params.programId + "/issues", function(data) {
            self.setState({issues: data});
        });
    },
    render: function() {
        var self = this;
        var content = this.state.issues.map(function (issue, index) {
            return (
                <div className="col-sm-4" key={index}>
                    <div className="card">
                        <div className="card-block">
                            <div className="card-title font-weight-bold"><Link to={"/app/" + self.props.params.programId + "/issue/" + issue.id}>{issue.title}</Link></div>
                            <div className="label-group">
                                <span className="label label-default">{issue.type}</span>
                                <span className="label label-default">{issue.status}</span>
                            </div>
                            <p className="card-text">Reported on {issue.time}</p>
                        </div>
                    </div>
                </div>
            );
        });
        return (
            <div className="container">
                <div className="row">
                    {content}
                </div>
            </div>
        );
    }
});
