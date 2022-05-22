import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, getDocs, getDoc, deleteDoc } from "firebase/firestore";

const firebaseConfig = {
  apiKey:            "AIzaSyD9YxMW-T75dZ-pm1QcxjZd6Jt_Yy82aVg",
  authDomain:        "pokemon-live-widget.firebaseapp.com",
  projectId:         "pokemon-live-widget",
  storageBucket:     "pokemon-live-widget.appspot.com",
  messagingSenderId: "123902109283",
  appId:             "1:123902109283:web:4e95b1ab2100d3ad11fa56"
};

const firebaseApp = initializeApp(firebaseConfig);
const db          = getFirestore(firebaseApp);

const teamMembersCollectionRef       = collection(db, "teamMembers");
const battleTeamMembersCollectionRef = collection(db, "battleTeamMembers");

const subscribeBattleTeamMembers = async (onChangeHandler) => {
  const unsub = onSnapshot(battleTeamMembersCollectionRef, async (battleTeamMembersQuerySnapshot) => {
    const battleTeamMembers = await Promise.all(
      battleTeamMembersQuerySnapshot.docs.map(async (battleTeamMemberDocumentSnapshot) => {
        const teamMemberDocumentRef      = battleTeamMemberDocumentSnapshot.data().teamMember;
        const teamMemberDocumentSnapshot = await getDoc(teamMemberDocumentRef);
        const pokemonDocumentRef         = teamMemberDocumentSnapshot.data().pokemon;
        const pokemonDocumentSnapshot    = await getDoc(pokemonDocumentRef);
        return {
          ...battleTeamMemberDocumentSnapshot.data(),
          teamMember: {
            ...teamMemberDocumentSnapshot.data(),
            pokemon: pokemonDocumentSnapshot.data(),
          },
        };
      }),
    )
    console.log(JSON.stringify(battleTeamMembers));
    onChangeHandler(1); // TODO: pass battleTeam
  })
}

const getTeamMembers = async () => {
  const teamMembersQuerySnapshot = await getDocs(teamMembersCollectionRef);
  return await Promise.all(
    teamMembersQuerySnapshot.docs.map(async (teamMemberDocumentSnapshot) => {
      const pokemonDocumentRef      = teamMemberDocumentSnapshot.data().pokemon;
      const pokemonDocumentSnapshot = await getDoc(pokemonDocumentRef);
      return {
        ...teamMemberDocumentSnapshot.data(),
        pokemon: pokemonDocumentSnapshot.data(),
      };
    }),
  );
}

const deleteBattleTeamMembers = async () => {
  const battleTeamMembersQuerySnapshot = await getDocs(battleTeamMembersCollectionRef);
  for (let battleTeamMemberDocumentSnapshot of battleTeamMembersQuerySnapshot.docs) {
    const battleTeamMemberDocumentRef = battleTeamMemberDocumentSnapshot.ref
    await deleteDoc(battleTeamMemberDocumentRef);
  };
}

export { subscribeBattleTeamMembers, deleteBattleTeamMembers, getTeamMembers }
