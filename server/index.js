const dotenv = require("dotenv");
dotenv.config();

const express = require("express");
const bcrypt = require("bcryptjs");
const path = require("path");
var bodyParser = require("body-parser");
var admin = require("firebase-admin");
var serviceAccount = require("./" + process.env.FIREBASE_FILE);
const PORT = process.env.PORT || 80;

function hash(value) {
  let salt = bcrypt.genSaltSync(10);
  let hashVal = bcrypt.hashSync(value, salt);
  return hashVal;
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://squadzz-default-rtdb.firebaseio.com/",
});

let database = admin.database();

express()
  .use(express.static(path.join(__dirname, "build")))
  .use(express.json())
  .use(bodyParser.urlencoded({ extended: false }))
  .post("/userGoogleSignIn", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let profile = req.body;
    let email = profile.email;
    let name = profile.name;
    let myVal = await database
      .ref("users")
      .orderByChild("email")
      .equalTo(email)
      .once("value");
    myVal = myVal.val();
    if (!myVal) {
      database.ref("users").push({
        email: email,
        password: "",
        name: name
      });
    }
    myVal = await database
      .ref("users")
      .orderByChild("email")
      .equalTo(email)
      .once("value");
    myVal = myVal.val();
    for (key in myVal) {
      userKey = key;
    }
    let returnVal = {
      data: userKey,
      name: name,
      email: email,
    };
    res.send(returnVal);
  })
  .post("/userSignIn", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let info = req.body;
    let email = info.email;
    let password = info.password;
    let returnVal;
    let myVal = await database
      .ref("users")
      .orderByChild("email")
      .equalTo(email)
      .once("value");
    myVal = myVal.val();
    if (!myVal) {
      returnVal = {
        data: "Incorrect credentials.",
      };
    } else {
      let inputPassword = password;
      let userPassword;
      for (key in myVal) {
        userPassword = myVal[key].password;
      }
      if (bcrypt.compareSync(inputPassword, userPassword)) {
        for (key in myVal) {
          returnVal = {
            data: key,
            name: myVal[key].name,
            email: email,
          };
        }
      } else {
        returnVal = {
          data: "Incorrect credentials",
        };
      }
    }
    res.send(returnVal);
  })
  .post("/userSignUp", async function (req, res) {
    let info = req.body;
    let email = info.email;
    let firstName = info.firstname;
    let lastName = info.lastname;
    let password = info.password;
    let passwordConfirm = info.passwordconfirm;
    let returnVal;
    if (!email) {
      returnVal = {
        data: "Please enter an email address.",
        success: false,
      };
      res.send(returnVal);
      return;
    }
    let myVal = await database
      .ref("users")
      .orderByChild("email")
      .equalTo(email)
      .once("value");
    myVal = myVal.val();
    if (myVal) {
      returnVal = {
        data: "Email already exists.",
        success: false,
      };
    } else if (firstName.length == 0 || lastName.length == 0) {
      returnVal = {
        data: "Invalid Name",
        success: false,
      };
    } else if (
      !(
        /^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(
          firstName
        ) &&
        /^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u.test(
          lastName
        )
      )
    ) {
      returnVal = {
        data: "Invalid Name",
        success: false,
      };
    } else if (
      !/(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/.test(
        email
      )
    ) {
      returnVal = {
        data: "Invalid email address.",
        success: false,
      };
    } else if (password.length < 6) {
      returnVal = {
        data: "Your password needs to be at least 6 characters.",
        success: false,
      };
    } else if (password != passwordConfirm) {
      returnVal = {
        data: "Your passwords don't match.",
        success: false,
      };
    } else {
      const value = {
        email: email,
        password: hash(password),
        name: `${firstName} ${lastName}`
      };
      database.ref("users").push(value);
      myVal = await database
        .ref("users")
        .orderByChild("email")
        .equalTo(email)
        .once("value");
      myVal = myVal.val();
      for (key in myVal) {
        userKey = key;
      }
      returnVal = {
        success: true,
        data: key,
        name: `${firstName} ${lastName}`,
        email: email,
      };
    }
    res.send(returnVal);
  })
  .post("/getGroups", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let userID = req.body.userID;
    let myVal = await database.ref(`users/${userID}/groups`).once("value");
    myVal = myVal.val();
    retVal = [];

    for (groupID in myVal) {
      let groupName = await database
        .ref(`groups/${groupID}/name`)
        .once("value");
      retVal.push({
        id: groupID,
        name: groupName,
      });
    }

    res.send({
      groups: retVal,
    });
  })
  .post("/checkForUser", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let info = req.body;
    let email = info.email;
    let myVal = await database
      .ref("users")
      .orderByChild("email")
      .equalTo(email)
      .once("value");
    myVal = myVal.val();
    if (!myVal) {
      res.send({
        data: false,
      });
    } else {
      res.send({
        data: true,
      });
    }
  })
  .post("/createGroup", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let info = req.body;
    let userID = info.userID;
    let groupName = info.groupName;
    let memberInfo = info.memberInfo;

    const value = {
      name: groupName,
      users: [userID],
    };

    let retVal = {};

    database.ref("groups").push(value).then((snapshot) => {
        retVal.key = snapshot.key;
    });

    let myVal = await database.ref(`users/${userID}/groups`).once("value");
    myVal = myVal.val();

    if (myVal == null){
        database.ref(`users/${userID}/groups`).set([retVal.key]);
    } else{
        myVal.push(retVal.key);
        database.ref(`users/${userID}/groups`).set(myVal);
    }

    res.send(retVal);
  })
  .listen(PORT, () => console.log(`Listening on ${PORT}`));
