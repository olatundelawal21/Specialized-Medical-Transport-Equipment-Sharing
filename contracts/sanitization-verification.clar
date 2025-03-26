;; Simple Sanitization Verification Contract

(define-data-var last-id uint u0)

;; Basic sanitization record
(define-map sanitization-records
  { id: uint }
  {
    equipment-id: uint,
    sanitized-by: principal,
    verified: bool,
    date: uint
  }
)

;; Record sanitization
(define-public (record-sanitization (equipment-id uint))
  (let
    ((new-id (+ (var-get last-id) u1))
     (block-time (unwrap! (get-block-info? time (- block-height u1)) (err u1))))
    (var-set last-id new-id)
    (map-set sanitization-records
      { id: new-id }
      {
        equipment-id: equipment-id,
        sanitized-by: tx-sender,
        verified: false,
        date: block-time
      }
    )
    (ok new-id)
  )
)

;; Verify sanitization
(define-public (verify-sanitization (record-id uint))
  (let
    ((record (unwrap! (map-get? sanitization-records { id: record-id }) (err u1))))
    (map-set sanitization-records
      { id: record-id }
      (merge record { verified: true })
    )
    (ok true)
  )
)

;; Get sanitization record
(define-read-only (get-record (id uint))
  (map-get? sanitization-records { id: id })
)

