import * as User from "./user";
import { createStore } from 'redux';

const store = createStore(User.updateUser);
