import 'sanitize.css';
import              '../css/style.css'
import { Elm } from '../src/Main.elm'
import {
  subscribeBattleTeamMembers,
  setBattleTeamMember,
  deleteBattleTeamMembers,
  subscribeTeamMembers,
  setTeamMember,
  subscribePokemons,
} from './firestore.js'

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

elmApp.ports.setBattleTeamMember.subscribe((battleTeamMember) => {
  setBattleTeamMember(battleTeamMember)
})

elmApp.ports.deleteBattleTeamMember.subscribe(() => {
  deleteBattleTeamMembers()
})

elmApp.ports.setTeamMember.subscribe((teamMember) => {
  setTeamMember(teamMember)
})

subscribeBattleTeamMembers(elmApp.ports.getBattleTeamMembers.send);
subscribeTeamMembers(elmApp.ports.getTeamMembers.send);
subscribePokemons(elmApp.ports.getPokemons.send);
