//sticky header

window.onscroll = function () {
  myFunction();
};
var header = document.getElementById("myHeader");
// Get the offset position of the navbar
var sticky = header.offsetTop;

function myFunction() {
  if (window.pageYOffset > sticky) {
    header.classList.add("sticky");
  } else {
    header.classList.remove("sticky");
  }
}

//COA img modal
// var coaModal = document.getElementById("coaModal");

// var img = document.getElementById("coaCopy");

// var coaModalImg = document.getElementById("coaIMG");

// img.onclick = function () {
//   coaModal.style.display = "block";
//   coaModalImg.src = this.src;
// }
// var span = document.getElementsByClassName("close2")[0];

// span.onclick = function () {
//   modals.style.display = "none";
// }

//end of COA Modal IMG

//sets the exit pop-up CTA
var modal = document.getElementById("myModal");
var span = document.getElementsByClassName("close")[0];
var emailForm = document.getElementById("emailForm");
var inputBox = document.getElementById("inputEmailBox");

document.addEventListener(
  "mouseleave",
  function (e) {
    if (e.clientY < 0) {
      console.log(e);
      modal.style.display = "block";
    }
  },
  false
);

span.onclick = function () {
  modal.style.display = "none";
};

window.onclick = function (event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
};

//scroll back to the top functions
window.onscroll = function () {
  scrollFunction();
};

function scrollFunction() {
  if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
    document.getElementById("topBtn").style.display = "block";
  } else {
    document.getElementById("topBtn").style.display = "none";
  }
}

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
  document.body.scrollTop = 0; // For Safari
  document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
}

//Nav Slider
/* Open when someone clicks on the span element */
function openNav() {
  document.getElementById("myNav").style.width = "100%";
}

/* Close when someone clicks on the "x" symbol inside the overlay */
function closeNav() {
  document.getElementById("myNav").style.width = "0%";
}



