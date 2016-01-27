var React = require("react");
var Link = require('react-router').Link
var Comment = require("./comment.jsx");
var ReportComment = require("./report_comment.jsx");

module.exports = React.createClass({
    getInitialState: function() {
        return {
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
    },
    componentDidMount: function() {
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
    },
    markReportAsFixed: function(reportId) {
        $.post(
            "/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/reports/" + reportId + "/fixed",
            "",
            function(data) {
                console.log("fixed");
            },
            "json"
         );
    },
    render: function() {
        var steps = this.state.issue.reproductionSteps.map(function(step, index) {
            return (
                <li key={index} className="collection-item">{step.instruction}</li>
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
                console.log("report")
                console.log(report.id)
                reportComments = report.comments.map(function(comment, index) {
                    return (
                        <div key={index}>
                            <ReportComment params={self.props.params} reportId={report.id} comment={comment}/>
                        </div>
                    );
                });
            }

            return (
                <div key={index}>
                    <div className="card grey white-text">
                        <div className="card-content">
                            <p>{report.description}</p>
                            <p>{report.specs}</p>
                            <p>Reported by {report.reporter.username}</p>
                            <p>At {report.time}</p>
                            <div className="chip">{report.status}</div>
                            <div className="chip">{report.type}</div>
                            <div className="chip">{report.confirmed ? "Confirmed" : "Unconfirmed"}</div>
                            <button onClick={self.markReportAsFixed.bind(self, index)}>Mark as fixed</button>
                        </div>
                        <div className="card-action">
                            <Link to={"/app/" + self.props.params.programId + "/issue/" + self.props.params.issueId + "/report/" + report.id + "/comments/new"}>Comment</Link>
                        </div>
                    </div>
                    {reportComments}
                </div>
            );
        });

        var edited = "";
        if (this.state.issue.lastEdited) {
            edited = <p>Edit time: {this.state.issue.lastEdited}</p>
        }

        return (
            <div>
                <div className="col s12">
                    <div className="card blue-grey darken-1 white-text">
                        <div className="card-content">
                            <span className="card-title">{this.state.issue.title}</span>
                            <p>{this.state.issue.description}</p>
                            <div className="chip">{this.state.issue.type}</div>
                            <div className="chip">{this.state.issue.status}</div>
                            <p>Reported by: {this.state.issue.reporter.username}</p>
                            <p>At {this.state.issue.time}</p>
                            {edited}
                        </div>
                    </div>
                </div>
                <ul className="collection">
                    {steps}
                </ul>
                <button className="waves-effect waves-light btn"><Link to={"/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/report/new"}>Create report</Link></button>
                <button className="waves-effect waves-light btn"><Link to={"/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/comments/new"}>Add comment</Link></button>
                <button className="waves-effect waves-light btn"><Link to={"/app/" + this.props.params.programId + "/issue/" + this.props.params.issueId + "/edit"}>Edit issue</Link></button>
                {comments}
                {reports}
            </div>
        );
    }
});


