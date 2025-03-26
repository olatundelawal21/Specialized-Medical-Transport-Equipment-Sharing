;; Simple Patient Matching Contract

(define-data-var last-patient-id uint u0)
(define-data-var last-match-id uint u0)

;; Basic patient structure
(define-map patients
  { id: uint }
  {
    name: (string-ascii 100),
    needs: (string-ascii 200),
    provider: principal
  }
)

;; Basic match structure
(define-map matches
  { id: uint }
  {
    patient-id: uint,
    equipment-id: uint,
    active: bool
  }
)

;; Register patient
(define-public (register-patient (name (string-ascii 100)) (needs (string-ascii 200)))
  (let
    ((new-id (+ (var-get last-patient-id) u1)))
    (var-set last-patient-id new-id)
    (map-set patients
      { id: new-id }
      {
        name: name,
        needs: needs,
        provider: tx-sender
      }
    )
    (ok new-id)
  )
)

;; Get patient
(define-read-only (get-patient (id uint))
  (map-get? patients { id: id })
)

;; Create match
(define-public (create-match (patient-id uint) (equipment-id uint))
  (let
    ((new-id (+ (var-get last-match-id) u1))
     (patient (unwrap! (map-get? patients { id: patient-id }) (err u1))))
    (asserts! (is-eq tx-sender (get provider patient)) (err u2))
    (var-set last-match-id new-id)
    (map-set matches
      { id: new-id }
      {
        patient-id: patient-id,
        equipment-id: equipment-id,
        active: true
      }
    )
    (ok new-id)
  )
)

;; End match
(define-public (end-match (match-id uint))
  (let
    ((match (unwrap! (map-get? matches { id: match-id }) (err u1))))
    (map-set matches
      { id: match-id }
      (merge match { active: false })
    )
    (ok true)
  )
)

;; Get match
(define-read-only (get-match (id uint))
  (map-get? matches { id: id })
)

