import * as React from "react";
import { IssueParams } from "./model/router_params";
import { Link, RouteComponentProps } from "react-router"
import { Comment } from "./comment";
import { ReportComment } from "./report_comment";
import { Tab, Tabs, TabList, TabPanel } from "react-tabs";

export interface GamesProps extends RouteComponentProps<{}, any> {}

export class Games extends React.Component<GamesProps, any> {
    constructor(props: GamesProps) {
        super(props);

        this.state = {
            programs: [],
        }
    }

    componentDidMount() {
        var self = this;

        $.getJSON("/api/programs", function(data) {
            console.log(data);
            self.setState({ programs: data });
        });
    }
    
    render() {
        var programs = this.state.programs.map((program, index) => {
            return (
                <div className="col-sm-3" key={index}>
                    <div className="card card-light">
                        <img src="http://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg?t=1452221296" className="img-fluid card-img-top"/>
                        <div className="card-block-no-padding">
                            <h4 className="card-title"><Link to={"/app/" + program.id + "/issue"}>{program.name}</Link></h4>
                            <p className="card-text">Issues: {program.issues}</p>
                        </div>
                    </div>
                </div>
            )
        });
        return (
            <div className="container bottom-margin-md">
                <div className="row">
                    {programs}
                </div>
            </div>
        );
    }
};
