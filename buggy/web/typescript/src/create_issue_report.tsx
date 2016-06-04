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

    componentDidMount() {
        var self = this;
        ($('select') as any).material_select(); // TODO proper type
    }
    
    addLabel() {
        var labels = this.state.labels;
        labels.push({
                text: ($(this.refs["label"]).children("option:selected")[0] as HTMLInputElement).textContent,
                value: (this.refs["label"] as HTMLInputElement).value
        });
        this.setState({labels: labels});
    }
    
    removeLabel(index) {
        var labels = this.state.labels;
        this.setState(labels.splice(index, 1));
    }
    
    createIssue(e) {
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
        );
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
            <div>
                <h1>New issue report</h1>
                <form method="post" onSubmit={this.createIssue}>
                    <div className="input-field col s12">
                        <textarea className="materialize-textarea" placeholder="Your report" ref="description"></textarea>
                        <label>Description</label>
                    </div>
                    <div className="input-field col s12">
                        <textarea className="materialize-textarea" placeholder="Your computer/software specs" ref="specs"></textarea>
                        <label>Specs</label>
                    </div>
                    <div className="input-field col s6">
                        <select defaultValue="" className="browser-default" ref="status">
                            <option value="" disabled></option>
                            <option value="Broken">Broken</option>
                            <option value="Working">Working</option>
                            <option value="PartiallyWorking">Partially working</option>
                            <option value="Works">Works</option>
                            <option value="NoWork">Does not work</option>
                        </select>
                        <label>Status</label>
                    </div>
                    <div className="input-field col s6">
                        <select defaultValue="" className="browser-default" ref="type">
                            <option value="" disabled></option>
                            <option value="Fix">Fix</option>
                            <option value="PartialFix">Partial Fix</option>
                            <option value="Report">Report</option>
                        </select>
                        <label>Type</label>
                    </div>
                    {labels}
                    <button type="submit" className="waves-effect waves-light btn">Submit</button>
                </form>
            </div>
        );
    }
};
