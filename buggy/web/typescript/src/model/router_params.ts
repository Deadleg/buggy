export interface ProgramParams {
    programId: string;
}

export interface IssueParams extends ProgramParams {
    issueId: string;
}

export interface ReportParams extends IssueParams {
    reportId: string;
}