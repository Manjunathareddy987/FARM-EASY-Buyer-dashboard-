// Mock data for farmer offers
const mockOffers = [
  {
    id: 1,
    title: "Organic Roma Tomatoes",
    quantity: "150 kg",
    price: "$2.50/kg",
    image: "https://images.unsplash.com/photo-1592841494900-055cc137145b?w=200&h=200&fit=crop",
    farmer: "Green Valley Farms",
    location: "California",
  },
  {
    id: 2,
    title: "Heirloom Carrots",
    quantity: "200 kg",
    price: "$1.80/kg",
    image: "https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73?w=200&h=200&fit=crop",
    farmer: "Sunrise Organics",
    location: "Oregon",
  },
  {
    id: 3,
    title: "Sweet Strawberries",
    quantity: "80 kg",
    price: "$4.00/kg",
    image: "https://images.unsplash.com/photo-1464454709131-ffd692591ee5?w=200&h=200&fit=crop",
    farmer: "Berry Best",
    location: "Florida",
  },
  {
    id: 4,
    title: "Fresh Lettuce",
    quantity: "120 kg",
    price: "$1.50/kg",
    image: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=200&h=200&fit=crop",
    farmer: "Green Valley Farms",
    location: "California",
  },
]

// Transportation options
const transportOptions = [
  {
    id: 1,
    name: "Agri-Logistics",
    price: "$60.00",
    delivery: "Estimated delivery: Jan 25-27",
    icon: "🚚",
    color: "#22c55e",
  },
  {
    id: 2,
    name: "Farm-to-Market Express",
    price: "$75.00",
    delivery: "Next Day Delivery",
    icon: "🚛",
    color: "#f59e0b",
  },
  {
    id: 3,
    name: "Green Haul",
    price: "$40.00",
    delivery: "Estimated delivery: Jan 28-30",
    icon: "🌱",
    color: "#10b981",
  },
  {
    id: 4,
    name: "CropCarriers",
    price: "$55.00",
    delivery: "Estimated delivery: Jan 25-26",
    icon: "📦",
    color: "#3b82f6",
  },
]

let currentPage = 1
let selectedTransportId = null
let allOffers = [...mockOffers]

const API_BASE_URL = resolveApiBase()

function resolveApiBase() {
  const override = window.__API_BASE_URL__ || window.API_BASE_URL || localStorage.getItem('API_BASE_URL')
  if (typeof override === 'string' && override.trim()) {
    return override.trim()
  }
  const { protocol, hostname, port } = window.location
  if (protocol === 'file:' || !hostname) {
    return 'http://localhost:3000'
  }
  const normalizedProtocol = protocol === 'https:' ? 'https:' : 'http:'
  const normalizedHost = hostname || 'localhost'
  const isLocalHost = ['localhost', '127.0.0.1'].includes(normalizedHost)
  if (isLocalHost && port && port !== '3000') {
    return `${normalizedProtocol}//${normalizedHost}:3000`
  }
  if (isLocalHost && !port) {
    return `${normalizedProtocol}//${normalizedHost}:3000`
  }
  return `${normalizedProtocol}//${normalizedHost}${port ? `:${port}` : ''}`
}

function apiFetch(path, options = {}) {
  const target = path.startsWith('http') ? path : `${API_BASE_URL}${path}`
  return fetch(target, options)
}

// Page Navigation
function goToPage(pageNumber) {
  document.querySelectorAll(".page").forEach((page) => page.classList.remove("active"))
  const pageEl = document.getElementById(`page-${pageNumber}`)
  if (pageEl) {
    pageEl.classList.add("active")
  }
  currentPage = pageNumber

  if (pageNumber === 2) {
    renderOffers()
  } else if (pageNumber === 3) {
    renderTransportOptions()
  } else if (pageNumber === 5) {
    displayConfirmation()
  }
}

// Page 1: Handle Purchase Offer Submit
function handlePurchaseSubmit(event) {
  event.preventDefault()

  const cropType = document.getElementById("cropType").value
  const quantity = document.getElementById("quantity").value
  const price = document.getElementById("price").value

  if (cropType && quantity && price) {
    const purchaseOffer = { cropType, quantity, price }
    localStorage.setItem("purchaseOffer", JSON.stringify(purchaseOffer))
    goToPage(2)
  }
}

// Page 2: Render Farmer Offers
function renderOffers() {
  const offersGrid = document.getElementById("offers-grid")
  offersGrid.innerHTML = ""

  allOffers.forEach((offer) => {
    const offerCard = document.createElement("div")
    offerCard.className = "offer-card"
    offerCard.innerHTML = `
            <img src="${offer.image}" alt="${offer.title}" class="offer-image">
            <div class="offer-content">
                <div>
                    <div class="offer-title">${offer.title}</div>
                    <div class="offer-details">${offer.quantity} at ${offer.price}</div>
                    <div class="offer-details">From ${offer.farmer}</div>
                </div>
                <button class="view-btn" onclick="selectOffer(${offer.id})">View Offer →</button>
            </div>
        `
    offersGrid.appendChild(offerCard)
  })
}

function selectOffer(offerId) {
  const offer = allOffers.find((o) => o.id === offerId)
  localStorage.setItem("selectedOffer", JSON.stringify(offer))
  goToPage(3)
}

function filterOffers() {
  const searchTerm = document.getElementById("search-input").value.toLowerCase()
  allOffers = mockOffers.filter(
    (offer) => offer.title.toLowerCase().includes(searchTerm) || offer.farmer.toLowerCase().includes(searchTerm),
  )
  renderOffers()
}

function sortOffers(sortType) {
  if (sortType === "price-low") {
    allOffers.sort((a, b) => {
      const priceA = Number.parseFloat(String(a.price).replace(/[^0-9.]/g, ""))
      const priceB = Number.parseFloat(String(b.price).replace(/[^0-9.]/g, ""))
      return priceA - priceB
    })
  } else if (sortType === "price-high") {
    allOffers.sort((a, b) => {
      const priceA = Number.parseFloat(String(a.price).replace(/[^0-9.]/g, ""))
      const priceB = Number.parseFloat(String(b.price).replace(/[^0-9.]/g, ""))
      return priceB - priceA
    })
  }
  renderOffers()
}

// Page 3: Render Transportation Options
function renderTransportOptions() {
  const transportContainer = document.getElementById("transport-options")
  transportContainer.innerHTML = ""

  transportOptions.forEach((option) => {
    const card = document.createElement("div")
    card.className = `transport-card ${selectedTransportId === option.id ? "selected" : ""}`
    card.onclick = () => selectTransport(option.id)
    card.innerHTML = `
            <div class="transport-icon" style="background-color: ${option.color}20">
                ${option.icon}
            </div>
            <div class="transport-info">
                <div class="transport-name">${option.name}</div>
                <div class="transport-price">${option.price}</div>
                <div class="transport-delivery">${option.delivery}</div>
            </div>
            <div class="radio-button ${selectedTransportId === option.id ? "selected" : ""}"></div>
        `
    transportContainer.appendChild(card)
  })
}

function selectTransport(transportId) {
  selectedTransportId = transportId
  document.getElementById("confirm-transport-btn").disabled = false
  renderTransportOptions()
}

function sortTransport(sortType) {
  if (sortType === "price-low") {
    transportOptions.sort((a, b) => Number.parseFloat(String(a.price).replace(/[^0-9.]/g, "")) - Number.parseFloat(String(b.price).replace(/[^0-9.]/g, "")))
  } else if (sortType === "price-high") {
    transportOptions.sort((a, b) => Number.parseFloat(String(b.price).replace(/[^0-9.]/g, "")) - Number.parseFloat(String(a.price).replace(/[^0-9.]/g, "")))
  }
  renderTransportOptions()
}

function confirmTransportation() {
  if (selectedTransportId) {
    const selected = transportOptions.find((t) => t.id === selectedTransportId)
    localStorage.setItem("selectedTransport", JSON.stringify(selected))
    goToPage(4)
  }
}

// Page 4: Handle Transportation Details Submit
function handleDetailsSubmit(event) {
  event.preventDefault()

  const vehicleName = document.getElementById("vehicleName").value
  const licensePlate = document.getElementById("licensePlate").value
  const driverName = document.getElementById("driverName").value
  const driverContact = document.getElementById("driverContact").value

  if (vehicleName && licensePlate) {
    const details = { vehicleName, licensePlate, driverName, driverContact }
    localStorage.setItem("transportationDetails", JSON.stringify(details))
    goToPage(5)
  }
}

// Page 5: Display Confirmation
function displayConfirmation() {
  const purchaseOffer = JSON.parse(localStorage.getItem("purchaseOffer"))
  const selectedOffer = JSON.parse(localStorage.getItem("selectedOffer"))
  const selectedTransport = JSON.parse(localStorage.getItem("selectedTransport"))
  const transportDetails = JSON.parse(localStorage.getItem("transportationDetails"))

  // Purchase Offer Summary
  document.getElementById("summary-crop").textContent = purchaseOffer.cropType
  document.getElementById("summary-quantity").textContent = purchaseOffer.quantity
  document.getElementById("summary-price").textContent = purchaseOffer.price

  // Selected Farmer Offer
  document.getElementById("summary-offer-crop").textContent = selectedOffer.title
  document.getElementById("summary-farmer").textContent = selectedOffer.farmer
  document.getElementById("summary-offer-quantity").textContent = selectedOffer.quantity

  // Transportation Details
  document.getElementById("summary-transport").textContent = selectedTransport.name
  document.getElementById("summary-vehicle").textContent = transportDetails.vehicleName
  document.getElementById("summary-plate").textContent = transportDetails.licensePlate
  document.getElementById("summary-driver").textContent = transportDetails.driverName || "Not provided"
}

function completeOrder() {
  alert("Order completed successfully!")
  // Clear localStorage
  localStorage.clear()
  // Go back to page 1
  goToPage(1)
  document.getElementById("purchase-form").reset()
}

// Toggle password visibility
function togglePassword(inputId) {
  const input = document.getElementById(inputId)
  const isPassword = input.type === "password"
  input.type = isPassword ? "text" : "password"
}

// Validate email format
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

// Validate phone number format
function isValidPhone(phone) {
  // Allow digits, spaces, dashes, plus and parentheses
  const phoneRegex = /^[\d\s\-+()]+$/
  return phoneRegex.test(phone) && phone.replace(/\D/g, "").length >= 10
}

// Handle Login Form Submission
document.addEventListener("DOMContentLoaded", () => {
  const loginForm = document.getElementById("loginForm")
  if (loginForm) {
    loginForm.addEventListener("submit", (e) => {
      e.preventDefault()

      const email = document.getElementById("email").value.trim()
      const password = document.getElementById("password").value
      const rememberMe = document.getElementById("remember").checked

      // Validation
      if (!email) {
        alert("Please enter your email or username")
        return
      }

      if (!password) {
        alert("Please enter your password")
        return
      }

      if (password.length < 6) {
        alert("Password must be at least 6 characters")
        return
      }

      // Call API login
      apiFetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      })
      .then(async (resp) => {
        if (!resp.ok) {
          const data = await resp.json().catch(() => ({}))
          throw new Error(data.error || 'Login failed')
        }
        return resp.json()
      })
      .then(({ token, user }) => {
        localStorage.setItem('authToken', token)
        localStorage.setItem('currentBuyer', JSON.stringify(user))
        localStorage.setItem('isLoggedIn', 'true')
        const loginData = { email, rememberMe, loginTime: new Date().toISOString() }
        localStorage.setItem('userLogin', JSON.stringify(loginData))
        alert('Login successful! Redirecting to dashboard...')
        window.location.href = "../buyerdash/bd.html"
      })
      .catch((e) => alert(e.message))
    })
  }

  // Handle Signup Form Submission
  const signupForm = document.getElementById("signupForm")
  if (signupForm) {
    signupForm.addEventListener("submit", (e) => {
      e.preventDefault()

      const businessName = document.getElementById("businessName").value.trim()
      const contactPerson = document.getElementById("contactPerson").value.trim()
      const email = document.getElementById("email").value.trim()
      const phone = document.getElementById("phone").value.trim()
      const address = document.getElementById("address").value.trim()
      const username = document.getElementById("username").value.trim()
      const password = document.getElementById("signupPassword").value
      const termsAccepted = document.getElementById("terms").checked

      // Validation
      if (!businessName) {
        alert("Please enter your business name")
        return
      }

      if (!contactPerson) {
        alert("Please enter contact person name")
        return
      }

      if (!email || !isValidEmail(email)) {
        alert("Please enter a valid email address")
        return
      }

      if (!phone || !isValidPhone(phone)) {
        alert("Please enter a valid phone number")
        return
      }

      if (!address) {
        alert("Please enter your business address")
        return
      }

      if (!username) {
        alert("Please enter a username")
        return
      }

      if (username.length < 4) {
        alert("Username must be at least 4 characters")
        return
      }

      if (!password) {
        alert("Please enter a password")
        return
      }

      if (password.length < 6) {
        alert("Password must be at least 6 characters")
        return
      }

      if (!termsAccepted) {
        alert("Please accept the Terms of Service and Privacy Policy")
        return
      }

      const normalizedAddress = address.trim() || 'Location not provided'

      // Call API signup (buyer role)
      apiFetch('/api/auth/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          role: 'buyer',
          name: businessName,
          email,
          password,
          location: normalizedAddress,
          address: normalizedAddress,
          contactPerson,
          phone,
          username
        })
      })
      .then(async (resp) => {
        if (!resp.ok) {
          const data = await resp.json().catch(() => ({}))
          throw new Error(data.error || 'Signup failed')
        }
        return resp.json()
      })
      .then(({ token, user }) => {
        localStorage.setItem('authToken', token)
        localStorage.setItem('currentBuyer', JSON.stringify(user))
        localStorage.setItem('isLoggedIn', 'true')
        alert('Account created successfully! Redirecting to dashboard...')
        window.location.href = "../buyerdash/bd.html"
      })
      .catch((e) => alert(e.message))
    })
  }

  // Check if user is already logged in -> redirect to dashboard and prevent back
  try {
    const isLoggedIn = localStorage.getItem("isLoggedIn") === 'true'
    const token = !!localStorage.getItem('authToken')
    const hasBuyer = !!localStorage.getItem('currentBuyer')
    const onLoginPage = /(^|\/)Buyerlogin\/(buy|login)\.html$/i.test(window.location.pathname) ||
                        window.location.pathname.includes('buy.html') ||
                        window.location.pathname.includes('login.html')
    if ((isLoggedIn || token) && hasBuyer && onLoginPage) {
      // replace so Back won't return to login page
      window.location.replace("../buyerdash/bd.html")
      return
    }
  } catch (_) {}
})

// Logout function (for use in dashboard)
function logout() {
  localStorage.removeItem("userLogin")
  localStorage.removeItem("userAccount")
  localStorage.removeItem("isLoggedIn")
  window.location.href = "buy.html"
}

// Get current user data
function getCurrentUser() {
  const userAccount = localStorage.getItem("userAccount")
  const userLogin = localStorage.getItem("userLogin")

  if (userAccount) {
    return JSON.parse(userAccount)
  } else if (userLogin) {
    return JSON.parse(userLogin)
  }
  return null
}

// Check authentication status
function isAuthenticated() {
  return localStorage.getItem("isLoggedIn") === "true"
}

// Protect pages - redirect to login if not authenticated
function protectPage() {
  if (!isAuthenticated()) {
    window.location.href = "buy.html"
  }
}

// Initialize
document.addEventListener("DOMContentLoaded", () => {
  if (document.querySelectorAll(".page").length) {
    goToPage(1)
  }
})
