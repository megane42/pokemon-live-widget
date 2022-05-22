import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, getDocs, getDoc, deleteDoc } from "firebase/firestore";

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

const teamSelectionsCollectionRef       = collection(db, "teamSelections");
const battleTeamSelectionsCollectionRef = collection(db, "battleTeamSelections");

const subscribeBattleTeamSelection = async (onChangeHandler) => {
  const unsub = onSnapshot(battleTeamSelectionsCollectionRef, async (battleTeamSelectionsQuerySnapshot) => {
    const battleTeam = await Promise.all(
      battleTeamSelectionsQuerySnapshot.docs.map(async (battleTeamSelectionDocumentSnapshot) => {
        const teamSelectionDocumentRef      = battleTeamSelectionDocumentSnapshot.data().teamSelection;
        const teamSelectionDocumentSnapshot = await getDoc(teamSelectionDocumentRef);
        const pokemonDocumentRef            = teamSelectionDocumentSnapshot.data().pokemon;
        const pokemonDocumentSnapshot       = await getDoc(pokemonDocumentRef);
        return {
          ...battleTeamSelectionDocumentSnapshot.data(),
          teamSelection: {
            ...teamSelectionDocumentSnapshot.data(),
            pokemon: pokemonDocumentSnapshot.data(),
          },
        };
      }),
    )
    console.log(JSON.stringify(battleTeam));
    onChangeHandler(1); // TODO: pass battleTeam
  })
}

const deleteBattleTeamSelections = async () => {
  const battleTeamSelectionsQuerySnapshot = await getDocs(battleTeamSelectionsCollectionRef);
  for (let battleTeamSelectionDocumentSnapshot of battleTeamSelectionsQuerySnapshot.docs) {
    const battleTeamSelectionDocumentRef = battleTeamSelectionDocumentSnapshot.ref
    await deleteDoc(battleTeamSelectionDocumentRef);
  };
}

const getTeam = async () => {
  const teamSelectionsQuerySnapshot = await getDocs(teamSelectionsCollectionRef);
  return await Promise.all(
    teamSelectionsQuerySnapshot.docs.map(async (teamSelectionDocumentSnapshot) => {
      const pokemonDocumentRef      = teamSelectionDocumentSnapshot.data().pokemon;
      const pokemonDocumentSnapshot = await getDoc(pokemonDocumentRef);
      return {
        ...teamSelectionDocumentSnapshot.data(),
        pokemon: pokemonDocumentSnapshot.data(),
      };
    }),
  );
}

export { subscribeBattleTeamSelection, deleteBattleTeamSelections, getTeam }
