var React = require("react");
var CreateIssueComment = require("./create_issue_comment.jsx");

var Comment = React.createClass({
    getInitialState: function() {
        return {
            show: false
        }
    },
    replyTo: function(commentParent) {
        this.setState({show: true})
    },
    render: function() {
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
                            <br />
                            <p className="card-text">Posted {this.props.comment.timeCreated}</p>
                            <button type="button" className="btn btn-common" onClick={this.replyTo.bind(this, this.props.comment.id)}>Reply</button>
                        </div>
                    </div>
                    <div className={this.state.show ? "" : "hide"}>
                        <CreateIssueComment params={this.props.params} parentComment={this.props.comment.id} />
                    </div>
                    {children}
                </div>
            </div>
        );
    }
});

module.exports = Comment
