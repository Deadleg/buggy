import * as React from "react";
import { IssueParams } from "./model/router_params";
import { Link, RouteComponentProps } from "react-router"
import { Comment } from "./comment";
import { ReportComment } from "./report_comment";
import { Tab, Tabs, TabList, TabPanel } from "react-tabs";

export interface IssueProps extends RouteComponentProps<IssueParams, any> {}

export class Issue extends React.Component<IssueProps, any> {
    constructor(props: IssueProps) {
        super(props);

        this.state = {
            issue: {
                description: "",
                id: 0,
                program: null,
                reporter: {id:0, username:""},
                reproductionSteps: [],
                status: "",
                time: "",
                title: "",
                type: "",
            },
            reports: [],
            comments: [],
            show: []
        }
    }

    markReportAsFixed(reportId) {
        $.post(
            "/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/reports/" + reportId + "/fixed",
            "",
            function(data) {
                console.log("fixed");
            },
            "json"
         );
    }
    
    componentDidMount() {
        var self = this;

        $.getJSON("/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId, function(data) {
            console.log(data);
            self.setState({issue: data});
        });

        $.getJSON("/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId + "/reports", function(data) {
            data.map(function(report, index) {
                $.getJSON("/api/programs/" + self.props.params.programId + "/issues/" + self.props.params.issueId + "/reports/" + report.id + "/comments", function(comments) {
                    report.comments = comments;
                    console.log("Setting data")
                    self.setState({reports: data});
                });
            });
            console.log(data);
        });

        $.getJSON("api/programs/" + this.props.params.programId, function(data) {
            self.setState({program: data});
        })

        $.getJSON("/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId + "/comments", function(data) {
            console.log(data);
            self.setState({comments: data});
        });

        $("#issueTabs a").click(function (e) {
            e.preventDefault();
            ($(this) as any).tab('show');
        });
    }
    
    watchIssue() {
        $.post(
            "/api/issues/me/watch/" + this.props.params.issueId
        ).fail(function(data) {
            console.log("watch failed", data);
        });
    }
    
    render() {
        var steps = this.state.issue.reproductionSteps.map(function(step, index) {
            return (
                <li key={index} className="common-list-item">{step.instruction}</li>
            );
        });

        var self = this;

        var comments = this.state.comments.map(function(comment, index) {
            return (
                <div key={index}>
                    <Comment params={self.props.params} comment={comment}/>
                </div>
            );
        });

        var reports = this.state.reports.map(function(report, index) {
            var reportComments = null;
            if (report.comments) {
                reportComments = report.comments.map(function(comment, index) {
                    return (
                        <div key={index}>
                            <ReportComment params={self.props.params} reportId={report.id} comment={comment}/>
                        </div>
                    );
                });
            }

            return (
                <div key={index} className="col-sm-4" style={{"marginBottom": "1rem"}}>
                    <div style={{"marginBottom": "1rem"}}>
                        <div className="card">
                            <div className="card-block">
                                <div>{report.description}</div>
                                <p>{report.specs}</p>
                                <div className="label-group">
                                    <div className="label label-default">{report.status}</div>
                                    <div className="label label-default">{report.type}</div>
                                    <div className="label label-default">{report.confirmed ? "Confirmed" : "Unconfirmed"}</div>
                                </div>
                                <div><small>Reported by {report.reporter.username}</small></div>
                                <div><small>At {report.time}</small></div>
                                <div className="btn-group-spaced" style={{"marginBottom": "1rem"}}>
                                    <button className="btn btn-common" onClick={self.markReportAsFixed.bind(self, index)}>Mark as fixed</button>
                                    <div className="btn btn-common">
                                        <Link to={"/app/" + self.props.params.programId + "/issue/" + self.props.params.issueId + "/report/" + report.id}>Comments</Link>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            );
        });

        var edited;
        if (this.state.issue.lastEdited) {
            edited = <div><small>Edit time: {this.state.issue.lastEdited}</small></div>
        }

        return (
            <div className="container">
                <div className="row">
                    <div className="col-sm-6">
                        <h3>{this.state.issue.title}</h3>
                        <div className="label-group" style={{"marginBottom": "1rem"}}>
                            <span className="label label-default">{this.state.issue.type}</span>
                            <span className="label label-default">{this.state.issue.status}</span>
                        </div>
                        <div>{this.state.issue.description}</div>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-6">
                        <ol className="common-list">
                            {steps}
                        </ol>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-6">
                        <div><small>Reported by: {this.state.issue.reporter.username}</small></div>
                        <div><small>At {this.state.issue.time}</small></div>
                        {edited}
                    </div>
                </div>
                <div className="row" style={{"marginTop":"2rem", "marginBottom": "2rem"}}>
                    <div className="col-sm-12 btn-group-spaced" id="issueTabs">
                        <button className="btn btn-common"><Link to={"/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/report/new"}>Add report</Link></button>
                        <button className="btn btn-common"><Link to={"/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/comments/new"}>Add comment</Link></button>
                        <button className="btn btn-common"><Link to={"/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/edit"}>Edit issue</Link></button>
                        <button className="btn btn-common" onClick={this.watchIssue}>Watch</button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <Tabs className="no-border">
                            <TabList>
                                <Tab className="btn btn-common">Reports</Tab>
                                <Tab className="btn btn-common">Comments</Tab>
                            </TabList>
                            <TabPanel>
                                <div className="row">
                                    {reports}
                                </div>
                            </TabPanel>
                            <TabPanel>
                                {comments}
                            </TabPanel>
                        </Tabs>
                    </div>
                </div>
            </div>
        );
    }
};
