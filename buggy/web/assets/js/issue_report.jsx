var React = require("react");
var Link = require('react-router').Link
var ReportComment = require("./report_comment.jsx");

module.exports = React.createClass({
    getInitialState: function() {
        console.log("****");
        return {
            report: {
                reporter: {
                    username: ""
                }
            }
        }
    },
    componentDidMount: function() {
        var self = this;
        $.getJSON("/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId + "/reports/" + this.props.params.reportId, function(report) {
            $.getJSON("/api/programs/" + self.props.params.programId + "/issues/" + self.props.params.issueId + "/reports/" + report.id + "/comments", function(comments) {
                report.comments = comments;
                console.log("Setting data");
                self.setState({report: report});
            });
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
        var self = this;
        var reportComments = null;
        var report = this.state.report;

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
            <div className="container">
                <div className="row">
                    <div className="col-sm-12" style={{"marginBottom": "1rem"}}>
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
                                        <button className="btn btn-common" onClick={self.markReportAsFixed.bind(self, self.props.params.reportId)}>Mark as fixed</button>
                                        <div className="btn btn-common">
                                            <Link to={"/app/" + self.props.params.programId + "/issue/" + self.props.params.issueId + "/report/" + self.props.params.reportId}>Comment</Link>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                {reportComments}
            </div>
        );
    }
})