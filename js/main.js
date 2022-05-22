import              '../css/style.css'
import { Elm } from '../src/Main.elm'
import {
  subscribeBattleTeamMembers,
  deleteBattleTeamMembers,
} from './firestore.js'

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

subscribeBattleTeamMembers(elmApp.ports.receiveBattleTeamPokemons.send);
