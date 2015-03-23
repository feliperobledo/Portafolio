var currDate;

var userInput = [];

function addUserInputToArray() {
  console.log("user input!");
  var lineEdit = document.GetElementById("lineEdit");

  // the following line should add the new user input to our
  //   array.
  userInput[userInput.length] = 0;
}

//The browser doesn't care that they are seperate files or not
var Person = function(name) {
  this.name = name
}

function myFunction() {
  //The \ character at the end  says that the line continues
  var arr1 = ["one","two"];
  var str = "three";

  document.getElementById("demo").innerHTML = arr1.concat(str);

  //so there is such a thing as ===, which checks for
  // type and value to be the same.

  //turns out that objects cannot be compared
}

function helloWorld() {
  document.getElementById("demo").innerHTML = "Hello \
   World.";
}

function logTest() {
  console.log(5 + 6);
}

function writeOnButton(id) {
  document.getElementById(id).innerHTML = "HIT!";
}

function displayDate() {
  currDate = new Date();
  document.getElementById("timeDisplay").innerHTML = currDate;
}
