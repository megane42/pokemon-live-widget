import              '../css/style.css'
import { Elm } from '../src/Main.elm'
import {
  subscribeBattleTeamMembers,
  setBattleTeamMembers,
  deleteBattleTeamMembers,
  getPokemons,
  getTeamMembers,
} from './firestore.js'

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

subscribeBattleTeamMembers(elmApp.ports.receiveBattleTeamPokemons.send);

console.log(await getPokemons())
console.log(await getTeamMembers())
console.log(await setBattleTeamMembers([{ id: "foo", living: true, order: 99, teamMember: { id: "gHRfZU6eMeMMSCFRAN0s" }}]))
