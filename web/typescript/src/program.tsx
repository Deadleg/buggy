import * as React from "react";
import { ProgramParams } from "./model/router_params";
import { Link, RouteComponentProps } from "react-router";

export interface ProgramProps extends RouteComponentProps<ProgramParams, any> {
}

export class Program extends React.Component<ProgramProps, any> {
    constructor(props: ProgramProps) {
        super(props);

        this.state =
            {
                program: {
                    name: "",
                    id: 0,
                    issues: 0
                }
            }
    }

    componentDidMount() {
        var self = this;

        $.getJSON("/api/programs/" + this.props.params.programId, function(data) {
            console.log(data);
            self.setState({program: data});
        });
    }
    
    render() {
        return (
            <div>
                <div className="banner">
                    <div className="container">
                        <div className="row">
                            <div className="col-sm-3 vertical-flex-parent">
                                <div style={{"width": "100%"}}>
                                    <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid"/>
                                </div>
                            </div>
                            <div className="col-sm-9 banner-body">
                                <h4 className="card-title"><Link to={"/app/" + this.props.params.programId + "/issue"}>{this.state.program.name}</Link></h4>
                                <p>Issues: {this.state.program.issues}</p>
                                <button className="btn btn-common"><Link to={"/app/" + this.props.params.programId + "/issue/new"}>Create an issue</Link></button>
                            </div>
                        </div>
                    </div>
                </div>
                {this.props.children}
            </div>
        );
    }
};
