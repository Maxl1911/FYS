// Create function validateform
function validateForm(){
    let x = document.forms["loginform"]["uname"].value; // Gets value from the form
    if (x == "100") {
      
    } else if (x == ""){
      var paragraph = document.getElementById("p");
      paragraph.textContent = "Username must be filled";
      return false;          
    } else  {
      var paragraph = document.getElementById("p");
      paragraph.textContent = "Username & password combination is not correct";
      return false; 
    }

    let y = document.forms["loginform"]["psw"].value;
    if (y == "testpw") { 
    } else if (x == ""){
      var paragraph = document.getElementById("p");
      paragraph.textContent = "password must be filled";
      return false;          
    } else  {
      var paragraph = document.getElementById("p");
      paragraph.textContent = "Username & password combination is not correct";
      return false; 
    }
    //sets an session variable to check if logged in.
    sessionStorage.setItem('status','loggedIn');
  }

