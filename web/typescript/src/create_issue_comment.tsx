import * as React from "react";
import { IssueParams } from "./model/router_params";
import { RouteComponentProps } from "react-router";

export interface CreateIssueCommentProps extends RouteComponentProps<IssueParams, any> {
    parentComment: number;
}

export class CreateIssueComment extends React.Component<CreateIssueCommentProps, any> {
    createComment = function(e) {
        e.preventDefault();

        var data = {
            comment: this.refs.comment.value,
            userId: 1,
            parentCommentId: null
        };

        if (this.props.parentComment) {
            data.parentCommentId = this.props.parentComment
        }
        console.log(data);

        $.post(
            "/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId + "/comments",
            JSON.stringify(data),
            function(data) {
                console.log("Ye");
            },
            "json"
        );
    }
    
    render() {
        return (
            <div>
                <h1>New issue comment</h1>
                <form method="post" onSubmit={this.createComment}>
                    <div className="input-field col s12">
                        <textarea className="materialize-textarea" placeholder="Comment" ref="comment"></textarea>
                        <label>Comment</label>
                    </div>
                    <button type="submit" className="waves-effect waves-light btn">Submit</button>
                </form>
            </div>
        );
    }
};
