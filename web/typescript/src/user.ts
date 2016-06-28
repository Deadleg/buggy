import * as actions from "./actions";

export interface SigninUser {
    type: string;
    userdata: any;
}

interface UserState {
    name: string;
    id: number;
}

const initialState: UserState = {
    name: null,
    id: null
}

export function signinUser(userdata): SigninUser {
    return {
        type: actions.SIGNIN_USER,
        userdata: userdata
    }
}

export function updateUser(state = initialState, action) {
    switch (action.type) {
        case actions.SIGNIN_USER:
            return Object.assign({}, state, {
                name: action.userdata.username,
                id: action.userdata.id
            })
        default:
            return state;
    }
}

