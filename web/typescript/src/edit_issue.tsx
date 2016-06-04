import * as React from "react";
import { IssueParams } from "./model/router_params";
import { RouteComponentProps } from "react-router";

export interface EditIssueProps extends RouteComponentProps<IssueParams, any> {
}

export class EditIssue extends React.Component<EditIssueProps, any> {
    constructor(props: EditIssueProps) {
        super(props);

        this.state = {
            reproductionSteps: [],
            issue: {}
        }
    }

    componentWillMount() {
        var self = this;
        $.getJSON("/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId, function(data) {
            console.log(data);
            self.setState({issue: data, reproductionSteps: data.reproductionSteps});
        });
    }
    
    componentDidMount() {
        ($('select') as any).material_select();
    }
    
    addReproductionStep() {
        var currentReproductionSteps = this.state.reproductionSteps;
        currentReproductionSteps.push({
            instruction: ""
        });
        this.setState({reproductionSteps: currentReproductionSteps});
    }
    
    removeReproductionStep(index) {
        var currentReproductionSteps = this.state.reproductionSteps;
        this.setState(currentReproductionSteps.splice(index, 1));
    }
    
    updateIssue(e) {
        e.preventDefault();

        var steps = [];

        for (var i = 0; i < this.state.reproductionSteps.length; i++) {
            steps.push((this.refs["instruction" + i] as HTMLInputElement).value);
        }

        var data = {
            programId: this.state.issue.programId,
            id: this.state.issue.id,
            title: (this.refs["title"] as HTMLInputElement).value,
            description: (this.refs["description"] as HTMLInputElement).value,
            type: "Bug",
            reproductionSteps: steps,
        };

        console.log(data);

        $.ajax({
            url: "/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId,
            type: "PUT",
            data: JSON.stringify(data),
        });
    }
    
    updateDescription() {
        this.setState({issue: {description: (this.refs["description"] as HTMLInputElement).value}});
    }
    
    updateTitle() {
        this.setState({issue: {title: (this.refs["title"] as HTMLInputElement).value}});
    }
    
    render() {
        var self = this;
        var steps = this.state.reproductionSteps.map(function(step, index) {
            return (
                <div key={index}>
                    <div className="input-field col s9">
                        <input type="text" placeholder="What did you do?" defaultValue={step.instruction.length > 0 ? step.instruction : null} ref={"instruction" + index} />
                        <label className="active">Step {index + 1}</label>
                    </div>
                    <button className="waves-effect waves-light btn col s3 red" type="button" onClick={self.removeReproductionStep.bind(self, index)}>Delete</button>
                </div>
            );
        });
        return (
            <div>
                <h1>Edit issue</h1>
                <form method="post" onSubmit={this.updateIssue}>
                    <div className="input-field col s12">
                        <input type="text" placeholder="A short descriptive title" ref="title" value={this.state.issue.title} onChange={this.updateTitle}></input>
                        <label>Title</label>
                    </div>
                    <div className="input-field col s12">
                        <textarea className="materialize-textarea" placeholder="A description of the problem" ref="description" value={this.state.issue.description} onChange={this.updateDescription}></textarea>
                        <label>Description</label>
                    </div>
                    <div className="input-field col s6">
                        <select ref="type" defaultValue={this.state.issue.type}>
                            <option value="" disabled></option>
                            <option value="Bug">Bug</option>
                            <option value="Feature">Feature</option>
                            <option value="UX">UX</option>
                            <option value="Graphic">Graphic</option>
                        </select>
                        <label>Issue type</label>
                    </div>
                    {steps}
                    <div className="col s12">
                        <button type="button" className="waves-effect waves-light btn" onClick={this.addReproductionStep}>Add step</button>
                    </div>
                    <button type="submit" className="waves-effect waves-light btn">Submit</button>
                </form>
            </div>
        );
    }
};
