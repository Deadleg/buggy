import * as React from "react";
import * as ReactDOM from "react-dom";
import { IssueParams } from "./model/router_params";
import { RouteComponentProps } from "react-router";

export interface ProgramProps extends RouteComponentProps<ProgramParams, any> {
}

export class ProgramUpdates extends React.Component<UpdatePropsProps, any> {
    constructor(props: ProgramParams) {
        super(props);

        this.state = {
        }
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