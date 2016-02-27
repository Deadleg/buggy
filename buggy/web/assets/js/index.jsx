var React = require('react');
var ReactDOM = require('react-dom');
var Router = require('react-router').Router
var Route = require('react-router').Route
var Link = require('react-router').Link

var Games = React.createClass({
    getInitialState: function() {
        return {programs: []}
    },
    componentDidMount: function() {
        var self = this;
        $.getJSON("/api/programs", function(data) {
            console.log(data);
            var state = self.state;
            self.state.programs = data;
            self.setState(state);
        });
    },
    render: function() {
        var content = this.state.programs.map(function (program, index) {
            return (
                <div className="row" key={index}>
                    <div className="col-sm-3">
                        <div className="card">
                            <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid card-img-top"/>
                            <div className="card-block">
                                <h4 className="card-title"><Link to={"/app/" + program.id + "/issue"}>{program.name}</Link></h4>
                                <p className="card-text">Issues: {program.issues}</p>
                            </div>
                        </div>
                    </div>
                </div>
            );
        });
        return (
            <div className="container">
                {content}
            </div>
        );
    }
});

var Issues = require("./issues.jsx");
var Issue = require("./issue.jsx");
var EditIssue = require("./edit_issue.jsx");
var Program = require("./program.jsx");
var CreateIssue = require("./create_issue.jsx");
var CreateIssueReport = require("./create_issue_report.jsx");
var CreateIssueComment = require("./create_issue_comment.jsx");
var CreateIssueReportComment = require("./create_issue_report_comment.jsx");

ReactDOM.render((
    <Router>
        <Route path="/" component={Games}/>
        <Route path="/app/:programId" component={Program}>
            <Route path="/app/:programId/issue/new" component={CreateIssue} />
            <Route path="/app/:programId/issue/:issueId" component={Issue} />
            <Route path="/app/:programId/issue/:issueId/edit" component={EditIssue} />
            <Route path="/app/:programId/issue/:issueId/report/new" component={CreateIssueReport} />
            <Route path="/app/:programId/issue/:issueId/report/:reportId/comments/new" component={CreateIssueReportComment} />
            <Route path="/app/:programId/issue/:issueId/comments/new" component={CreateIssueComment} />
            <Route path="/app/:programId/issue" component={Issues} />
       </Route>
    </Router>),
    document.getElementById('content')
);