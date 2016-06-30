import { SIGNIN_USER } from "./actions";

export interface Action {}

export interface SigninUser extends Action {
    type: string;
    user: UserState;
}

export interface UserState {
    username: string;
    id: number;
}

export interface StoreState {
    user: UserState
}

const initialState: StoreState = {
    user: null
}

export function signinUser(user : UserState): SigninUser {
    return {
        type: SIGNIN_USER,
        user: user
    }
}

export function updateUser(state = initialState, action) {
    switch (action.type) {
        case SIGNIN_USER:
            return Object.assign({}, state, {
                user: action.user,
            })
        default:
            return state;
    }
}

