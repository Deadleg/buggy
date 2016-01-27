var React = require("react");

module.exports = React.createClass({
    getInitialState: function() {
        return {
            reproductionSteps: [],
        }
    },
    componentDidMount: function() {
        var self = this;
        $('select').material_select();
    },
    addReproductionStep: function() {
        var currentReproductionSteps = this.state.reproductionSteps;
        currentReproductionSteps.push({
            instruction: ""
        });
        this.setState({reproductionSteps: currentReproductionSteps});
    },
    removeReproductionStep: function(index) {
        var currentReproductionSteps = this.state.reproductionSteps;
        this.setState(currentReproductionSteps.splice(index, 1));
    },
    createIssue: function(e) {
        e.preventDefault();

        var steps = [];

        for (i = 0; i < this.state.reproductionSteps.length; i++) {
            steps.push(this.refs["instruction" + i].value);
        }

        var data = {
            title: this.refs.title.value,
            description: this.refs.description.value,
            type: "Bug",
            reproductionSteps: steps,
            programId: parseInt(this.props.params.programId),
        };

        console.log(data);

        $.post(
            "api/programs/" + this.props.params.programId + "/issues/new",
            JSON.stringify(data),
            function(data) {
                console.log("Ye");
            },
            "json"
        );
    },
    render: function() {
        var self = this;
        var steps = this.state.reproductionSteps.map(function(step, index) {
            return (
                <div key={index}>
                    <div className="input-field col s9">
                        <input type="text" placeholder="What did you do?" value={step.instruction.length > 0 ? step.instruction : null} ref={"instruction" + index} />
                        <label className="active">Step {index + 1}</label>
                    </div>
                    <button className="waves-effect waves-light btn col s3 red" type="button" onClick={self.removeReproductionStep.bind(self, index)}>Delete</button>
                </div>
            );
        });
        return (
            <div>
                <h1>New issue</h1>
                <form method="post" onSubmit={this.createIssue}>
                    <div className="input-field col s12">
                        <input type="text" placeholder="A short descriptive title" ref="title"></input>
                        <label>Title</label>
                    </div>
                    <div className="input-field col s12">
                        <textarea className="materialize-textarea" placeholder="A description of the problem" ref="description"></textarea>
                        <label>Description</label>
                    </div>
                    <div className="input-field col s6">
                        <select value="" ref="type">
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
});
