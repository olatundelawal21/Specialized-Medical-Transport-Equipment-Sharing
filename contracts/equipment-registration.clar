;; Simple Equipment Registration Contract

(define-data-var last-id uint u0)

;; Basic equipment structure
(define-map equipment
  { id: uint }
  {
    name: (string-ascii 100),
    type: (string-ascii 50),
    available: bool,
    owner: principal
  }
)

;; Register equipment
(define-public (register (name (string-ascii 100)) (type (string-ascii 50)))
  (let
    ((new-id (+ (var-get last-id) u1)))
    (var-set last-id new-id)
    (map-set equipment
      { id: new-id }
      {
        name: name,
        type: type,
        available: true,
        owner: tx-sender
      }
    )
    (ok new-id)
  )
)

;; Get equipment
(define-read-only (get-equipment (id uint))
  (map-get? equipment { id: id })
)

;; Update availability
(define-public (set-available (id uint) (available bool))
  (let
    ((equip (unwrap! (map-get? equipment { id: id }) (err u1))))
    (asserts! (is-eq tx-sender (get owner equip)) (err u2))
    (map-set equipment
      { id: id }
      (merge equip { available: available })
    )
    (ok true)
  )
)

