// Import the functions you need from the SDKs you need
import { getAuth } from '@firebase/auth';
import { initializeApp } from 'firebase/app';
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: 'AIzaSyDblyYdsBDufvNkLQcWHeQxIYiUsGlc9_0',
  authDomain: 'ecomonitor-2a295.firebaseapp.com',
  projectId: 'ecomonitor-2a295',
  storageBucket: 'ecomonitor-2a295.appspot.com',
  messagingSenderId: '556815122778',
  appId: '1:556815122778:web:633d441fb72fab7596b363',
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
