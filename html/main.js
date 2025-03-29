function populateLiveries(state) {
  const container = document.getElementById("liveries-container");
  container.innerHTML = ""; // Clear existing liveries

  if (!state || !state.livery) return;

  const { current, count, names } = state.livery;

  // Add regular liveries if available
  if (count > 0) {
    for (let i = 0; i < count; i++) {
      const button = document.createElement("button");
      button.className = `livery-item${current === i ? " active" : ""}`;
      button.textContent = names[i] || `Livery ${i + 1}`;
      button.dataset.liveryIndex = i;
      button.dataset.isRoof = "false";

      button.addEventListener("click", () => {
        // Remove active class from all livery buttons
        document
          .querySelectorAll(".livery-item")
          .forEach((btn) => btn.classList.remove("active"));
        // Add active class to clicked button
        button.classList.add("active");

        // Send livery update to FiveM
        fetch(`https://qr-extramenu/changeLivery`, {
          method: "POST",
          body: JSON.stringify({
            liveryIndex: i,
            isRoof: false,
          }),
        });
      });

      container.appendChild(button);
    }
  }

  // Add roof liveries if available
  if (state.livery.roof && state.livery.roof.count > 0) {
    const roofLiveriesHeader = document.createElement("h3");
    roofLiveriesHeader.className = "category-header";
    roofLiveriesHeader.textContent = "Roof Liveries";
    container.appendChild(roofLiveriesHeader);

    for (let i = 0; i < state.livery.roof.count; i++) {
      const button = document.createElement("button");
      button.className = `livery-item${state.livery.roof.current === i ? " active" : ""}`;
      button.textContent = `Roof Livery ${i + 1}`;
      button.dataset.liveryIndex = i;
      button.dataset.isRoof = "true";

      button.addEventListener("click", () => {
        // Remove active class from roof livery buttons
        document
          .querySelectorAll('.livery-item[data-is-roof="true"]')
          .forEach((btn) => btn.classList.remove("active"));
        // Add active class to clicked button
        button.classList.add("active");

        // Send roof livery update to FiveM
        fetch(`https://qr-extramenu/changeLivery`, {
          method: "POST",
          body: JSON.stringify({
            liveryIndex: i,
            isRoof: true,
          }),
        });
      });

      container.appendChild(button);
    }
  }

  // Show message if no liveries available
  if (count <= 0 && (!state.livery.roof || state.livery.roof.count <= 0)) {
    const noLiveriesMsg = document.createElement("div");
    noLiveriesMsg.className = "no-liveries-message";
    noLiveriesMsg.textContent = "No liveries available for this vehicle";
    container.appendChild(noLiveriesMsg);
  }
}

// Update the updateVehicleState function to use the new populateLiveries
function updateVehicleState(state) {
  if (!state) return;

  // Clear all previous active states first
  clearActiveStates();

  // Update extras
  if (state.extras) {
    document.querySelectorAll(".extra-toggle").forEach((btn) => {
      const extraId = btn.dataset.extra;
      if (state.extras[extraId]) {
        btn.classList.add("active");
      }
    });
  }

  // Update colors
  if (state.colors) {
    // Update primary color buttons
    document.querySelectorAll('[data-type="primary"]').forEach((btn) => {
      if (parseInt(btn.dataset.colorIndex) === state.colors.primary) {
        btn.classList.add("active");
      }
    });

    // Update secondary color buttons
    document.querySelectorAll('[data-type="secondary"]').forEach((btn) => {
      if (parseInt(btn.dataset.colorIndex) === state.colors.secondary) {
        btn.classList.add("active");
      }
    });
  }

  // Update liveries with full state object
  populateLiveries(state);
}

// Color Categories
const FIVEM_COLORS = {
  metallic: [
    { name: "Ice White", index: 111 },
    { name: "Frost White", index: 112 },
    { name: "Black", index: 0 },
    { name: "Carbon Black", index: 147 },
    { name: "Graphite", index: 1 },
    { name: "Anthracite Black", index: 11 },
    { name: "Black Steel", index: 2 },
    { name: "Dark Steel", index: 3 },
    { name: "Silver", index: 4 },
    { name: "Bluish Silver", index: 5 },
    { name: "Rolled Steel", index: 6 },
    { name: "Shadow Silver", index: 7 },
    { name: "Stone Silver", index: 8 },
    { name: "Midnight Silver", index: 9 },
    { name: "Cast Iron Silver", index: 10 },
    { name: "Red", index: 27 },
    { name: "Torino Red", index: 28 },
    { name: "Formula Red", index: 29 },
    { name: "Blaze Red", index: 30 },
    { name: "Grace Red", index: 31 },
    { name: "Garnet Red", index: 32 },
    { name: "Sunset Red", index: 33 },
    { name: "Cabernet Red", index: 34 },
    { name: "Candy Red", index: 35 },
    { name: "Sunrise Orange", index: 36 },
    { name: "Orange", index: 38 },
    { name: "Dark Green", index: 49 },
    { name: "Racing Green", index: 50 },
    { name: "Sea Green", index: 51 },
    { name: "Olive Green", index: 52 },
    { name: "Bright Green", index: 53 },
    { name: "Gasoline Green", index: 54 },
    { name: "Galaxy Blue", index: 61 },
    { name: "Dark Blue", index: 62 },
    { name: "Saxon Blue", index: 63 },
    { name: "Blue", index: 64 },
    { name: "Mariner Blue", index: 65 },
    { name: "Harbor Blue", index: 66 },
    { name: "Diamond Blue", index: 67 },
    { name: "Surf Blue", index: 68 },
    { name: "Nautical Blue", index: 69 },
    { name: "Ultra Blue", index: 70 },
    { name: "Schafter Purple", index: 71 },
    { name: "Spinnaker Purple", index: 72 },
    { name: "Racing Blue", index: 73 },
    { name: "Light Blue", index: 74 },
    { name: "Yellow", index: 88 },
    { name: "Race Yellow", index: 89 },
    { name: "Bronze", index: 90 },
    { name: "Dew Yellow", index: 91 },
    { name: "Lime Green", index: 92 },
    { name: "Feltzer Brown", index: 94 },
    { name: "Creeen Brown", index: 95 },
    { name: "Chocolate Brown", index: 96 },
    { name: "Maple Brown", index: 97 },
    { name: "Saddle Brown", index: 98 },
    { name: "Straw Brown", index: 99 },
    { name: "Moss Brown", index: 100 },
    { name: "Bison Brown", index: 101 },
    { name: "Woodbeech Brown", index: 102 },
    { name: "Beechwood Brown", index: 103 },
    { name: "Sienna Brown", index: 104 },
    { name: "Sandy Brown", index: 105 },
    { name: "Bleached Brown", index: 106 },
    { name: "Cream", index: 107 },
    { name: "Hot Pink", index: 135 },
    { name: "Salmon Pink", index: 136 },
    { name: "Pfsiter Pink", index: 137 },
    { name: "Bright Orange", index: 138 },
    { name: "Midnight Blue", index: 141 },
    { name: "Midnight Purple", index: 142 },
    { name: "Wine Red", index: 143 },
    { name: "Bright Purple", index: 145 },
    { name: "Lava Red", index: 150 },
  ],
  matte: [
    { name: "Ice White", index: 131 },
    { name: "Black", index: 12 },
    { name: "Gray", index: 13 },
    { name: "Light Gray", index: 14 },
    { name: "Red", index: 39 },
    { name: "Dark Red", index: 40 },
    { name: "Orange", index: 41 },
    { name: "Yellow", index: 42 },
    { name: "Lime Green", index: 55 },
    { name: "Dark Blue", index: 82 },
    { name: "Blue", index: 83 },
    { name: "Midnight Blue", index: 84 },
    { name: "Green", index: 128 },
    { name: "Schafter Purple", index: 148 },
    { name: "Midnight Purple", index: 149 },
    { name: "Frost Green", index: 151 },
    { name: "Olive Darb", index: 152 },
    { name: "Desert Tan", index: 154 },
    { name: "Dark Earth", index: 155 },
  ],
  metals: [
    { name: "Brushed Steel", index: 117 },
    { name: "Brushed Black Steel", index: 118 },
    { name: "Brushed Aluminum", index: 119 },
    { name: "Pure Gold", index: 158 },
    { name: "Brushed Gold", index: 159 },
    { name: "Chrome", index: 120 },
  ],
};

// Create Color Grid
function createColorGrid(colors, type, category) {
  const grid = document.createElement("div");
  grid.className = "color-grid";

  colors.forEach((color) => {
    const button = document.createElement("button");
    button.className = "color-toggle";
    button.textContent = color.name;
    button.dataset.colorIndex = color.index;
    button.dataset.category = category;
    button.dataset.type = type;

    button.addEventListener("click", () => {
      // Remove active class from all buttons in the parent container
      button
        .closest(".colors-container")
        .querySelectorAll(".color-toggle")
        .forEach((btn) => btn.classList.remove("active"));
      // Add active class to clicked button
      button.classList.add("active");

      // Send color update to FiveM
      fetch(`https://qr-extramenu/changeColor`, {
        method: "POST",
        body: JSON.stringify({
          type: type,
          colorIndex: color.index,
        }),
      });
    });

    grid.appendChild(button);
  });

  return grid;
}

// Populate Colors
function populateColors() {
  const primaryContainer = document.getElementById("primary-colors");
  const secondaryContainer = document.getElementById("secondary-colors");

  primaryContainer.innerHTML = "";
  secondaryContainer.innerHTML = "";

  Object.entries(FIVEM_COLORS).forEach(([category, colors]) => {
    // Primary Colors
    const primaryCategoryHeader = document.createElement("h3");
    primaryCategoryHeader.className = "category-header";
    primaryCategoryHeader.textContent =
      category.charAt(0).toUpperCase() + category.slice(1);
    primaryContainer.appendChild(primaryCategoryHeader);

    const primaryGrid = createColorGrid(colors, "primary", category);
    primaryContainer.appendChild(primaryGrid);

    // Secondary Colors
    const secondaryCategoryHeader = document.createElement("h3");
    secondaryCategoryHeader.className = "category-header";
    secondaryCategoryHeader.textContent =
      category.charAt(0).toUpperCase() + category.slice(1);
    secondaryContainer.appendChild(secondaryCategoryHeader);

    const secondaryGrid = createColorGrid(colors, "secondary", category);
    secondaryContainer.appendChild(secondaryGrid);
  });
}

// Clear all active states
function clearActiveStates() {
  document.querySelectorAll(".color-toggle.active").forEach((btn) => {
    btn.classList.remove("active");
  });
  document.querySelectorAll(".extra-toggle.active").forEach((btn) => {
    btn.classList.remove("active");
  });
  document.querySelectorAll(".livery-item.active").forEach((btn) => {
    btn.classList.remove("active");
  });
}

// Menu Navigation
function showMenu(menuId) {
  document
    .querySelectorAll(".sub-menu, #main-menu")
    .forEach((menu) => menu.classList.add("hidden"));
  document
    .getElementById(menuId ? menuId : "main-menu")
    .classList.remove("hidden");
  document.querySelector(".back-btn").classList.toggle("hidden", !menuId);
}

// Function to close menu
function closeMenu() {
  document.querySelector(".vehicle-menu-container").style.display = "none";
  // Reset to main menu when closing
  showMenu();
  // Clear all active states
  clearActiveStates();
  // Notify FiveM
  fetch(`https://qr-extramenu/closeMenu`, {
    method: "POST",
  });
}

// Event Listeners
document.addEventListener("DOMContentLoaded", () => {
  // Menu Navigation
  document.querySelectorAll(".menu-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      showMenu(`${btn.dataset.menu}-menu`);
    });
  });

  // Back Button
  document
    .querySelector(".back-btn")
    .addEventListener("click", () => showMenu());

  // Extra Toggles
  document.querySelectorAll(".extra-toggle").forEach((btn) => {
    btn.addEventListener("click", () => {
      btn.classList.toggle("active");
      fetch(`https://qr-extramenu/toggleExtra`, {
        method: "POST",
        body: JSON.stringify({
          extra: btn.dataset.extra,
          state: btn.classList.contains("active"),
        }),
      });
    });
  });

  // Window tint button handler
  document.querySelector(".window-tint").addEventListener("click", () => {
    fetch(`https://qr-extramenu/setWindowTint`, {
      method: "POST",
      body: JSON.stringify({
        tint: 3, // 3 is light smoke
      }),
    });
  });

  // Remove All Extras
  document.querySelector(".remove-all-extras").addEventListener("click", () => {
    document.querySelectorAll(".extra-toggle").forEach((btn) => {
      btn.classList.remove("active");
    });
    fetch(`https://qr-extramenu/removeAllExtras`, {
      method: "POST",
    });
  });

  // Remove All Colors (Reset to Metallic Black)
  document.querySelector(".remove-all-colors").addEventListener("click", () => {
    document.querySelectorAll(".color-toggle").forEach((btn) => {
      btn.classList.remove("active");
    });
    fetch(`https://qr-extramenu/resetColors`, {
      method: "POST",
    });
  });

  // Remove All Liveries
  document
    .querySelector(".remove-all-liveries")
    .addEventListener("click", () => {
      document.querySelectorAll(".livery-item").forEach((btn) => {
        btn.classList.remove("active");
      });
      fetch(`https://qr-extramenu/changeLivery`, {
        method: "POST",
        body: JSON.stringify({
          liveryIndex: 0, // Set to 0 for no livery
          isRoof: false,
        }),
      });
    });

  // Vehicle Actions
  document.querySelector(".wash-vehicle").addEventListener("click", () => {
    fetch(`https://qr-extramenu/washVehicle`, {
      method: "POST",
    });
  });

  document.querySelector(".fix-vehicle").addEventListener("click", () => {
    fetch(`https://qr-extramenu/fixVehicle`, {
      method: "POST",
    });
  });

  // Initialize
  document.querySelector(".vehicle-menu-container").style.display = "none";
  populateColors();
});

// Handle Messages from FiveM
window.addEventListener("message", (event) => {
  if (event.data.type === "openMenu") {
    document.querySelector(".vehicle-menu-container").style.display = "block";
    showMenu();

    // Clear previous state and update with new vehicle state
    clearActiveStates();
    if (event.data.vehicleState) {
      updateVehicleState(event.data.vehicleState);
    }
  }

  if (event.data.type === "closeMenu") {
    document.querySelector(".vehicle-menu-container").style.display = "none";
    showMenu(); // Reset to main menu
    clearActiveStates(); // Clear all active states
  }
});

// Handle Escape Key
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    closeMenu();
  }
});
