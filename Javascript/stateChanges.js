var currState = 0;

var states = ["Start", "Middle", "End"];

function changeState() {
  ++currState;
  if(currState >= states.length || currState < 0)
  {
    console.log("State Overflow. Restarting sequence.")
    currState = 0;
  }

  displayState();

  onStateChange();
}

function displayState() {
  document.getElementById("stateDisplay").innerHTML = states[currState];
}

function onStateChange() {
  switch(currState)
  {
    case 0:
      break;
    case 1:
      break;
    case 2:
      break;
    default:
      console.log("Invalid state");
  }
}
