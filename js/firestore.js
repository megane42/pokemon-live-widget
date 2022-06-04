import { initializeApp } from 'firebase/app';
import { getFirestore, doc, collection, onSnapshot, getDocs, getDoc, setDoc, deleteDoc } from "firebase/firestore";

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

const pokemonsCollectionRef          = collection(db, "pokemons");
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
          id: battleTeamMemberDocumentSnapshot.id,
          ...battleTeamMemberDocumentSnapshot.data(),
          teamMember: {
            id: teamMemberDocumentSnapshot.id,
            ...teamMemberDocumentSnapshot.data(),
            pokemon: {
              id: pokemonDocumentSnapshot.id,
              ...pokemonDocumentSnapshot.data(),
            }
          },
        };
      }),
    )
    console.log(battleTeamMembers);
    onChangeHandler(battleTeamMembers);
  })
}

const setBattleTeamMember = async (battleTeamMember) => {
  const battleTeamMemberDocumentRef = battleTeamMember.id == "__RANDOM_ID__"
                                    ? doc(battleTeamMembersCollectionRef)
                                    : doc(db, "battleTeamMembers", battleTeamMember.id);
  const teamMemberDocumentRef       = doc(db, "teamMembers", battleTeamMember.teamMember.id);

  await setDoc(battleTeamMemberDocumentRef, {
    living:     battleTeamMember.living,
    order:      battleTeamMember.order,
    teamMember: teamMemberDocumentRef,
  });
}

const deleteBattleTeamMembers = async () => {
  const battleTeamMembersQuerySnapshot = await getDocs(battleTeamMembersCollectionRef);
  for (let battleTeamMemberDocumentSnapshot of battleTeamMembersQuerySnapshot.docs) {
    const battleTeamMemberDocumentRef = battleTeamMemberDocumentSnapshot.ref
    await deleteDoc(battleTeamMemberDocumentRef);
  };
}

const subscribeTeamMembers = async (onChangeHandler) => {
  const unsub = onSnapshot(teamMembersCollectionRef, async (teamMembersQuerySnapshot) => {
    const teamMembers = await Promise.all(
      teamMembersQuerySnapshot.docs.map(async (teamMemberDocumentSnapshot) => {
        const pokemonDocumentRef      = teamMemberDocumentSnapshot.data().pokemon;
        const pokemonDocumentSnapshot = await getDoc(pokemonDocumentRef);
        return {
          id: teamMemberDocumentSnapshot.id,
          ...teamMemberDocumentSnapshot.data(),
          pokemon: {
            id: pokemonDocumentSnapshot.id,
            ...pokemonDocumentSnapshot.data(),
          },
        };
      }),
    );
    console.log(teamMembers);
    onChangeHandler(teamMembers);
  })
}

const setTeamMember = async (teamMember) => {
  const teamMemberDocumentRef = teamMember.id == "__RANDOM_ID__"
                              ? doc(teamMembersCollectionRef)
                              : doc(db, "teamMembers", teamMember.id);
  const pokemonDocumentRef    = doc(db, "pokemons", teamMember.pokemon.id);
  await setDoc(teamMemberDocumentRef, {
    pokemon: pokemonDocumentRef,
  });
}

const subscribePokemons = async (onChangeHandler) => {
  const unsub = onSnapshot(pokemonsCollectionRef, async (pokemonsQuerySnapshot) => {
    const pokemons = pokemonsQuerySnapshot.docs.map(
      pokemonDocumentSnapshot => {
        return {
          id: pokemonDocumentSnapshot.id,
          ...pokemonDocumentSnapshot.data(),
        }
      }
    );
    console.log(pokemons);
    onChangeHandler(pokemons);
  })
}

export {
  subscribeBattleTeamMembers,
  setBattleTeamMember,
  deleteBattleTeamMembers,
  subscribeTeamMembers,
  setTeamMember,
  subscribePokemons,
}
