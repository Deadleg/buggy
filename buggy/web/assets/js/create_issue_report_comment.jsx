var React = require("react");

module.exports = React.createClass({
    createComment: function(e) {
        e.preventDefault();

        var data = {
            comment: this.refs.comment.value,
            userId: 1
        };

        if (this.props.parentComment) {
            data.parentCommentId = this.props.parentComment
        }
        console.log(data);

        var reportId = this.props.reportId ? this.props.reportId : this.props.params.reportId;

        $.post(
            "/api/programs/" + this.props.params.programId + "/issues/" + this.props.params.issueId + "/reports/" + reportId + "/comments",
            JSON.stringify(data),
            function(stuff) {
                console.log("Ye");
                console.log(stuff);
            },
            "json"
        );
    },
    render: function() {
        return (
            <div>
                <h1>New issue comment</h1>
                <form method="post" onSubmit={this.createComment}>
                    <div className="input-field col s12">
                        <textarea className="materialize-textarea" placeholder="Comment" ref="comment"></textarea>
                        <label>Comment</label>
                    </div>
                    <button type="submit" className="waves-effect waves-light btn">Submit</button>
                </form>
            </div>
        );
    }
});
