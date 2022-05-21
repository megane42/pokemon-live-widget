import './style.css'
import { Elm } from './src/Main.elm'
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, getDocs, getDoc, deleteDoc } from "firebase/firestore";

const root = document.querySelector("#app");
const elmApp = Elm.Main.init({ node: root })

const firebaseConfig = {
  apiKey: "AIzaSyD9YxMW-T75dZ-pm1QcxjZd6Jt_Yy82aVg",
  authDomain: "pokemon-live-widget.firebaseapp.com",
  projectId: "pokemon-live-widget",
  storageBucket: "pokemon-live-widget.appspot.com",
  messagingSenderId: "123902109283",
  appId: "1:123902109283:web:4e95b1ab2100d3ad11fa56"
};

const firebaseApp = initializeApp(firebaseConfig);
const db          = getFirestore(firebaseApp);

const subscribeBattleTeamSelection = async (onChangeHandler) => {
  const battleTeamSelectionsCollectionRef = collection(db, "battleTeamSelections");
  const unsub = onSnapshot(battleTeamSelectionsCollectionRef, async (battleTeamSelectionsQuerySnapshot) => {
    let battleTeamPokemons = [];
    for (let battleTeamSelectionDocumentSnapshot of battleTeamSelectionsQuerySnapshot.docs) {
      const teamSelectionDocumentRef      = battleTeamSelectionDocumentSnapshot.data().teamSelection;
      const teamSelectionDocumentSnapshot = await getDoc(teamSelectionDocumentRef);
      const pokemonDocumentRef            = teamSelectionDocumentSnapshot.data().pokemon;
      const pokemonDocumentSnapshot       = await getDoc(pokemonDocumentRef);
      battleTeamPokemons.push(pokemonDocumentSnapshot.data());
    };
    console.log(battleTeamPokemons);
    onChangeHandler(1);
  });
};

subscribeBattleTeamSelection(elmApp.ports.receiveBattleTeamPokemons.send);

const deleteBattleTeamSelections = async () => {
  const battleTeamSelectionsCollectionRef = collection(db, "battleTeamSelections");
  const battleTeamSelectionsQuerySnapshot = await getDocs(battleTeamSelectionsCollectionRef);
  for (let battleTeamSelectionDocumentSnapshot of battleTeamSelectionsQuerySnapshot.docs) {
    const battleTeamSelectionDocumentRef = battleTeamSelectionDocumentSnapshot.ref
    await deleteDoc(battleTeamSelectionDocumentRef);
  };
}
