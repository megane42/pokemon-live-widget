import              '../css/style.css'
import { Elm } from '../src/Main.elm'
import {
  subscribeBattleTeamMembers,
  deleteBattleTeamMembers,
  getPokemons,
  getTeamMembers,
} from './firestore.js'

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

subscribeBattleTeamMembers(elmApp.ports.receiveBattleTeamPokemons.send);

console.log(await getPokemons())
console.log(await getTeamMembers())
