import * as React from "react";
import { IssueParams } from "./model/router_params";
import { RouteComponentProps } from "react-router";
import { CreateIssueReportComment } from "./create_issue_report_comment";

export interface CommentData {
    children: CommentData[];
    comment: string;
    timeCreated: string;
    id: string;
}

export interface ReportCommentProps extends RouteComponentProps<IssueParams, any> {
    comment: CommentData;
    reportId: string;
}

export class ReportComment extends React.Component<ReportCommentProps, any> {
    constructor(props: ReportCommentProps) {
        super(props);

        this.state = { show: false };
    }

    replyTo(commentParent) {
        this.setState({show: true})
    }
    
    render() {
        var self = this;

        var children = this.props.comment.children.map(function(comment, index) {
            return (
                <div style={{"marginLeft": "1rem"}} key={index}>
                    <ReportComment params={self.props.params} reportId={this.props.repordId} comment={comment} />
                </div>
            );
        });

        return (
            <div className="row">
                <div className="col-sm-12">
                    <div className="card">
                        <div className="card-block">
                            <p className="card-text">{this.props.comment.comment}</p>
                            <br />
                            <p className="card-text">Posted {this.props.comment.timeCreated}</p>
                            <button type="button" className="btn btn-common" onClick={this.replyTo.bind(this, this.props.comment.id)}>Reply</button>
                        </div>
                    </div>
                    <div className={this.state.show ? "" : "hide"}>
                        <CreateIssueReportComment parentComment={this.props.comment.id} />
                    </div>
                    {children}
                </div>
            </div>
        );
    }
};