// Retrieve todo from local storage or initialize an empty array
let todo = JSON.parse(localStorage.getItem("todo")) || [];
const todoInput = document.getElementById("todoInput");
const todoList = document.getElementById("todoList");
const todoCount = document.getElementById("todoCount");
const addButton = document.querySelector(".btn");
const deleteButton = document.getElementById("deleteButton");

// Initialize
document.addEventListener("DOMContentLoaded", function () {
  addButton.addEventListener("click", addTask);
  todoInput.addEventListener("keydown", function (event) {
    if (event.key === "Enter") {
      event.preventDefault(); // Prevents default Enter key behavior
      addTask();
    }
  });
  deleteButton.addEventListener("click", deleteAllTasks);
  displayTasks();
});

const apiBaseUrl = 'http://todo-app-lb-912273965.us-east-1.elb.amazonaws.com';

function addTask() {
  const newTask = todoInput.value.trim();
  if (newTask !== "") {
    fetch(`${apiBaseUrl}/todos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ text: newTask, disabled: false })
    })
      .then(response => response.json())
      .then(data => {
        todo.push(data);
        saveToLocalStorage();
        todoInput.value = "";
        displayTasks();
      })
      .catch(error => console.error('Error:', error));
  }
}

function displayTasks() {
  todoList.innerHTML = "";
  fetch(`${apiBaseUrl}/todos`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  })
    .then(response => response.json())
    .then(data => {
      todo = data;
      todo.forEach((item, index) => {
        const p = document.createElement("p");
        p.innerHTML = `
          <div class="todo-container">
            <input type="checkbox" class="todo-checkbox" id="input-${index}" ${item.disabled ? "checked" : ""
          }>
            <p id="todo-${index}" class="${item.disabled ? "disabled" : ""
          }" onclick="editTask(${index})">${item.text}</p>
          </div>
        `;
        p.querySelector(".todo-checkbox").addEventListener("change", () =>
          toggleTask(index)
        );
        todoList.appendChild(p);
      });
      todoCount.textContent = todo.length;
    })
    .catch(error => console.error('Error:', error));
}

function toggleTask(index) {
  todo[index].disabled = !todo[index].disabled;
  saveToLocalStorage();
  displayTasks();
}

function deleteAllTasks() {
  todo = [];
  saveToLocalStorage();
  displayTasks();
}

function saveToLocalStorage() {
  localStorage.setItem("todo", JSON.stringify(todo));
}
