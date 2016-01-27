var React = require("react");
var Link = require('react-router').Link

module.exports = React.createClass({
    getInitialState: function() {
        return { program: {
            name: "",
            id: 0,
            issues: 0
        }}
    },
    componentDidMount: function() {
        var self = this;

        $.getJSON("/api/programs/" + this.props.params.programId, function(data) {
            console.log(data);
            self.setState({program: data});
        });
    },
    render: function() {
        return (
            <div>
                <div className="col s12">
                    <div className="card blue-grey darken-1 white-text">
                        <div className="card-content">
                            <span className="card-title"><Link to={"/app/" + this.props.params.programId + "/issue"}>{this.state.program.name}</Link></span>
                        </div>
                    </div>
                </div>
                {this.props.children}
            </div>
        );
    }
});


