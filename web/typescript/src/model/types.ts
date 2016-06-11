export interface IssueSummary {
    issueId: number;
    title: string;
}

export interface ProgramSummary {
    topIssues: IssueSummary[];
    numberOfIssuesThiWeek: number;
    name: string;
}