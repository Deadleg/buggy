import * as React from "react";
import { ProgramParams } from "./model/router_params";
import { connect } from "react-redux";
import { Link, RouteComponentProps } from "react-router";

declare var Chart;

export interface IssuesProps extends RouteComponentProps<ProgramParams, any> {
}

export class Issues extends React.Component<any, any> {
    constructor(props: IssuesProps) {
        super(props);

        this.state = {programId: this.props.params.programId, issues: [], stats: {}};
    }

    componentDidMount() {
        var self = this;

        $.getJSON("/api/programs/" + this.props.params.programId + "/issues", function(data) {
            self.setState({issues: data});
        });

        $.getJSON("/api/programs/" + this.props.params.programId + "/stats", function(data) {
            console.log(data);

            var element = document.getElementById('stats');
            var chart = new Chart(element, {
                type: 'line',
                data: {
                    labels: data.times,
                    datasets: [{
                        label: 'Issues reported',
                        data: data.created,
                        borderColor: 'rgba(207, 75, 84, 0.8)',
                        backgroundColor: 'rgba(207, 75, 84, 0.1)'
                    },{
                        label: 'Issues fixed',
                        data: data.fixed,
                        borderColor: 'rgba(75, 160, 207, 0.8)',
                        backgroundColor: 'rgba(75, 160, 207, 0.1)'
                    },{
                        label: 'Total open issues',
                        data: data.cumulativeIssues,
                        borderColor: 'rgba(75, 207, 155, 0.8)',
                        backgroundColor: 'rgba(75, 207, 155, 0.1)'
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        yAxes: [{
                            ticks: {
                                beginAtZero:true
                            }
                        }],
                        xAxes: [{
                            type: 'time',
                            time: {
                                displayFormats: {
                                    month: 'MMM'
                                }
                            }
                        }]
                    },
                    title: {
                        display: true,
                        text: 'Issues created and fixed per month'
                    }
                }
            });

            var element2 = document.getElementById('status-graph');
            var chart2 = new Chart(element2, {
                type: 'pie',
                data: {
                    labels: data.statusTypes,
                    datasets: [{
                        label: 'Issues reported',
                        data: data.statusNumbers,
                        borderColor: ['rgba(207, 75, 84, 0.8)', 'rgba(75, 160, 207, 0.8)', 'rgba(75, 207, 155, 0.8)', 'rgba(155, 75, 207, 0.8)', 'rgba(207, 89, 75, 0.8)'],
                        backgroundColor: ['rgba(207, 75, 84, 0.2)', 'rgba(75, 160, 207, 0.2)', 'rgba(75, 207, 155, 0.2)', 'rgba(155, 75, 207, 0.2)', 'rgba(207, 89, 75, 0.2)']
                    }]
                },
                options: {
                    responsive: true,
                    title: {
                        display: true,
                        text: 'Issue types'
                    }
                }
            });
            self.setState({stats: data});
        });
    }
    
    render() {
        var self = this;
        var content = this.state.issues.map(function (issue, index) {
            return (
                <div key={index} className="bottom-margin-md">
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
                        <span className="label border-red">{issue.type}</span>
                        <span className="label border-blue">{issue.status}</span>
                    </div>
                    <p className="card-text">
                        <small>
                            {issue.reporter.username} reported on {moment(issue.time).format("DD-MM-YYYY")}
                        </small>
                    </p>
                </div>
            );
        });

        return (
            <div className="container bottom-margin-md">
                <div className="row">
                    <div className="col-sm-12 bottom-margin-md">
                        <div className="row">
                            <div className="col-sm-4">
                                <canvas id="stats" width="100" height="100"></canvas>
                            </div>
                            <div className="col-sm-4 vertical-flex-parent" style={{"height": "354px"}}>
                                <div>
                                    <h5 className="text-sm-center">Total issues</h5>
                                    <p className="text-sm-center">523</p>
                                    <h5 className="text-sm-center">Issues reported in the last month</h5>
                                    <p className="text-sm-center">125</p>
                                    <h5 className="text-sm-center">Issues fixed in the last month</h5>
                                    <p className="text-sm-center">52</p>
                                </div>
                            </div>
                            <div className="col-sm-4">
                                <canvas id="status-graph" width="100" height="100"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-3 bottom-margin-md">
                        {content}
                    </div>
                    <div className="col-sm-9 bottom-margin-md">
                        {this.props.children}
                    </div>
                </div>
            </div>
        );
    }
};

const mapStateToProps = (state) => {
    return {
        user: state.user
    }
}

export const IssuesContainer = connect(mapStateToProps)(Issues);
