const dotenv = require("dotenv");
const fs = require('fs');
dotenv.config();

const express = require("express");
const bcrypt = require("bcryptjs");
const path = require("path");
var bodyParser = require("body-parser");
var admin = require("firebase-admin");
const { getStorage, getDownloadURL } = require('firebase-admin/storage');
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
        name: name,
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
        name: `${firstName} ${lastName}`,
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

    if (myVal) {
      for (groupID of myVal) {
        let group = await database
          .ref(`groups/${groupID}`)
          .once("value");
        group = group.val();
        group["id"] = groupID;
        retVal.push(group);
      }
    }

    res.send({
      groups: retVal,
    });
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

    for (member in memberInfo) {
      let myVal = await database
        .ref(`users`)
        .orderByChild("email")
        .equalTo(memberInfo[member])
        .once("value");
      myVal = myVal.val();
      if (myVal == null) {
        res.sendStatus(400);
        return;
      } else {
        for (key in myVal) {
          value.users.push(key);
        }
      }
    }

    let newKey = "";

    database
      .ref("groups")
      .push(value)
      .then((snapshot) => {
        newKey = snapshot.key;
      });

    for (userID of value.users) {
      let myVal = await database.ref(`users/${userID}/groups`).once("value");
      myVal = myVal.val();

      if (myVal == null) {
        database.ref(`users/${userID}/groups`).set([newKey]);
      } else {
        myVal.push(newKey);
        database.ref(`users/${userID}/groups`).set(myVal);
      }
    }

    res.sendStatus(200);
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
  .post("/getTrips", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let userID = req.body.userID;
    let myVal = await database.ref(`users/${userID}/trips`).once("value");
    myVal = myVal.val();
    retVal = [];

    if (myVal) {
      for (tripID of myVal) {
        let tripInfo = await database
          .ref(`trips/${tripID}`)
          .once("value");
        tripInfo = tripInfo.val();
        tripInfo["id"] = tripID;
        retVal.push(tripInfo);
      }
    }

    res.send({
      trips: retVal,
    });
  })
  .post("/getTripData", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let tripID = req.body.tripID;
    let myVal = await database.ref(`trips/${tripID}`).once("value");
    let retVal = {"trip": myVal.val()};
    for (userID of retVal.trip.users) {
      let myVal = await database.ref(`users/${userID}`).once("value");
      retVal[userID] = myVal.val();
    }
    
    res.send(retVal);
  })
  .post("/createTrip", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );
    let info = req.body;
    let userID = info.userID;
    let tripName = info.tripName;
    let memberInfo = info.memberInfo;
    let groupID = info.groupID;

    let myVal = await database
        .ref(`groups/${groupID}`)
        .once("value");
    myVal = myVal.val();

    const value = {
      name: tripName,
      users: myVal.users,
    };

    for (member in memberInfo) {
      let myVal = await database
        .ref(`users`)
        .orderByChild("email")
        .equalTo(memberInfo[member])
        .once("value");
      myVal = myVal.val();
      if (myVal == null) {
        res.sendStatus(400);
        return;
      } else {
        for (key in myVal) {
          value.users.push(key);
        }
      }
    }

    let newKey = "";

    database
      .ref("trips")
      .push(value)
      .then((snapshot) => {
        newKey = snapshot.key;
      });

    for (userID of value.users) {
      let myVal = await database.ref(`users/${userID}/trips`).once("value");
      myVal = myVal.val();

      if (myVal == null) {
        database.ref(`users/${userID}/trips`).set([newKey]);
      } else {
        myVal.push(newKey);
        database.ref(`users/${userID}/trips`).set(myVal);
      }
    }

    res.sendStatus(200);
  })
  .post("/fetchPOIData", async function (req, res) {
    res.setHeader("Access-Control-Allow-Origin", "https://www.squadzz.us");
    res.setHeader(
      "Access-Control-Allow-Methods",
      "GET, POST, OPTIONS, PUT, PATCH, DELETE"
    );

    let info = req.body;
    let latitude = info.latitude;

    // rushi's code here: //todo please populate the two variables below
    let best_lat = 0;
    let best_long = 0;

    // getting the place ids
    const spawn = require("child_process").spawn;
    const pythonProcess = spawn('python3', ["../python/find_place_ids.py", best_lat, best_long, "temp/place_ids.txt", 1000]);

    // collect place_ids from temp/place_ids.txt
    // const pids = [];
    const file = fs.readFile('temp/place_ids.txt', 'utf8');
    const lines = file.split('\n');
    for (const line of lines) {
      // pids.push(data);
      // get info for each place
      const pythonProcess = spawn('python3', ["..python/get_place_info.py", line]);
    }
    
    res.sendStatus(200);
  })
  .post("/uploadImage", async function(req, res) {
    // var defaultStorage = firebase.storage();
    const bucket = getStorage().bucket('squadzz.appspot.com');

    for (let i = 0; i < req.body.images.length; i++) {
      
      const blob = bucket.file(req);
      const blobStream = blob.createWriteStream({
        resumable: false,
      });

      blobStream.on("error", (err) => {
        res.status(500).send({ message: err.message });
      });

      let publicUrl;

      blobStream.on("finish", async (data) => {
        // Create URL for directly file access via HTTP.
        publicUrl = format(
          `https://storage.googleapis.com/${bucket.name}/${blob.name}`
        );

        // Make the file public
        await bucket.file(req.file.originalname).makePublic();

      }) 

      // adding uploaded pictures to the correct cluster
      const spawn = require("child_process").spawn;
      const pythonProcess = spawn('python3', ["../python/face_req.py", publicUrl, tripID]);
    }

    res.sendStatus(200);

  })
  .post("/getLatLong", async function(req, res) {
    //   const spawn = require("child_process").spawn;
    //   const pythonProcess = spawn('python3', ["../python/getCoord.py", addressFROMREQ]);

    //   let lat;
    //   let long;

    //   pythonProcess.stdout.on('data', (data) => {
    //     lat = data[0],
    //     long = data[1]
    //   });

    //   res.send({
    //     latitude: lat,
    //     longitude: long,
    //   });
    var BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json?address=";

    var address = fromreq;

    var url = BASE_URL + address + "&key=" + process.env.GOOGLE_MAPS_Api_KEY;

    let lat;
    let long;

    request(url, function (error, response, body) {
        if (!error && response.statusCode == 200) {
            lat = body.results[0].geometry.location.lat,
            long = body.results[0].geometry.location.lng
        }
    });
    res.send({
      latitude: lat,
      longitude: long,
    });
  })
  .listen(PORT, () => console.log(`Listening on ${PORT}`));