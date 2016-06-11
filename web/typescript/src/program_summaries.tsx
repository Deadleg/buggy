import * as React from "react";
import * as ReactDOM from "react-dom";
import { ProgramParams } from "./model/router_params";
import { ProgramSummary } from "./model/types";
import { RouteComponentProps } from "react-router";

export interface ProgramSummariesProps extends RouteComponentProps<ProgramParams, any> {
    summaries: ProgramSummary[];
}

export class ProgramSummaries extends React.Component<ProgramSummariesProps, any> {
    constructor(props: ProgramSummariesProps) {
        super(props);

        this.state = {
        }
    }

    render() {
        var self = this;

        var children = this.props.summaries.map((summary: ProgramSummary) => {
            return (
                <div className="card">
                    <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid card-img-top"/>
                    <div className="card-block">
                        <p className="card-text">{summary.name}</p>
                    </div>
                </div>
            );
        });

        return (
            <div className="row">
                <div className="col-sm-3">
                    { children } 
                </div>
            </div>
        );
    }
};