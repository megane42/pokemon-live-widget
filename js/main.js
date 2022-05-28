import              '../css/style.css'
import { Elm } from '../src/Main.elm'
import {
  subscribeBattleTeamMembers,
  setBattleTeamMember,
  deleteBattleTeamMembers,
  getPokemons,
  getTeamMembers,
  setTeamMember,
} from './firestore.js'

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

subscribeBattleTeamMembers(elmApp.ports.receiveBattleTeamPokemons.send);

console.log(await getPokemons())
console.log(await getTeamMembers())
// console.log(await setBattleTeamMember({ id: "bar", living: true, order: 99, teamMember: { id: "gHRfZU6eMeMMSCFRAN0s" }}))
// console.log(await setTeamMember({ id: "bar", pokemon: { id: "b1CdXPDL5djSvB8PjdNF" }}))
