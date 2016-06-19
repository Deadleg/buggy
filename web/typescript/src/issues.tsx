import * as React from "react";
import { ProgramParams } from "./model/router_params";
import { Link, RouteComponentProps } from "react-router";

export interface IssuesProps extends RouteComponentProps<ProgramParams, any> {
}

export class Issues extends React.Component<IssuesProps, any> {
    constructor(props: IssuesProps) {
        super(props);

        this.state = {programId: this.props.params.programId, issues: []};
    }

    componentDidMount() {
        var self = this;

        $.getJSON("/api/programs/" + this.props.params.programId + "/issues", function(data) {
            self.setState({issues: data});
        });
    }
    
    render() {
        var self = this;
        var content = this.state.issues.map(function (issue, index) {
            return (
                <div className="col-sm-12 bottom-margin-md" key={index}>
                    <div className="row">
                        <div className="col-sm-12">
                            <div className="upvotes">
                                {issue.upvotes}
                            </div>
                            <Link className="" to={"/app/" + self.props.params.programId + "/issue/" + issue.id}>
                                {issue.title}
                            </Link>
                        </div>
                    </div>
                    <div className="label-group">
                        <span className="label label-default">{issue.type}</span>
                        <span className="label label-default">{issue.status}</span>
                    </div>
                    <p className="card-text">
                        <small>
                            Reported on {moment(issue.time).format("DD-MM-YYYY")}
                        </small>
                    </p>
                </div>
            );
        });

        return (
            <div className="container bottom-margin-md">
                <div className="row">
                    {content}
                </div>
            </div>
        );
    }
};
