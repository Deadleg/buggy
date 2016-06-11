import * as React from "react";
import * as ReactDOM from "react-dom";
import { Router, Route, Link, browserHistory } from "react-router";
import { ProgramSummaries } from "./program_summaries";
import { Issues } from "./issues";
import { Issue } from "./issue";
import { EditIssue } from "./edit_issue";
import { Program } from "./program";
import { CreateIssue } from "./create_issue";
import { CreateIssueReport } from "./create_issue_report";
import { CreateIssueComment } from "./create_issue_comment";
import { CreateIssueReportComment } from "./create_issue_report_comment";
import { IssueReport } from "./issue_report";
import { Login } from "./login";


var Home = React.createClass({
    getInitialState: function() {
        return {programs: {}, user: {}, popular: [], popularIssues: []}
    },
    componentDidMount: function() {
        var self = this;
        //$.getJSON("/api/programs", function(data) {
        //    console.log(data);
        //    var state = self.state;
        //    self.state.programs = data;
        //    self.setState(state);
        //});

        $.getJSON("/api/programs/popular", (data) => {
            console.log(data);
            self.setState({popular: data});
        }).fail((e) => {
            console.log(e);
        });

        $.getJSON("/api/issues/popular", (data) => {
            console.log(data);
            data.map((issue) => {
                $.getJSON("/api/programs/" + issue.programId, (programData) => {
                    var programs = self.state.programs;
                    programs[issue.programId] = programData;
                    this.setState({programs: programs});
                });
            });
            self.setState({popularIssues: data});
        }).fail((e) => {
           console.log(e);
       });
    },
    render: function() {
        var self = this;
        var popularIssues = this.state.popularIssues.map((issue, index) => {
            return (
                <div className="col-sm-3">
                    <div className="card">
                        <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid card-img-top"/>
                        <div className="card-block">
                            <h4 className="card-title"><Link to={"/app/" + issue.programId + "/issue/" + issue.id}>{issue.title}</Link></h4>
                            <p className="card-text">{self.state.programs[issue.programId].name}</p>
                            <p className="card-text">Reported: {issue.time}</p>
                        </div>
                    </div>
                </div>
            );
        });

        var summaries = this.state.popular.map((summary, index) => {
            var issues = summary.topIssues.map((issue, index) => {
                return (
                    <div key={index}>
                        <p className="card-text small">{issue.title}</p>
                    </div>
                );
            });

            return (
                <div className="col-sm-3">
                    <div className="card">
                        <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid card-img-top"/>
                        <div className="card-block">
                            <h4 className="card-title"><Link to={"/app/" + summary.id + "/issue"}>{summary.name}</Link></h4>
                            {issues}
                        </div>
                    </div>
                </div>
            );
        });

        return (
            <div className="container">
                <h2>Top issues</h2>
                <div className="row">
                    {popularIssues}
                </div>

                <h2>Popular buggy games</h2>
                <div className="row">
                    {summaries}
                </div>
            </div>
        );
    }
});

ReactDOM.render((
    <Router history={browserHistory}>
        <Route path="/" component={Home}/>
        <Route path="/account/login" component={Login}/>
        <Route path="/app/:programId" component={Program}>
            <Route path="/app/:programId/issue/new" component={CreateIssue} />
            <Route path="/app/:programId/issue/:issueId/edit" component={EditIssue} />
            <Route path="/app/:programId/issue/:issueId" component={Issue} />
            <Route path="/app/:programId/issue/:issueId/report/new" component={CreateIssueReport} />
            <Route path="/app/:programId/issue/:issueId/report/:reportId" component={IssueReport} />
            <Route path="/app/:programId/issue/:issueId/report/:reportId/comments/new" component={CreateIssueReportComment} />
            <Route path="/app/:programId/issue/:issueId/comments/new" component={CreateIssueComment} />
            <Route path="/app/:programId/issue" component={Issues} />
       </Route>
    </Router>),
    document.getElementById('content')
);
