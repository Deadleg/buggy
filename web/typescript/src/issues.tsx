import * as React from "react";
import { ProgramParams } from "./model/router_params";
import { Link, RouteComponentProps } from "react-router";

declare var Chart;

export interface IssuesProps extends RouteComponentProps<ProgramParams, any> {
}

export class Issues extends React.Component<IssuesProps, any> {
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
                        <span className="label label-default">{issue.type}</span>
                        <span className="label label-default">{issue.status}</span>
                    </div>
                    <p className="card-text">
                        <small>
                            Reported on {moment(issue.time).format("DD-MM-YYYY")}
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
                            <div className="col-sm-4 bottom-margin-md">
                                <canvas id="stats" width="100" height="100"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-6 bottom-margin-md">
                        {content}
                    </div>
                </div>
            </div>
        );
    }
};
