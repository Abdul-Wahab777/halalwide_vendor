importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBB72aLkBBeE6GFtLuNz_SXSddwm7zuNyY",
  authDomain: "halalwide.firebaseapp.com",
  projectId: "halalwide",
  storageBucket: "halalwide.appspot.com",
  messagingSenderId: "901157018784",
  appId: "1:901157018784:web:afd7a7b1262bf264f2fdc5",
  measurementId: "G-H94KRRZ3SB",
databaseURL: "...",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});