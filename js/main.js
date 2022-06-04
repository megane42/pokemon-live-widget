import              '../css/style.css'
import { Elm } from '../src/Main.elm'
import {
  subscribeBattleTeamMembers,
  setBattleTeamMember,
  deleteBattleTeamMembers,
  getTeamMembers,
  setTeamMember,
  getPokemons,
} from './firestore.js'

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

elmApp.ports.setBattleTeamMember.subscribe((battleTeamMember) => {
  setBattleTeamMember(battleTeamMember)
})

subscribeBattleTeamMembers(elmApp.ports.receiveBattleTeamPokemons.send);
