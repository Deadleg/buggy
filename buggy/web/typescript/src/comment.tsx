import * as React from "react";
import * as ReactDOM from "react-dom";
import { IssueParams } from "./model/router_params";
import { RouteComponentProps } from "react-router";
import { CreateIssueComment } from "./create_issue_comment";

export interface CommentData {
    children: CommentData[];
    comment: string;
    timeCreated: string;
    id: number;
}

export interface CommentProps extends RouteComponentProps<IssueParams, any> {
    comment: CommentData;
}

export class Comment extends React.Component<CommentProps, any> {
    constructor(props: CommentProps) {
        super(props);

        this.state = {
            show: false
        }
    }

    replyTo(commentParent) {
        this.setState({show: true})
    }
    
    render() {
        var self = this;

        var children = this.props.comment.children.map(function(comment, index) {
            return (
                <div style={{"marginLeft": "1rem"}} key={index}>
                    <Comment params={self.props.params} comment={comment} />
                </div>
            );
        });

        return (
            <div className="row">
                <div className="col-sm-12">
                    <div className="card">
                        <div className="card-block">
                            <p className="card-text">{this.props.comment.comment}</p>
                            <p className="card-text"><small>Posted {this.props.comment.timeCreated}</small></p>
                            <button type="button" className="btn btn-common" onClick={this.replyTo.bind(this, this.props.comment.id)}>Reply</button>
                        </div>
                    </div>
                    <div className={this.state.show ? "" : "hide"}>
                        <CreateIssueComment parentComment={this.props.comment.id} params={this.props.params} />
                    </div>
                    {children}
                </div>
            </div>
        );
    }
};