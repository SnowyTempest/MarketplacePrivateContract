;; MVP Data Marketplace - Bootcamp Version
;; Combined contract with essential features only

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-UNAUTHORIZED (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-INVALID-PRICE (err u104))
(define-constant ERR-INVALID-RATING (err u105))

;; Data Variables
(define-data-var marketplace-fee uint u250) ;; 2.5% fee
(define-data-var next-listing-id uint u1)

;; Core Data Maps
(define-map data-listings
  { listing-id: uint }
  {
    seller: principal,
    title: (string-ascii 100),
    description: (string-ascii 200),
    price: uint,
    privacy-level: uint, ;; 1=basic, 2=enhanced, 3=maximum
    is-active: bool,
    total-sales: uint
  }
)

(define-map user-profiles
  { user: principal }
  {
    reputation: uint, ;; 0-100 score
    total-listings: uint,
    total-earnings: uint
  }
)

(define-map data-access
  { listing-id: uint, buyer: principal }
  { has-access: bool }
)

;; Privacy certification (simplified)
(define-map privacy-certs
  { listing-id: uint }
  { certified: bool, method: (string-ascii 50) }
)

;; Helper Functions
(define-private (calculate-fee (amount uint))
  (/ (* amount (var-get marketplace-fee)) u10000)
)

(define-private (min (a uint) (b uint))
  (if (< a b) a b)
)

;; Public Functions

;; Create listing with basic privacy check
(define-public (create-listing 
  (title (string-ascii 100))
  (description (string-ascii 200))
  (price uint)
  (privacy-level uint)
  (privacy-method (string-ascii 50))
)
  (let (
    (listing-id (var-get next-listing-id))
  )
    (asserts! (> price u0) ERR-INVALID-PRICE)
    (asserts! (and (>= privacy-level u1) (<= privacy-level u3)) ERR-INVALID-PRICE)
    
    ;; Create listing
    (map-set data-listings
      { listing-id: listing-id }
      {
        seller: tx-sender,
        title: title,
        description: description,
        price: price,
        privacy-level: privacy-level,
        is-active: true,
        total-sales: u0
      }
    )
    
    ;; Auto-certify privacy (simplified for MVP)
    (map-set privacy-certs
      { listing-id: listing-id }
      { certified: true, method: privacy-method }
    )
    
    ;; Update/create user profile
    (match (map-get? user-profiles { user: tx-sender })
      profile
        (map-set user-profiles
          { user: tx-sender }
          (merge profile { total-listings: (+ (get total-listings profile) u1) })
        )
      ;; Create new profile
      (map-set user-profiles
        { user: tx-sender }
        { reputation: u100, total-listings: u1, total-earnings: u0 }
      )
    )
    
    (var-set next-listing-id (+ listing-id u1))
    (ok listing-id)
  )
)

;; Purchase data access
(define-public (purchase-data (listing-id uint))
  (let (
    (listing (unwrap! (map-get? data-listings { listing-id: listing-id }) ERR-NOT-FOUND))
    (price (get price listing))
    (seller (get seller listing))
    (fee (calculate-fee price))
    (seller-amount (- price fee))
  )
    (asserts! (get is-active listing) ERR-NOT-FOUND)
    (asserts! (not (is-eq tx-sender seller)) ERR-UNAUTHORIZED)
    
    ;; Transfer payment
    (try! (stx-transfer? seller-amount tx-sender seller))
    (try! (stx-transfer? fee tx-sender CONTRACT-OWNER))
    
    ;; Grant access
    (map-set data-access
      { listing-id: listing-id, buyer: tx-sender }
      { has-access: true }
    )
    
    ;; Update listing stats
    (map-set data-listings
      { listing-id: listing-id }
      (merge listing { total-sales: (+ (get total-sales listing) u1) })
    )
    
    ;; Update seller earnings and reputation
    (unwrap! (match (map-get? user-profiles { user: seller })
      profile
        (begin
          (map-set user-profiles
            { user: seller }
            (merge profile {
              total-earnings: (+ (get total-earnings profile) seller-amount),
              reputation: (min u100 (+ (get reputation profile) u5))
            })
          )
          (ok true)
        )
      (err ERR-NOT-FOUND)
    ) ERR-NOT-FOUND)
    
    (ok true)
  )
)

;; Rate a seller (simple reputation system)
(define-public (rate-seller (seller principal) (rating uint))
  (let (
    (profile (unwrap! (map-get? user-profiles { user: seller }) ERR-NOT-FOUND))
    (current-rep (get reputation profile))
  )
    (asserts! (and (>= rating u1) (<= rating u5)) ERR-INVALID-RATING)
    (asserts! (not (is-eq tx-sender seller)) ERR-UNAUTHORIZED)
    
    ;; Simple reputation update: average with current score
    (let (
      (rating-normalized (* rating u20)) ;; Convert 1-5 to 20-100 scale
      (new-rep (/ (+ current-rep rating-normalized) u2))
    )
      (map-set user-profiles
        { user: seller }
        (merge profile { reputation: new-rep })
      )
    )
    
    (ok true)
  )
)

;; Toggle listing active status (seller only)
(define-public (toggle-listing (listing-id uint))
  (let (
    (listing (unwrap! (map-get? data-listings { listing-id: listing-id }) ERR-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get seller listing)) ERR-UNAUTHORIZED)
    
    (map-set data-listings
      { listing-id: listing-id }
      (merge listing { is-active: (not (get is-active listing)) })
    )
    
    (ok true)
  )
)

;; Update marketplace fee (owner only)
(define-public (set-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (asserts! (<= new-fee u500) ERR-INVALID-PRICE) ;; Max 5% fee
    (var-set marketplace-fee new-fee)
    (ok true)
  )
)

;; Read-only Functions

;; Get listing details
(define-read-only (get-listing (listing-id uint))
  (map-get? data-listings { listing-id: listing-id })
)

;; Get user profile
(define-read-only (get-profile (user principal))
  (map-get? user-profiles { user: user })
)

;; Check data access
(define-read-only (has-access (listing-id uint) (buyer principal))
  (default-to false 
    (get has-access 
      (map-get? data-access { listing-id: listing-id, buyer: buyer })))
)

;; Get privacy certification
(define-read-only (get-privacy-cert (listing-id uint))
  (map-get? privacy-certs { listing-id: listing-id })
)

;; Get marketplace stats
(define-read-only (get-marketplace-stats)
  {
    total-listings: (- (var-get next-listing-id) u1),
    current-fee: (var-get marketplace-fee)
  }
)

;; Get current fee
(define-read-only (get-fee)
  (var-get marketplace-fee)
)