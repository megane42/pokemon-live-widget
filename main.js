import './style.css'
import { Elm } from './src/Main.elm'
import {
  subscribeBattleTeamSelection,
  deleteBattleTeamSelections,
} from './firestore.js'

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

subscribeBattleTeamSelection(elmApp.ports.receiveBattleTeamPokemons.send);
