import * as React from "react";
import * as ReactDOM from "react-dom";
import { IndexRoute, Router, Route, Link, browserHistory } from "react-router";
import { ProgramSummaries } from "./program_summaries";
import { IssuesContainer } from "./issues";
import { IssueContainer } from "./issue";
import { EditIssue } from "./edit_issue";
import { Program } from "./program";
import { CreateIssue } from "./create_issue";
import { CreateIssueReport } from "./create_issue_report";
import { CreateIssueComment } from "./create_issue_comment";
import { CreateIssueReportComment } from "./create_issue_report_comment";
import { IssueReportContainer } from "./issue_report";
import { LoginContainer } from "./login";
import { Games } from "./games";
import { Provider } from 'react-redux';
import * as User from "./user";
import { createStore } from 'redux';
export * from './loginFunctions';

const store = createStore(User.updateUser);

$.getJSON("/api/account/me/basic", function(data) {
    console.log(data);
    $("#signin-link").attr('href', '/account/signout');
    $("#signin-link").text(data.username);
    store.dispatch(User.signinUser(data));
}).fail(function(e) {
    console.log(e);
});

var Layout = React.createClass({
    render: function() {
        return (
            <div>
                {this.props.children}

                <footer>
                    <div className="container">
                        <div className="row">
                            <div className="col-sm-4">
                                <p><Link to="/about">About</Link></p>
                                <p><a href="#">Source</a></p>
                                <p><Link to="/privacy">Privacy</Link></p>
                                <p><Link to="/donate">Donate</Link></p>
                            </div>
                        </div>
                    </div>
                </footer>
            </div>
        )
    }
});

var Home = React.createClass({
    getInitialState: function() {
        return {programs: {}, user: {}, popular: [], popularIssues: []}
    },
    componentDidMount: function() {
        var self = this;
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
                    <div className="card card-light">
                        <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid card-img-top"/>
                        <div className="card-block-no-padding">
                            <h5 className="card-title">
                                <div className="upvotes">{issue.upvotes}</div>
                                <Link to={"/app/" + issue.programId + "/issue/" + issue.id}>
                                    {issue.title}
                                </Link>
                            </h5>
                            <div className="row">
                                <div className="label-group col-sm-6">
                                    <span className="label label-default">{issue.type}</span>
                                    <span className="label label-default">{issue.status}</span>
                                </div>
                                <div className="card-text col-sm-6 text-sm-right">{moment(issue.time).format("DD-MM-YYYY")}</div>
                            </div>
                            <div className="row">
                                <span className="card-text col-sm-10">
                                    <b>
                                        <Link to={"/app/" + self.state.programs[issue.programId].id + "/issue"}>
                                            {self.state.programs[issue.programId].name}
                                        </Link>
                                    </b>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            );
        });

        var summaries = this.state.popular.map((summary, index) => {
            var issues = summary.topIssues.map((issue, index2) => {
                return (
                    <div key={index2}>
                        <div className="upvotes">
                            {issue.upvotes}
                        </div>
                        <span className="card-text"><Link to={"/app/" + summary.id + "/issue/" + issue.issueId}>{issue.title}</Link></span>
                    </div>
                );
            });

            return (
                <div className="col-sm-3">
                    <div className="card card-light">
                        <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid card-img-top"/>
                        <div className="card-block">
                            <h5 className="card-title"><Link to={"/app/" + summary.id + "/issue"}>{summary.name}</Link></h5>
                            {issues}
                        </div>
                    </div>
                </div>
            );
        });

        return (
            <div>
                <div className="container bottom-margin-md">
                    <h2 className="bottom-margin-md red-underline">Hot issues</h2>
                    <div className="row">
                        {popularIssues}
                    </div>
                </div>

                <div className="banner">
                    <div className="container bottom-margin-md">
                        <div className="banner-body">
                            <h2 className="bottom-margin-md blue-underline">Popular games</h2>
                            <div className="row">
                                {summaries}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
});

ReactDOM.render((
    <Provider store={store}>
        <Router history={browserHistory}>
            <Route path="/" component={Layout}>
                <Route path="browse" component={Games}/>
                <Route path="account/login" component={LoginContainer}/>
                <Route path="app/:programId" component={Program}>
                    <Route path="issue/new" component={CreateIssue}/>
                    <Route path="issue" component={IssuesContainer}>
                        <Route path=":issueId" component={IssueContainer}/>
                    </Route>
                    <Route path="issue/:issueId/edit" component={EditIssue}/>
                    <Route path="issue/:issueId/report/new" component={CreateIssueReport}/>
                    <Route path="issue/:issueId/report/:reportId/comments/new" component={CreateIssueReportComment}/>
                    <Route path="issue/:issueId/report/:reportId" component={IssueReportContainer}/>
                    <Route path="issue/:issueId/comments/new" component={CreateIssueComment}/>
                </Route>
                <IndexRoute component={Home}/>
           </Route>
        </Router>
    </Provider>),
    document.getElementById('content')
);
