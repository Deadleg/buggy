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

    componentWillMount = () => {
        var self = this;
        $.getJSON("/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId, function(data) {
            console.log(data);
            self.setState({issue: data, reproductionSteps: data.reproductionSteps});
        });
    }
    
    addReproductionStep = () => {
        var currentReproductionSteps = this.state.reproductionSteps;
        currentReproductionSteps.push({
            instruction: ""
        });
        this.setState({reproductionSteps: currentReproductionSteps});
    }
    
    removeReproductionStep = (index) => {
        var currentReproductionSteps = this.state.reproductionSteps;
        this.setState(currentReproductionSteps.splice(index, 1));
    }
    
    updateIssue = (e) => {
        e.preventDefault();

        var steps = [];

        for (var i = 0; i < this.state.reproductionSteps.length; i++) {
            steps.push((this.refs["instruction" + i] as HTMLInputElement).value);
        }

        var data = {
            programId: this.state.issue.programId,
            id: this.state.issue.id,
            title: this.state.issue.title,
            description: this.state.issue.description,
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
    
    updateDescription = (e) => {
        var issue = this.state.issue;
        issue.description = (e.target as HTMLInputElement).value;
        this.setState({issue: issue});
    }

    updateTitle = (e) => {
        var issue = this.state.issue;
        issue.title = (e.target as HTMLInputElement).value;
        this.setState({issue: issue});
    }

    render() {
        var self = this;
        var steps = this.state.reproductionSteps.map(function(step, index) {
            return (
                <div key={index}>
                    <fieldset className="form-group">
                        <label>Step {index + 1}</label>
                        <input className="form-control" type="text" placeholder="What did you do?" defaultValue={step.instruction.length > 0 ? step.instruction : null} ref={"instruction" + index} />
                        <div className="btn-group form-sequence-buttons pull-sm-right">
                            <button className="btn btn-red" type="button" onClick={self.removeReproductionStep.bind(self, index)}>Delete</button>
                        </div>
                    </fieldset>
                </div>
            );
        });

        return (
            <div className="container bottom-margin-md">
                <div className="row">
                    <div className="col-sm-12">
                        <h1>Edit issue</h1>
                    </div>
                    <div className="col-sm-6">
                        <form method="post" onSubmit={this.updateIssue}>
                            <fieldset>
                                <label>Title</label>
                                <input className="form-control" type="text" placeholder="A short descriptive title" value={this.state.issue.title} onChange={this.updateTitle}></input>
                            </fieldset>
                            <fieldset>
                                <label>Description</label>
                                <textarea className="form-control" placeholder="A description of the problem" value={this.state.issue.description} onChange={this.updateDescription}></textarea>
                            </fieldset>
                            <fieldset>
                                <label>Issue type</label>
                                <select className="form-control" ref="type" defaultValue={this.state.issue.type}>
                                    <option value="" disabled></option>
                                    <option value="Bug">Bug</option>
                                    <option value="Feature">Feature</option>
                                    <option value="UX">UX</option>
                                    <option value="Graphic">Graphic</option>
                                </select>
                            </fieldset>
                            {steps}
                            <button type="button" className="btn btn-common" onClick={this.addReproductionStep}>Add step</button>
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
