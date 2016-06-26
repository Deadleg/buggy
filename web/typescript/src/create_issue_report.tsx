import * as React from "react";
import { IssueParams } from "./model/router_params";
import { RouteComponentProps } from "react-router";

export interface CreateIssueProps extends RouteComponentProps<IssueParams, string> {
}

export class CreateIssueReport extends React.Component<CreateIssueProps, any> {
    constructor(props: CreateIssueProps) {
        super(props);

        this.state = {
            programId: this.props.params.programId,
            issueId: this.props.params.issueId,
            labels: []
        }
    }

    addLabel = () => {
        var labels = this.state.labels;
        labels.push({
                text: ($(this.refs["label"]).children("option:selected")[0] as HTMLInputElement).textContent,
                value: (this.refs["label"] as HTMLInputElement).value
        });
        this.setState({labels: labels});
    }
    
    removeLabel = (index) => {
        var labels = this.state.labels;
        this.setState(labels.splice(index, 1));
    }
    
    createIssue = (e) => {
        e.preventDefault();

        var labels = this.state.labels.map(function(x) {
            return x.value;
        });

        var data = {
            specs: (this.refs as any).specs.value,
            description: (this.refs as any).description.value,
            reporterId: 1,
            type: (this.refs as any).type.value,
            status: (this.refs as any).status.value,
            programId: parseInt(this.props.params.programId),
            issueId: parseInt(this.props.params.issueId)
        };

        console.log(data);

        $.post(
            "/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId + "/reports/new",
            JSON.stringify(data),
            function(data) {
                console.log("Ye");
            },
            "json"
        ).fail((e) => {
            console.log(e);
        });
    }
    
    render() {
        var self = this;
        var labels = this.state.labels.map(function(label, index) {
            return (
                <div className="chip" key={index}>
                    {label.text}
                    <i className="material-icons" onClick={self.removeLabel.bind(self, index)}>close</i>
                </div>
            );
        });
        return (
            <div className="container bottom-margin-md">
                <div className="row">
                    <div className="col-sm-12">
                        <h1>New issue report</h1>
                    </div>
                    <div className="col-sm-6">
                        <form method="post" onSubmit={this.createIssue}>
                            <fieldset>
                                <label>Description</label>
                                <textarea className="form-control" placeholder="Your report" ref="description"></textarea>
                            </fieldset>
                            <fieldset>
                                <label>Specs</label>
                                <textarea className="form-control" placeholder="Your computer/software specs" ref="specs"></textarea>
                            </fieldset>
                            <fieldset>
                                <label>Status</label>
                                <select defaultValue="" className="form-control" ref="status">
                                    <option value="" disabled></option>
                                    <option value="Broken">Broken</option>
                                    <option value="Working">Working</option>
                                    <option value="PartiallyWorking">Partially working</option>
                                    <option value="Works">Works</option>
                                    <option value="NoWork">Does not work</option>
                                </select>
                            </fieldset>
                            <fieldset>
                                <label>Type</label>
                                <select defaultValue="" className="form-control" ref="type">
                                    <option value="" disabled></option>
                                    <option value="Fix">Fix</option>
                                    <option value="PartialFix">Partial Fix</option>
                                    <option value="Report">Report</option>
                                </select>
                            </fieldset>
                            {labels}
                            <div style={{"marginTop": "2rem"}}>
                                <button type="submit" className="btn btn-common">Submit</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        );
    }
};
