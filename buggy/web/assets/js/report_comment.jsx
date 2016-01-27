var React = require("react");
var CreateIssueReportComment = require("./create_issue_report_comment.jsx");

var ReportComment = React.createClass({
    getInitialState: function() {
        return {
            show: false
        }
    },
    replyTo: function(commentParent) {
        this.setState({show: true})
    },
    render: function() {
        var self = this;

        var children = this.props.comment.children.map(function(comment, index) {
            return (
                <div style={{"marginLeft": "1rem"}} key={index}>
                    <ReportComment params={self.props.params} reportId={self.props.reportId} comment={comment} />
                </div>
            );
        });

        return (
            <div>
                <div>
                    <div className="card green lighten-4">
                        <div className="card-content">
                            <p>{this.props.comment.comment}</p>
                            <br />
                            <p>Posted {this.props.comment.timeCreated}</p>
                        </div>
                        <div className="card-action">
                            <button type="button" onClick={this.replyTo.bind(this, this.props.comment.id)}>Reply</button>
                        </div>
                    </div>
                </div>
                <div className={this.state.show ? "" : "hide"}>
                    <CreateIssueReportComment reportId={this.props.reportId} params={this.props.params} parentComment={this.props.comment.id} />
                </div>
                {children}
            </div>
        );
    }
});

module.exports = ReportComment
