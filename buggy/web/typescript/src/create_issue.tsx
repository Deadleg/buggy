import * as React from "react";
import { RouteComponentProps } from "react-router";

export interface ProgramParams {
    programId: string;
}

export interface CreateIssueProps extends RouteComponentProps<ProgramParams, string> {
}

export class CreateIssue extends React.Component<CreateIssueProps, any> {
    constructor(props: CreateIssueProps) {
        super(props);

        this.state = { reproductionSteps: [] }
    }

    addReproductionStep = () => {
        var currentReproductionSteps = this.state.reproductionSteps;
        currentReproductionSteps.push({
            instruction: ""
        });
        this.setState({reproductionSteps: currentReproductionSteps});
    }
    
    removeReproductionStep = (index: number) => {
        var currentReproductionSteps = this.state.reproductionSteps;
        this.setState(currentReproductionSteps.splice(index, 1));
    }
    
    createIssue = (e) => {
        e.preventDefault();

        var steps = [];

        for (var i = 0; i < this.state.reproductionSteps.length; i++) {
            steps.push((this.refs["instruction" + i] as any).value);
        }

        var data = {
            title: (this.refs as any).title.value,
            description: (this.refs as any).description.value,
            type: "Bug",
            reproductionSteps: steps,
            programId: parseInt(this.props.params.programId),
        };

        console.log(data);
        console.log(this.props.params.programId);

        $.post(
            "/api/programs/" + this.props.params.programId + "/issues/new",
            JSON.stringify(data),
            function(data) {
                console.log("Ye");
            },
            "json"
        ).fail(function(e) {
            console.log(e);
        });
    }
    
    render() {
        var self = this;
        var steps = this.state.reproductionSteps.map(function(step, index) {
            return (
                <div key={index}>
                    <fieldset className="form-group">
                        <label>Step {index + 1}</label>
                        <input className="form-control" type="text" placeholder="What did you do?" value={step.instruction.length > 0 ? step.instruction : null} ref={"instruction" + index} />
                        <div className="btn-group form-sequence-buttons pull-sm-right">
                            <button className="btn btn-red" type="button" onClick={self.removeReproductionStep.bind(self, index)}>Delete</button>
                        </div>
                    </fieldset>
                </div>
            );
        });
        return (
            <div className="container">
                <div className="row">
                    <div className="col-sm-12">
                        <h1>New issue</h1>
                    </div>
                    <div className="col-sm-6">
                        <form method="post" onSubmit={this.createIssue}>
                            <fieldset className="form-group">
                                <label>Title</label>
                                <input type="text" className="form-control" placeholder="A short descriptive title" ref="title"></input>
                            </fieldset>
                            <fieldset className="form-group">
                                <label>Description</label>
                                <textarea className="form-control" placeholder="A description of the problem" ref="description"></textarea>
                            </fieldset>
                            <fieldset className="form-group">
                                <label>Issue type</label>
                                <select defaultValue="" ref="type" className="form-control">
                                    <option value="" disabled></option>
                                    <option value="Bug">Bug</option>
                                    <option value="Feature">Feature</option>
                                    <option value="UX">UX</option>
                                    <option value="Graphic">Graphic</option>
                                </select>
                            </fieldset>
                            {steps}
                            <button type="button" className="btn btn-common" onClick={this.addReproductionStep}>Add step</button>
                            <div className="col s12" style={{"marginTop": "2rem"}}>
                                <button type="submit" className="btn btn-common">Submit</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        );
    }
};
