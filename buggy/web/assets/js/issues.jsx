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
                <div className="col m3 s12" key={index}>
                    <div className="card blue-grey darken-1 white-text">
                        <div className="card-content">
                            <p className="card-title"><Link to={"/app/" + self.props.params.programId + "/issue/" + issue.id}>{issue.title}</Link></p>
                            <div className="chip">{issue.type}</div>
                            <div className="chip">{issue.status}</div>
                            <p>Reported on {issue.time}</p>
                        </div>
                    </div>
                </div>
            );
        });
        return (
            <div className="col s12">
                <div className="row">
                    <div className="col s4">
                        <button className="waves-effect waves-light btn"><Link to={"/app/" + self.props.params.programId + "/issue/new"}>Create an issue</Link></button>
                    </div>
                </div>
                <div className="row">
                    {content}
                </div>
            </div>
        );
    }
});
