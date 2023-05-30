document
  .querySelector("form")
  .addEventListener("submit", async function (event) {
    event.preventDefault();
    const dateinput = document.getElementById("date").value;
    console.log(typeof dateinput, dateinput);
  });
